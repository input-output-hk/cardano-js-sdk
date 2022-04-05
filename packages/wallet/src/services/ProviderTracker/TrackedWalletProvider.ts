import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, ProviderTracker } from './ProviderTracker';
import { RewardHistoryProps, WalletProvider } from '@cardano-sdk/core';

export class WalletProviderStats {
  readonly currentWalletProtocolParameters$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly genesisParameters$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly ledgerTip$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly networkInfo$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly queryBlocksByHashes$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly queryTransactionsByAddresses$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly queryTransactionsByHashes$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly rewardsHistory$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly utxoDelegationAndRewards$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly stakePoolStats$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.currentWalletProtocolParameters$.complete();
    this.genesisParameters$.complete();
    this.ledgerTip$.complete();
    this.networkInfo$.complete();
    this.queryBlocksByHashes$.complete();
    this.queryTransactionsByAddresses$.complete();
    this.queryTransactionsByHashes$.complete();
    this.rewardsHistory$.complete();
    this.utxoDelegationAndRewards$.complete();
    this.stakePoolStats$.complete();
  }

  reset() {
    this.currentWalletProtocolParameters$.next(CLEAN_FN_STATS);
    this.genesisParameters$.next(CLEAN_FN_STATS);
    this.ledgerTip$.next(CLEAN_FN_STATS);
    this.networkInfo$.next(CLEAN_FN_STATS);
    this.queryBlocksByHashes$.next(CLEAN_FN_STATS);
    this.queryTransactionsByAddresses$.next(CLEAN_FN_STATS);
    this.queryTransactionsByHashes$.next(CLEAN_FN_STATS);
    this.rewardsHistory$.next(CLEAN_FN_STATS);
    this.utxoDelegationAndRewards$.next(CLEAN_FN_STATS);
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
  readonly networkInfo: WalletProvider['networkInfo'];
  readonly utxoDelegationAndRewards: WalletProvider['utxoDelegationAndRewards'];
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
    this.networkInfo = () => this.trackedCall(walletProvider.networkInfo, this.stats.networkInfo$);
    this.utxoDelegationAndRewards = (addresses, rewardAccount) =>
      this.trackedCall(
        () => walletProvider.utxoDelegationAndRewards(addresses, rewardAccount),
        this.stats.utxoDelegationAndRewards$
      );
    this.transactionsByAddresses = (addresses) =>
      this.trackedCall(
        () => walletProvider.transactionsByAddresses(addresses),
        this.stats.queryTransactionsByAddresses$
      );
    this.transactionsByHashes = (hashes) =>
      this.trackedCall(() => walletProvider.transactionsByHashes(hashes), this.stats.queryTransactionsByHashes$);
    this.blocksByHashes = (hashes) =>
      this.trackedCall(() => walletProvider.blocksByHashes(hashes), this.stats.queryBlocksByHashes$);
    this.currentWalletProtocolParameters = () =>
      this.trackedCall(walletProvider.currentWalletProtocolParameters, this.stats.currentWalletProtocolParameters$);
    this.genesisParameters = () => this.trackedCall(walletProvider.genesisParameters, this.stats.genesisParameters$);
    this.rewardsHistory = (props: RewardHistoryProps) =>
      this.trackedCall(() => walletProvider.rewardsHistory(props), this.stats.rewardsHistory$);
  }
}
