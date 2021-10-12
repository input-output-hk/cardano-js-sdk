import Schema, { TxIn, TxOut } from '@cardano-ogmios/schema';
import { Buffer } from 'buffer';
import { UtxoRepository } from './types';
import { CardanoProvider, Ogmios, CardanoSerializationLib, CSL } from '@cardano-sdk/core';
import { dummyLogger, Logger } from 'ts-log';
import { ImplicitCoin, InputSelector, SelectionConstraints, SelectionResult } from '@cardano-sdk/cip2';
import { KeyManager } from './KeyManagement';
import { OnTransactionArgs, TransactionTracker, UtxoRepositoryEvents } from '.';
import { cslToOgmios } from '@cardano-sdk/core/src/Ogmios';
import Emittery from 'emittery';
import { TransactionError, TransactionFailure } from './TransactionError';

export interface InMemoryUtxoRepositoryProps {
  csl: CardanoSerializationLib;
  provider: CardanoProvider;
  keyManager: KeyManager;
  inputSelector: InputSelector;
  txTracker: TransactionTracker;
  logger?: Logger;
}

const utxoEquals = ([txIn1]: [Schema.TxIn, Schema.TxOut], [txIn2]: [Schema.TxIn, Schema.TxOut]): boolean =>
  txIn1.txId === txIn2.txId && txIn1.index === txIn2.index;
export class InMemoryUtxoRepository extends Emittery<UtxoRepositoryEvents> implements UtxoRepository {
  #csl: CardanoSerializationLib;
  #delegationAndRewards: Schema.DelegationsAndRewards;
  #inputSelector: InputSelector;
  #keyManager: KeyManager;
  #logger: Logger;
  #provider: CardanoProvider;
  #utxoSet: Set<[TxIn, TxOut]>;
  #lockedUtxoSet: Set<[TxIn, TxOut]> = new Set();

  constructor({
    csl,
    logger = dummyLogger,
    provider,
    inputSelector,
    keyManager,
    txTracker
  }: InMemoryUtxoRepositoryProps) {
    super();
    this.#csl = csl;
    this.#logger = logger;
    this.#provider = provider;
    this.#utxoSet = new Set();
    this.#delegationAndRewards = { rewards: undefined, delegate: undefined };
    this.#inputSelector = inputSelector;
    this.#keyManager = keyManager;
    txTracker.on('transaction', (args) => {
      // not blocking to make it testable easier
      this.#onTransaction(args).catch(this.#logger.error);
    });
  }

  public async sync(): Promise<void> {
    this.#logger.debug('Syncing InMemoryUtxoRepository');
    const result = await this.#provider.utxoDelegationAndRewards(
      [this.#keyManager.deriveAddress(1, 0)],
      Buffer.from(this.#keyManager.stakeKey.hash().to_bytes()).toString('hex')
    );
    this.#logger.trace(result);
    for (const utxo of result.utxo) {
      if (!this.allUtxos.some((oldUtxo) => utxoEquals(utxo, oldUtxo))) {
        this.#utxoSet.add(utxo);
        this.#logger.debug('New UTxO', utxo);
      }
    }
    for (const utxo of this.#utxoSet) {
      if (!result.utxo.some((newUtxo) => utxoEquals(utxo, newUtxo))) {
        this.#utxoSet.delete(utxo);
        this.#logger.debug('UTxO is gone', utxo);
      }
    }
    if (this.#delegationAndRewards.delegate !== result.delegationAndRewards.delegate) {
      this.#delegationAndRewards.delegate = result.delegationAndRewards.delegate;
      this.#logger.debug('Delegation stored', result.delegationAndRewards.delegate);
    }
    if (this.#delegationAndRewards.rewards !== result.delegationAndRewards.rewards) {
      this.#delegationAndRewards.rewards = result.delegationAndRewards.rewards;
      this.#logger.debug('Rewards balance stored', result.delegationAndRewards.rewards);
    }
  }

  public async selectInputs(
    outputs: Set<CSL.TransactionOutput>,
    constraints: SelectionConstraints,
    implicitCoin?: ImplicitCoin
  ): Promise<SelectionResult> {
    if (this.#utxoSet.size === 0) {
      this.#logger.debug('Local UTxO set is empty. Syncing...');
      await this.sync();
    }
    return this.#inputSelector.select({
      utxo: new Set(Ogmios.ogmiosToCsl(this.#csl).utxo(this.availableUtxos)),
      outputs,
      constraints,
      implicitCoin
    });
  }

  public get allUtxos(): Schema.Utxo {
    return [...this.#utxoSet.values()];
  }

  public get availableUtxos(): Schema.Utxo {
    return this.allUtxos.filter((utxo) => !this.#lockedUtxoSet.has(utxo));
  }

  public get rewards(): Schema.Lovelace | null {
    return this.#delegationAndRewards.rewards ?? null;
  }

  public get delegation(): Schema.PoolId | null {
    return this.#delegationAndRewards.delegate ?? null;
  }

  async #onTransaction({ transaction, confirmed }: OnTransactionArgs) {
    const utxoLockedByTx: Schema.Utxo = [];
    const inputs = transaction.body().inputs();
    for (let inputIdx = 0; inputIdx < inputs.len(); inputIdx++) {
      const { txId, index } = cslToOgmios.txIn(inputs.get(inputIdx));
      const utxo = this.allUtxos.find(([txIn]) => txIn.txId === txId && txIn.index === index)!;
      this.#lockedUtxoSet.add(utxo);
      utxoLockedByTx.push(utxo);
    }
    const unlock = (spent?: boolean) => {
      for (const utxo of utxoLockedByTx) {
        this.#lockedUtxoSet.delete(utxo);
        spent && this.#utxoSet.delete(utxo);
      }
    };
    try {
      await confirmed;
      unlock(true);
    } catch (error) {
      unlock(false);
      if (!(error instanceof TransactionError) || error.reason !== TransactionFailure.Timeout) {
        await this.emit('transactionUntracked', transaction).catch(this.#logger.error);
      }
    }
  }
}
