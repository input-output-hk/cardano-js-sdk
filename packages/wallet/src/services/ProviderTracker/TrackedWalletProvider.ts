import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, ProviderTracker } from './ProviderTracker';
import { WalletProvider } from '@cardano-sdk/core';

export class WalletProviderStats {
  readonly currentWalletProtocolParameters$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly genesisParameters$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly ledgerTip$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly rewardsHistory$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly rewardAccountBalance$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly stakePoolStats$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.currentWalletProtocolParameters$.complete();
    this.genesisParameters$.complete();
    this.ledgerTip$.complete();
    this.rewardsHistory$.complete();
    this.rewardAccountBalance$.complete();
    this.stakePoolStats$.complete();
  }

  reset() {
    this.currentWalletProtocolParameters$.next(CLEAN_FN_STATS);
    this.genesisParameters$.next(CLEAN_FN_STATS);
    this.ledgerTip$.next(CLEAN_FN_STATS);
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
  readonly ledgerTip: WalletProvider['ledgerTip'];
  readonly currentWalletProtocolParameters: WalletProvider['currentWalletProtocolParameters'];
  readonly genesisParameters: WalletProvider['genesisParameters'];

  constructor(walletProvider: WalletProvider) {
    super();
    walletProvider = walletProvider;

    this.ledgerTip = () => this.trackedCall(walletProvider.ledgerTip, this.stats.ledgerTip$);
    this.currentWalletProtocolParameters = () =>
      this.trackedCall(walletProvider.currentWalletProtocolParameters, this.stats.currentWalletProtocolParameters$);
    this.genesisParameters = () => this.trackedCall(walletProvider.genesisParameters, this.stats.genesisParameters$);
  }
}
