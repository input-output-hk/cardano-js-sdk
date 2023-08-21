import { Cardano } from '../..';
import { Provider } from '../Provider';
import { Range } from '@cardano-sdk/util';

export interface Reward {
  epoch: Cardano.EpochNo;
  rewards: Cardano.Lovelace;
  /**
   * The pool the stake address was delegated to when the reward is earned.
   * Will be undefined for payments from the treasury or the reserves.
   */
  poolId?: Cardano.PoolId;
}

export interface RewardsHistoryArgs {
  rewardAccounts: Cardano.RewardAccount[];
  epochs?: Range<Cardano.EpochNo>;
}
export interface RewardAccountBalanceArgs {
  rewardAccount: Cardano.RewardAccount;
}

export interface RewardsProvider extends Provider {
  /**
   * Query rewards history for provided stake addresses.
   *
   * @returns Rewards quantity for every epoch that had any rewards in ascending order.
   */
  rewardsHistory: (args: RewardsHistoryArgs) => Promise<Map<Cardano.RewardAccount, Reward[]>>;
  rewardAccountBalance: (args: RewardAccountBalanceArgs) => Promise<Cardano.Lovelace>;
}
