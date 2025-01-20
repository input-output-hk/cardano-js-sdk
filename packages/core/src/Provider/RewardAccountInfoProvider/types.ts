import { Cardano, Provider } from '../..';

export interface RewardAccountInfoProvider extends Provider {
  rewardAccountInfo(
    rewardAccount: Cardano.RewardAccount,
    localEpoch: Cardano.EpochNo
  ): Promise<Cardano.RewardAccountInfo>;
  delegationPortfolio(rewardAccounts: Cardano.RewardAccount): Promise<Cardano.Cip17DelegationPortfolio | null>;
}
