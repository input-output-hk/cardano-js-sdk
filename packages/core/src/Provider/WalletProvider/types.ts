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

export type StakePoolStats = {
  qty: {
    active: number;
    retired: number;
    retiring: number;
  };
};

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
  // TODO: when implementing db-sync provider,
  // move stakePoolStats out to other provider type, since it's not required for wallet operation.
  // Perhaps generalize StakePoolSearchProvider?
  stakePoolStats?: () => Promise<StakePoolStats>;
  /**
   * @param {Cardano.BlockNo} sinceBlock inclusive
   */
  transactionsByAddresses: (addresses: Cardano.Address[], sinceBlock?: Cardano.BlockNo) => Promise<Cardano.TxAlonzo[]>;
  transactionsByHashes: (hashes: Cardano.TransactionId[]) => Promise<Cardano.TxAlonzo[]>;
  /**
   * @returns an array of blocks, same length and in the same order as `hashes` argument.
   */
  blocksByHashes: (hashes: Cardano.BlockId[]) => Promise<Cardano.Block[]>;
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
