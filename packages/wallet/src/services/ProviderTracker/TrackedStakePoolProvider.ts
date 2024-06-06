import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderTracker } from './ProviderTracker.js';
import type { ProviderFnStats } from './ProviderTracker.js';
import type { StakePoolProvider } from '@cardano-sdk/core';

export class StakePoolProviderStats {
  readonly healthCheck$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly queryStakePools$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly stakePoolStats$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.healthCheck$.complete();
    this.queryStakePools$.complete();
    this.stakePoolStats$.complete();
  }

  reset() {
    this.healthCheck$.next(CLEAN_FN_STATS);
    this.queryStakePools$.next(CLEAN_FN_STATS);
    this.stakePoolStats$.next(CLEAN_FN_STATS);
  }
}

/** Wraps a StakePoolProvider, tracking # of calls of each function */
export class TrackedStakePoolProvider extends ProviderTracker implements StakePoolProvider {
  readonly stats = new StakePoolProviderStats();
  readonly healthCheck: StakePoolProvider['healthCheck'];
  readonly queryStakePools: StakePoolProvider['queryStakePools'];
  readonly stakePoolStats: StakePoolProvider['stakePoolStats'];

  constructor(queryStakePoolsProvider: StakePoolProvider) {
    super();
    queryStakePoolsProvider = queryStakePoolsProvider;

    this.healthCheck = () => this.trackedCall(() => queryStakePoolsProvider.healthCheck(), this.stats.healthCheck$);

    this.queryStakePools = (fragments) =>
      this.trackedCall(() => queryStakePoolsProvider.queryStakePools(fragments), this.stats.queryStakePools$);

    this.stakePoolStats = () =>
      this.trackedCall(() => queryStakePoolsProvider.stakePoolStats(), this.stats.stakePoolStats$);
  }
}
