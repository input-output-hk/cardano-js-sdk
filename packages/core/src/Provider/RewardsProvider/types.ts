import { Cardano } from '../..';
import { Provider } from '../Provider';

export interface EpochRange {
  /**
   * Inclusive
   */
  lowerBound?: Cardano.EpochNo;
  /**
   * Inclusive
   */
  upperBound?: Cardano.EpochNo;
}

export interface EpochRewards {
  epoch: Cardano.EpochNo;
  rewards: Cardano.Lovelace;
}

export interface RewardHistoryProps {
  rewardAccounts: Cardano.RewardAccount[];
  epochs?: EpochRange;
}

export interface RewardsProvider extends Provider {
  /**
   * Query rewards history for provided stake addresses.
   *
   * @returns Rewards quantity for every epoch that had any rewards in ascending order.
   */
  rewardsHistory: (props: RewardHistoryProps) => Promise<Map<Cardano.RewardAccount, EpochRewards[]>>;
  rewardAccountBalance: (rewardAccount: Cardano.RewardAccount) => Promise<Cardano.Lovelace>;
}
