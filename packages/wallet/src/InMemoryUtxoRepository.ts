import Schema, { TxIn, TxOut } from '@cardano-ogmios/schema';
import { Buffer } from 'buffer';
import { CardanoProvider, Ogmios, CardanoSerializationLib, CSL, cslUtil } from '@cardano-sdk/core';
import { dummyLogger, Logger } from 'ts-log';
import { ImplicitCoin, InputSelector, SelectionConstraints, SelectionResult } from '@cardano-sdk/cip2';
import { KeyManager } from './KeyManagement';
import {
  UtxoRepository,
  OnTransactionArgs,
  TransactionTracker,
  TransactionTrackerEvent,
  UtxoRepositoryEvent,
  UtxoRepositoryEvents
} from './types';
import { cslToOgmios } from '@cardano-sdk/core/src/Ogmios';
import Emittery from 'emittery';

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
  #delegationAndRewards: Ogmios.DelegationsAndRewards;
  #inputSelector: InputSelector;
  #keyManager: KeyManager;
  #logger: Logger;
  #provider: CardanoProvider;
  #utxoSet: Set<[TxIn, TxOut]>;
  #lockedUtxoSet: Set<[TxIn, TxOut]> = new Set();
  #lockedRewards = 0n;

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
    txTracker.on(TransactionTrackerEvent.NewTransaction, (args) => {
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
      this.#delegationAndRewards.rewards = result.delegationAndRewards.rewards
        ? BigInt(result.delegationAndRewards.rewards)
        : undefined;
      this.#logger.debug('Rewards balance stored', result.delegationAndRewards.rewards);
    }
    this.#emitSynced();
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

  public get allRewards(): Ogmios.Lovelace | null {
    return this.#delegationAndRewards.rewards ?? null;
  }

  public get availableRewards(): Ogmios.Lovelace | null {
    if (!this.allRewards) return null;
    return this.allRewards - this.#lockedRewards;
  }

  public get delegation(): Schema.PoolId | null {
    return this.#delegationAndRewards.delegate ?? null;
  }

  #emitSynced() {
    this.emit(UtxoRepositoryEvent.Changed, {
      allUtxos: this.allUtxos,
      availableUtxos: this.availableUtxos,
      allRewards: this.allRewards,
      availableRewards: this.availableRewards,
      delegation: this.delegation
    }).catch(this.#logger.error);
  }

  async #onTransaction({ transaction, confirmed }: OnTransactionArgs) {
    // Lock reward
    const rewardsLockedByTx = this.#getOwnTransactionWithdrawalQty(transaction);
    this.#lockedRewards += rewardsLockedByTx;
    // Lock utxo
    const utxoLockedByTx: Schema.Utxo = [];
    const inputs = transaction.body().inputs();
    for (let inputIdx = 0; inputIdx < inputs.len(); inputIdx++) {
      const { txId, index } = cslToOgmios.txIn(inputs.get(inputIdx));
      const utxo = this.allUtxos.find(([txIn]) => txIn.txId === txId && txIn.index === index)!;
      this.#lockedUtxoSet.add(utxo);
      utxoLockedByTx.push(utxo);
    }
    this.#emitSynced();
    // Await confirmation. Rejection should be handled by the user after submitting transaction.
    await confirmed.catch(() => void 0);
    // Unlock utxo
    for (const utxo of utxoLockedByTx) {
      this.#lockedUtxoSet.delete(utxo);
    }
    // Unlock rewards
    this.#lockedRewards -= rewardsLockedByTx;
    // Sync utxo and rewards with the provider
    await this.#trySync();
  }

  async #trySync() {
    try {
      await this.sync();
    } catch (error) {
      this.#logger.debug('InMemoryUtxoRepository.#trySync failed:', error);
      this.emit(UtxoRepositoryEvent.OutOfSync, void 0).catch(this.#logger.error);
    }
  }

  #getOwnTransactionWithdrawalQty(transaction: CSL.Transaction) {
    const withdrawals = transaction.body().withdrawals();
    if (!withdrawals) return 0n;
    const ownStakeCredential = this.#csl.StakeCredential.from_keyhash(this.#keyManager.stakeKey.hash());
    const withdrawalKeys = withdrawals.keys();
    let withdrawalTotal = 0n;
    for (let withdrawalKeyIdx = 0; withdrawalKeyIdx < withdrawalKeys.len(); withdrawalKeyIdx++) {
      const rewardAddress = withdrawalKeys.get(withdrawalKeyIdx);
      if (cslUtil.bytewiseEquals(rewardAddress.payment_cred(), ownStakeCredential)) {
        withdrawalTotal += BigInt(withdrawals.get(rewardAddress)!.to_str());
      }
    }
    return withdrawalTotal;
  }
}
