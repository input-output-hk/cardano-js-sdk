import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, ProviderTracker } from './ProviderTracker';
import { WalletNetworkInfoProvider } from '../../types';

export class WalletNetworkInfoProviderStats {
  readonly eraSummaries$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly protocolParameters$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly genesisParameters$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly ledgerTip$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.eraSummaries$.complete();
    this.protocolParameters$.complete();
    this.genesisParameters$.complete();
    this.ledgerTip$.complete();
  }

  reset() {
    this.eraSummaries$.next(CLEAN_FN_STATS);
    this.protocolParameters$.next(CLEAN_FN_STATS);
    this.genesisParameters$.next(CLEAN_FN_STATS);
    this.ledgerTip$.next(CLEAN_FN_STATS);
  }
}

/** Wraps a WalletNetworkInfoProvider, tracking # of calls of each function */
export class TrackedWalletNetworkInfoProvider extends ProviderTracker implements WalletNetworkInfoProvider {
  readonly stats = new WalletNetworkInfoProviderStats();
  readonly eraSummaries: WalletNetworkInfoProvider['eraSummaries'];
  readonly ledgerTip: WalletNetworkInfoProvider['ledgerTip'];
  readonly protocolParameters: WalletNetworkInfoProvider['protocolParameters'];
  readonly genesisParameters: WalletNetworkInfoProvider['genesisParameters'];

  constructor(networkInfoProvider: WalletNetworkInfoProvider) {
    super();
    networkInfoProvider = networkInfoProvider;

    this.eraSummaries = () => this.trackedCall(networkInfoProvider.eraSummaries, this.stats.eraSummaries$);
    this.ledgerTip = () => this.trackedCall(networkInfoProvider.ledgerTip, this.stats.ledgerTip$);
    this.protocolParameters = () =>
      this.trackedCall(networkInfoProvider.protocolParameters, this.stats.protocolParameters$);
    this.genesisParameters = () =>
      this.trackedCall(networkInfoProvider.genesisParameters, this.stats.genesisParameters$);
  }
}
