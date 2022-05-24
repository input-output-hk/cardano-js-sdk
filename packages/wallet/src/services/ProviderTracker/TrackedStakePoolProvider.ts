import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, ProviderTracker } from './ProviderTracker';
import { StakePoolProvider } from '@cardano-sdk/core';

export class StakePoolProviderStats {
  readonly queryStakePools$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly stakePoolStats$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.queryStakePools$.complete();
    this.stakePoolStats$.complete();
  }

  reset() {
    this.queryStakePools$.next(CLEAN_FN_STATS);
    this.stakePoolStats$.next(CLEAN_FN_STATS);
  }
}

/**
 * Wraps a StakePoolProvider, tracking # of calls of each function
 */
export class TrackedStakePoolProvider extends ProviderTracker implements StakePoolProvider {
  readonly stats = new StakePoolProviderStats();
  readonly queryStakePools: StakePoolProvider['queryStakePools'];
  readonly stakePoolStats: StakePoolProvider['stakePoolStats'];

  constructor(queryStakePoolsProvider: StakePoolProvider) {
    super();
    queryStakePoolsProvider = queryStakePoolsProvider;

    this.queryStakePools = (fragments) =>
      this.trackedCall(() => queryStakePoolsProvider.queryStakePools(fragments), this.stats.queryStakePools$);

    this.stakePoolStats = () =>
      this.trackedCall(() => queryStakePoolsProvider.stakePoolStats(), this.stats.stakePoolStats$);
  }
}
