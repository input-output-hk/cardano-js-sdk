import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, ProviderTracker } from './ProviderTracker';
import { RewardHistoryProps, WalletProvider } from '@cardano-sdk/core';

export class WalletProviderStats {
  readonly currentWalletProtocolParameters$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly genesisParameters$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly ledgerTip$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly blocksByHashes$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly transactionsByAddresses$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly transactionsByHashes$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly rewardsHistory$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly rewardAccountBalance$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly stakePoolStats$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.currentWalletProtocolParameters$.complete();
    this.genesisParameters$.complete();
    this.ledgerTip$.complete();
    this.blocksByHashes$.complete();
    this.transactionsByAddresses$.complete();
    this.transactionsByHashes$.complete();
    this.rewardsHistory$.complete();
    this.rewardAccountBalance$.complete();
    this.stakePoolStats$.complete();
  }

  reset() {
    this.currentWalletProtocolParameters$.next(CLEAN_FN_STATS);
    this.genesisParameters$.next(CLEAN_FN_STATS);
    this.ledgerTip$.next(CLEAN_FN_STATS);
    this.blocksByHashes$.next(CLEAN_FN_STATS);
    this.transactionsByAddresses$.next(CLEAN_FN_STATS);
    this.transactionsByHashes$.next(CLEAN_FN_STATS);
    this.rewardsHistory$.next(CLEAN_FN_STATS);
    this.rewardAccountBalance$.next(CLEAN_FN_STATS);
    this.stakePoolStats$.next(CLEAN_FN_STATS);
  }
  // Consider shutdown() completing all subjects:
  // might be needed in Wallet.shutdown() to not leak all stats subjects
}

/**
 * Wraps a WalletProvider, tracking # of calls of each function
 */
export class TrackedWalletProvider extends ProviderTracker implements WalletProvider {
  readonly stats = new WalletProviderStats();
  readonly stakePoolStats: WalletProvider['stakePoolStats'];
  readonly ledgerTip: WalletProvider['ledgerTip'];
  readonly rewardAccountBalance: WalletProvider['rewardAccountBalance'];
  readonly transactionsByAddresses: WalletProvider['transactionsByAddresses'];
  readonly transactionsByHashes: WalletProvider['transactionsByHashes'];
  readonly blocksByHashes: WalletProvider['blocksByHashes'];
  readonly currentWalletProtocolParameters: WalletProvider['currentWalletProtocolParameters'];
  readonly genesisParameters: WalletProvider['genesisParameters'];
  readonly rewardsHistory: WalletProvider['rewardsHistory'];

  constructor(walletProvider: WalletProvider) {
    super();
    walletProvider = walletProvider;

    this.stakePoolStats =
      typeof walletProvider.stakePoolStats !== 'undefined'
        ? () => this.trackedCall(walletProvider.stakePoolStats!, this.stats.stakePoolStats$)
        : undefined;
    this.ledgerTip = () => this.trackedCall(walletProvider.ledgerTip, this.stats.ledgerTip$);
    this.rewardAccountBalance = (rewardAccount) =>
      this.trackedCall(() => walletProvider.rewardAccountBalance(rewardAccount), this.stats.rewardAccountBalance$);
    this.transactionsByAddresses = (addresses) =>
      this.trackedCall(() => walletProvider.transactionsByAddresses(addresses), this.stats.transactionsByAddresses$);
    this.transactionsByHashes = (hashes) =>
      this.trackedCall(() => walletProvider.transactionsByHashes(hashes), this.stats.transactionsByHashes$);
    this.blocksByHashes = (hashes) =>
      this.trackedCall(() => walletProvider.blocksByHashes(hashes), this.stats.blocksByHashes$);
    this.currentWalletProtocolParameters = () =>
      this.trackedCall(walletProvider.currentWalletProtocolParameters, this.stats.currentWalletProtocolParameters$);
    this.genesisParameters = () => this.trackedCall(walletProvider.genesisParameters, this.stats.genesisParameters$);
    this.rewardsHistory = (props: RewardHistoryProps) =>
      this.trackedCall(() => walletProvider.rewardsHistory(props), this.stats.rewardsHistory$);
  }
}
