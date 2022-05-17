import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, ProviderTracker } from './ProviderTracker';
import { StakePoolProvider } from '@cardano-sdk/core';

export class StakePoolProviderStats {
  readonly queryStakePools$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.queryStakePools$.complete();
  }

  reset() {
    this.queryStakePools$.next(CLEAN_FN_STATS);
  }
}

/**
 * Wraps a StakePoolProvider, tracking # of calls of each function
 */
export class TrackedStakePoolProvider extends ProviderTracker implements StakePoolProvider {
  readonly stats = new StakePoolProviderStats();
  readonly queryStakePools: StakePoolProvider['queryStakePools'];

  constructor(queryStakePoolsProvider: StakePoolProvider) {
    super();
    queryStakePoolsProvider = queryStakePoolsProvider;

    this.queryStakePools = (fragments) =>
      this.trackedCall(() => queryStakePoolsProvider.queryStakePools(fragments), this.stats.queryStakePools$);
  }
}
