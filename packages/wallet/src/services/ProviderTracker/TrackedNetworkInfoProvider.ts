import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, ProviderTracker } from './ProviderTracker';
import { NetworkInfoProvider } from '@cardano-sdk/core';

export class NetworkInfoProviderStats {
  readonly networkInfo$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.networkInfo$.complete();
  }

  reset() {
    this.networkInfo$.next(CLEAN_FN_STATS);
  }
}

/**
 * Wraps a NetworkInfoProvider, tracking # of calls of each function
 */
export class TrackedNetworkInfoProvider extends ProviderTracker implements NetworkInfoProvider {
  readonly stats = new NetworkInfoProviderStats();
  readonly networkInfo: NetworkInfoProvider['networkInfo'];

  constructor(networkInfoProvider: NetworkInfoProvider) {
    super();
    networkInfoProvider = networkInfoProvider;

    this.networkInfo = () => this.trackedCall(networkInfoProvider.networkInfo, this.stats.networkInfo$);
  }
}
