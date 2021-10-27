import { WalletProvider, Cardano, cslUtil, CSL, coreToCsl, cslToCore } from '@cardano-sdk/core';
import { dummyLogger, Logger } from 'ts-log';
import { InputSelector, SelectionConstraints, SelectionResult } from '@cardano-sdk/cip2';
import { KeyManager } from './KeyManagement';
import {
  UtxoRepository,
  OnTransactionArgs,
  TransactionTracker,
  TransactionTrackerEvent,
  UtxoRepositoryEvent,
  UtxoRepositoryEvents
} from './types';
import Emittery from 'emittery';

export interface InMemoryUtxoRepositoryProps {
  provider: WalletProvider;
  keyManager: KeyManager;
  inputSelector: InputSelector;
  txTracker: TransactionTracker;
  logger?: Logger;
}

const utxoEquals = ([txIn1]: Cardano.Utxo, [txIn2]: Cardano.Utxo): boolean =>
  txIn1.txId === txIn2.txId && txIn1.index === txIn2.index;

export class InMemoryUtxoRepository extends Emittery<UtxoRepositoryEvents> implements UtxoRepository {
  #delegationAndRewards: Cardano.DelegationsAndRewards;
  #inputSelector: InputSelector;
  #keyManager: KeyManager;
  #logger: Logger;
  #provider: WalletProvider;
  #utxoSet: Set<Cardano.Utxo>;
  #lockedUtxoSet: Set<Cardano.Utxo> = new Set();
  #lockedRewards = 0n;

  constructor({ logger = dummyLogger, provider, inputSelector, keyManager, txTracker }: InMemoryUtxoRepositoryProps) {
    super();
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
    implicitCoin?: Cardano.ImplicitCoin
  ): Promise<SelectionResult> {
    if (this.#utxoSet.size === 0) {
      this.#logger.debug('Local UTxO set is empty. Syncing...');
      await this.sync();
    }
    return this.#inputSelector.select({
      utxo: new Set(coreToCsl.utxo(this.availableUtxos)),
      outputs,
      constraints,
      implicitCoin
    });
  }

  public get allUtxos(): Cardano.Utxo[] {
    return [...this.#utxoSet.values()];
  }

  public get availableUtxos(): Cardano.Utxo[] {
    return this.allUtxos.filter((utxo) => !this.#lockedUtxoSet.has(utxo));
  }

  public get allRewards(): Cardano.Lovelace | null {
    return this.#delegationAndRewards.rewards ?? null;
  }

  public get availableRewards(): Cardano.Lovelace | null {
    if (!this.allRewards) return null;
    return this.allRewards - this.#lockedRewards;
  }

  public get delegation(): Cardano.PoolId | null {
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
    const utxoLockedByTx: Cardano.Utxo[] = [];
    const inputs = transaction.body().inputs();
    for (let inputIdx = 0; inputIdx < inputs.len(); inputIdx++) {
      // don't need the address, not using it
      const { txId, index } = cslToCore.txIn(inputs.get(inputIdx), '' as Cardano.Address);
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
    const ownStakeCredential = CSL.StakeCredential.from_keyhash(this.#keyManager.stakeKey.hash());
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
