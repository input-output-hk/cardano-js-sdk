import { Cardano } from '../..';

export type ProtocolParametersRequiredByWallet = Required<
  Pick<
    Cardano.ProtocolParametersAlonzo,
    | 'coinsPerUtxoWord'
    | 'maxTxSize'
    | 'maxValueSize'
    | 'stakeKeyDeposit'
    | 'maxCollateralInputs'
    | 'minFeeCoefficient'
    | 'minFeeConstant'
    | 'minPoolCost'
    | 'poolDeposit'
    | 'protocolVersion'
  >
>;

export interface EpochRange {
  /**
   * Inclusive
   */
  lowerBound?: Cardano.Epoch;
  /**
   * Inclusive
   */
  upperBound?: Cardano.Epoch;
}

export interface RewardHistoryProps {
  rewardAccounts: Cardano.RewardAccount[];
  epochs?: EpochRange;
}

export interface EpochRewards {
  epoch: Cardano.Epoch;
  rewards: Cardano.Lovelace;
}

export interface WalletProvider {
  ledgerTip: () => Promise<Cardano.Tip>;
  currentWalletProtocolParameters: () => Promise<ProtocolParametersRequiredByWallet>;
  genesisParameters: () => Promise<Cardano.CompactGenesis>;
  /**
   * Query rewards history for provided stake addresses.
   *
   * @returns Rewards quantity for every epoch that had any rewards in ascending order.
   */
  rewardsHistory: (props: RewardHistoryProps) => Promise<Map<Cardano.RewardAccount, EpochRewards[]>>;
  rewardAccountBalance: (rewardAccount: Cardano.RewardAccount) => Promise<Cardano.Lovelace>;
}
