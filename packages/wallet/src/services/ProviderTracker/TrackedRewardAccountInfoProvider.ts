import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, ProviderTracker } from './ProviderTracker';
import { RewardAccountInfoProvider } from '@cardano-sdk/core';

export class RewardAccountInfoProviderStats {
  readonly healthCheck$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly rewardAccountInfo$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly delegationPortfolio$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.healthCheck$.complete();
    this.rewardAccountInfo$.complete();
    this.delegationPortfolio$.complete();
  }

  reset() {
    this.healthCheck$.next(CLEAN_FN_STATS);
    this.rewardAccountInfo$.next(CLEAN_FN_STATS);
    this.delegationPortfolio$.next(CLEAN_FN_STATS);
  }
}

/** Wraps a RewardAccountInfoProvider, tracking # of calls of each function */
export class TrackedRewardAccountInfoProvider extends ProviderTracker implements RewardAccountInfoProvider {
  readonly stats = new RewardAccountInfoProviderStats();
  readonly healthCheck: RewardAccountInfoProvider['healthCheck'];
  readonly rewardAccountInfo: RewardAccountInfoProvider['rewardAccountInfo'];
  readonly delegationPortfolio: RewardAccountInfoProvider['delegationPortfolio'];

  constructor(rewardAccountInfoProvider: RewardAccountInfoProvider) {
    super();

    this.healthCheck = () => this.trackedCall(() => rewardAccountInfoProvider.healthCheck(), this.stats.healthCheck$);

    this.rewardAccountInfo = (rewardAccount, localEpoch) =>
      this.trackedCall(
        () => rewardAccountInfoProvider.rewardAccountInfo(rewardAccount, localEpoch),
        this.stats.rewardAccountInfo$
      );

    this.delegationPortfolio = (rewardAccount) =>
      this.trackedCall(
        () => rewardAccountInfoProvider.delegationPortfolio(rewardAccount),
        this.stats.delegationPortfolio$
      );
  }
}
