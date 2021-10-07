import Schema, { TxIn, TxOut } from '@cardano-ogmios/schema';
import { Buffer } from 'buffer';
import { UtxoRepository } from './types';
import { CardanoProvider, Ogmios, CardanoSerializationLib, CSL } from '@cardano-sdk/core';
import { dummyLogger, Logger } from 'ts-log';
import { ImplicitCoin, InputSelector, SelectionConstraints, SelectionResult } from '@cardano-sdk/cip2';
import { KeyManager } from './KeyManagement';

export class InMemoryUtxoRepository implements UtxoRepository {
  #csl: CardanoSerializationLib;
  #delegationAndRewards: Schema.DelegationsAndRewards;
  #inputSelector: InputSelector;
  #keyManager: KeyManager;
  #logger: Logger;
  #provider: CardanoProvider;
  #utxoSet: Set<[TxIn, TxOut]>;

  constructor(
    csl: CardanoSerializationLib,
    provider: CardanoProvider,
    keyManager: KeyManager,
    inputSelector: InputSelector,
    logger?: Logger
  ) {
    this.#csl = csl;
    this.#logger = logger ?? dummyLogger;
    this.#provider = provider;
    this.#utxoSet = new Set();
    this.#delegationAndRewards = { rewards: undefined, delegate: undefined };
    this.#inputSelector = inputSelector;
    this.#keyManager = keyManager;
  }

  public async sync(): Promise<void> {
    this.#logger.debug('Syncing InMemoryUtxoRepository');
    const result = await this.#provider.utxoDelegationAndRewards(
      [this.#keyManager.deriveAddress(1, 0)],
      Buffer.from(this.#keyManager.stakeKey.hash().to_bytes()).toString('hex')
    );
    this.#logger.trace(result);
    for (const utxo of result.utxo) {
      if (!this.#utxoSet.has(utxo)) {
        this.#utxoSet.add(utxo);
        this.#logger.debug('New UTxO', utxo);
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
      utxo: new Set(Ogmios.ogmiosToCsl(this.#csl).utxo(this.allUtxos)),
      outputs,
      constraints,
      implicitCoin
    });
  }

  public get allUtxos(): Schema.Utxo {
    return [...this.#utxoSet.values()];
  }

  public get rewards(): Schema.Lovelace | null {
    return this.#delegationAndRewards.rewards ?? null;
  }

  public get delegation(): Schema.PoolId | null {
    return this.#delegationAndRewards.delegate ?? null;
  }
}
