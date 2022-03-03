import { BehaviorSubject } from 'rxjs';
import { RewardHistoryProps, WalletProvider } from '@cardano-sdk/core';

export interface WalletProviderFnStats {
  numCalls: number;
  numResponses: number;
}

export const CLEAN_FN_STATS = { numCalls: 0, numResponses: 0 };

export class WalletProviderStats {
  readonly currentWalletProtocolParameters$ = new BehaviorSubject<WalletProviderFnStats>(CLEAN_FN_STATS);
  readonly genesisParameters$ = new BehaviorSubject<WalletProviderFnStats>(CLEAN_FN_STATS);
  readonly ledgerTip$ = new BehaviorSubject<WalletProviderFnStats>(CLEAN_FN_STATS);
  readonly networkInfo$ = new BehaviorSubject<WalletProviderFnStats>(CLEAN_FN_STATS);
  readonly queryBlocksByHashes$ = new BehaviorSubject<WalletProviderFnStats>(CLEAN_FN_STATS);
  readonly queryTransactionsByAddresses$ = new BehaviorSubject<WalletProviderFnStats>(CLEAN_FN_STATS);
  readonly queryTransactionsByHashes$ = new BehaviorSubject<WalletProviderFnStats>(CLEAN_FN_STATS);
  readonly rewardsHistory$ = new BehaviorSubject<WalletProviderFnStats>(CLEAN_FN_STATS);
  readonly submitTx$ = new BehaviorSubject<WalletProviderFnStats>(CLEAN_FN_STATS);
  readonly utxoDelegationAndRewards$ = new BehaviorSubject<WalletProviderFnStats>(CLEAN_FN_STATS);
  readonly stakePoolStats$ = new BehaviorSubject<WalletProviderFnStats>(CLEAN_FN_STATS);

  reset() {
    this.currentWalletProtocolParameters$.next(CLEAN_FN_STATS);
    this.genesisParameters$.next(CLEAN_FN_STATS);
    this.ledgerTip$.next(CLEAN_FN_STATS);
    this.networkInfo$.next(CLEAN_FN_STATS);
    this.queryBlocksByHashes$.next(CLEAN_FN_STATS);
    this.queryTransactionsByAddresses$.next(CLEAN_FN_STATS);
    this.queryTransactionsByHashes$.next(CLEAN_FN_STATS);
    this.rewardsHistory$.next(CLEAN_FN_STATS);
    this.submitTx$.next(CLEAN_FN_STATS);
    this.utxoDelegationAndRewards$.next(CLEAN_FN_STATS);
    this.stakePoolStats$.next(CLEAN_FN_STATS);
  }
}

/**
 * Wraps a WalletProvider, tracking # of calls of each function
 */
export class TrackedWalletProvider implements WalletProvider {
  readonly stats = new WalletProviderStats();
  readonly stakePoolStats: WalletProvider['stakePoolStats'];
  readonly ledgerTip: WalletProvider['ledgerTip'];
  readonly networkInfo: WalletProvider['networkInfo'];
  readonly submitTx: WalletProvider['submitTx'];
  readonly utxoDelegationAndRewards: WalletProvider['utxoDelegationAndRewards'];
  readonly queryTransactionsByAddresses: WalletProvider['queryTransactionsByAddresses'];
  readonly queryTransactionsByHashes: WalletProvider['queryTransactionsByHashes'];
  readonly queryBlocksByHashes: WalletProvider['queryBlocksByHashes'];
  readonly currentWalletProtocolParameters: WalletProvider['currentWalletProtocolParameters'];
  readonly genesisParameters: WalletProvider['genesisParameters'];
  readonly rewardsHistory: WalletProvider['rewardsHistory'];

  constructor(walletProvider: WalletProvider) {
    walletProvider = walletProvider;

    this.stakePoolStats =
      typeof walletProvider.stakePoolStats !== 'undefined'
        ? () => this.#trackedCall(walletProvider.stakePoolStats!, this.stats.stakePoolStats$)
        : undefined;
    this.ledgerTip = () => this.#trackedCall(walletProvider.ledgerTip, this.stats.ledgerTip$);
    this.networkInfo = () => this.#trackedCall(walletProvider.networkInfo, this.stats.networkInfo$);
    this.submitTx = (signedTransaction) =>
      this.#trackedCall(() => walletProvider.submitTx(signedTransaction), this.stats.submitTx$);
    this.utxoDelegationAndRewards = (addresses, rewardAccount) =>
      this.#trackedCall(
        () => walletProvider.utxoDelegationAndRewards(addresses, rewardAccount),
        this.stats.utxoDelegationAndRewards$
      );
    this.queryTransactionsByAddresses = (addresses) =>
      this.#trackedCall(
        () => walletProvider.queryTransactionsByAddresses(addresses),
        this.stats.queryTransactionsByAddresses$
      );
    this.queryTransactionsByHashes = (hashes) =>
      this.#trackedCall(() => walletProvider.queryTransactionsByHashes(hashes), this.stats.queryTransactionsByHashes$);
    this.queryBlocksByHashes = (hashes) =>
      this.#trackedCall(() => walletProvider.queryBlocksByHashes(hashes), this.stats.queryBlocksByHashes$);
    this.currentWalletProtocolParameters = () =>
      this.#trackedCall(walletProvider.currentWalletProtocolParameters, this.stats.currentWalletProtocolParameters$);
    this.genesisParameters = () => this.#trackedCall(walletProvider.genesisParameters, this.stats.genesisParameters$);
    this.rewardsHistory = (props: RewardHistoryProps) =>
      this.#trackedCall(() => walletProvider.rewardsHistory(props), this.stats.rewardsHistory$);
  }

  #trackedCall<T>(call: () => Promise<T>, tracker: BehaviorSubject<WalletProviderFnStats>) {
    tracker.next({ ...tracker.value, numCalls: tracker.value.numCalls + 1 });
    return call().then((result: T) => {
      tracker.next({
        ...tracker.value,
        numResponses: tracker.value.numResponses + 1
      });
      return result;
    });
  }
}
