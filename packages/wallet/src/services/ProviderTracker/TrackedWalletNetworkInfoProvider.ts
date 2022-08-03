/* eslint-disable brace-style */
import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, ProviderTracker } from './ProviderTracker';
import { WalletNetworkInfoProvider } from '../../types';

export class WalletNetworkInfoProviderStats {
  readonly timeSettings$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly currentWalletProtocolParameters$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly genesisParameters$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly ledgerTip$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.timeSettings$.complete();
    this.currentWalletProtocolParameters$.complete();
    this.genesisParameters$.complete();
    this.ledgerTip$.complete();
  }

  reset() {
    this.timeSettings$.next(CLEAN_FN_STATS);
    this.currentWalletProtocolParameters$.next(CLEAN_FN_STATS);
    this.genesisParameters$.next(CLEAN_FN_STATS);
    this.ledgerTip$.next(CLEAN_FN_STATS);
  }
}

/**
 * Wraps a WalletNetworkInfoProvider, tracking # of calls of each function
 */
export class TrackedWalletNetworkInfoProvider extends ProviderTracker implements WalletNetworkInfoProvider {
  readonly stats = new WalletNetworkInfoProviderStats();
  readonly timeSettings: WalletNetworkInfoProvider['timeSettings'];
  readonly ledgerTip: WalletNetworkInfoProvider['ledgerTip'];
  readonly currentWalletProtocolParameters: WalletNetworkInfoProvider['currentWalletProtocolParameters'];
  readonly genesisParameters: WalletNetworkInfoProvider['genesisParameters'];

  constructor(networkInfoProvider: WalletNetworkInfoProvider) {
    super();
    networkInfoProvider = networkInfoProvider;

    this.timeSettings = () => this.trackedCall(networkInfoProvider.timeSettings, this.stats.timeSettings$);
    this.ledgerTip = () => this.trackedCall(networkInfoProvider.ledgerTip, this.stats.ledgerTip$);
    this.currentWalletProtocolParameters = () =>
      this.trackedCall(
        networkInfoProvider.currentWalletProtocolParameters,
        this.stats.currentWalletProtocolParameters$
      );
    this.genesisParameters = () =>
      this.trackedCall(networkInfoProvider.genesisParameters, this.stats.genesisParameters$);
  }
}
