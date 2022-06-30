import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, ProviderTracker } from './ProviderTracker';
import { WC } from '../../types';

export class NetworkInfoProviderStats {
  readonly stake$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly lovelaceSupply$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly timeSettings$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly currentWalletProtocolParameters$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly genesisParameters$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly ledgerTip$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.stake$.complete();
    this.lovelaceSupply$.complete();
    this.timeSettings$.complete();
    this.currentWalletProtocolParameters$.complete();
    this.genesisParameters$.complete();
    this.ledgerTip$.complete();
  }

  reset() {
    this.stake$.next(CLEAN_FN_STATS);
    this.lovelaceSupply$.next(CLEAN_FN_STATS);
    this.timeSettings$.next(CLEAN_FN_STATS);
    this.currentWalletProtocolParameters$.next(CLEAN_FN_STATS);
    this.genesisParameters$.next(CLEAN_FN_STATS);
    this.ledgerTip$.next(CLEAN_FN_STATS);
  }
}

/**
 * Wraps a NetworkInfoProvider, tracking # of calls of each function
 */
export class TrackedNetworkInfoProvider extends ProviderTracker implements WC.NetworkInfoProvider {
  readonly stats = new NetworkInfoProviderStats();
  readonly stake: WC.NetworkInfoProvider['stake'];
  readonly lovelaceSupply: WC.NetworkInfoProvider['lovelaceSupply'];
  readonly timeSettings: WC.NetworkInfoProvider['timeSettings'];
  readonly ledgerTip: WC.NetworkInfoProvider['ledgerTip'];
  readonly currentWalletProtocolParameters: WC.NetworkInfoProvider['currentWalletProtocolParameters'];
  readonly genesisParameters: WC.NetworkInfoProvider['genesisParameters'];

  constructor(networkInfoProvider: WC.NetworkInfoProvider) {
    super();
    networkInfoProvider = networkInfoProvider;

    this.stake = () => this.trackedCall(networkInfoProvider.stake, this.stats.stake$);
    this.lovelaceSupply = () => this.trackedCall(networkInfoProvider.lovelaceSupply, this.stats.lovelaceSupply$);
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
