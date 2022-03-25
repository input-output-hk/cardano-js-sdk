import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, ProviderTracker } from './ProviderTracker';
import { StakePoolSearchProvider } from '@cardano-sdk/core';

export class StakePoolSearchProviderStats {
  readonly queryStakePools$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.queryStakePools$.complete();
  }

  reset() {
    this.queryStakePools$.next(CLEAN_FN_STATS);
  }
}

/**
 * Wraps a StakePoolSearchProvider, tracking # of calls of each function
 */
export class TrackedStakePoolSearchProvider extends ProviderTracker implements StakePoolSearchProvider {
  readonly stats = new StakePoolSearchProviderStats();
  readonly queryStakePools: StakePoolSearchProvider['queryStakePools'];

  constructor(queryStakePoolsProvider: StakePoolSearchProvider) {
    super();
    queryStakePoolsProvider = queryStakePoolsProvider;

    this.queryStakePools = (fragments) =>
      this.trackedCall(() => queryStakePoolsProvider.queryStakePools(fragments), this.stats.queryStakePools$);
  }
}
