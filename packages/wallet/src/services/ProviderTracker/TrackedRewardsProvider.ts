import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderTracker } from './ProviderTracker.js';
import type { ProviderFnStats } from './ProviderTracker.js';
import type { RewardsProvider } from '@cardano-sdk/core';

export class RewardsProviderStats {
  readonly healthCheck$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly rewardsHistory$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly rewardAccountBalance$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.healthCheck$.complete();
    this.rewardsHistory$.complete();
    this.rewardAccountBalance$.complete();
  }

  reset() {
    this.healthCheck$.next(CLEAN_FN_STATS);
    this.rewardsHistory$.next(CLEAN_FN_STATS);
    this.rewardAccountBalance$.next(CLEAN_FN_STATS);
  }
}

/** Wraps a RewardsProvider, tracking # of calls of each function */
export class TrackedRewardsProvider extends ProviderTracker implements RewardsProvider {
  readonly stats = new RewardsProviderStats();
  readonly healthCheck: RewardsProvider['healthCheck'];
  readonly rewardsHistory: RewardsProvider['rewardsHistory'];
  readonly rewardAccountBalance: RewardsProvider['rewardAccountBalance'];

  constructor(rewardsProvider: RewardsProvider) {
    super();
    rewardsProvider = rewardsProvider;

    this.healthCheck = () => this.trackedCall(() => rewardsProvider.healthCheck(), this.stats.healthCheck$);

    this.rewardsHistory = (fragments) =>
      this.trackedCall(() => rewardsProvider.rewardsHistory(fragments), this.stats.rewardsHistory$);

    this.rewardAccountBalance = (fragments) =>
      this.trackedCall(() => rewardsProvider.rewardAccountBalance(fragments), this.stats.rewardAccountBalance$);
  }
}
