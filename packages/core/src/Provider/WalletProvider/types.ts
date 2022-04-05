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

export type AssetSupply = {
  circulating: Cardano.Lovelace;
  max: Cardano.Lovelace;
  total: Cardano.Lovelace;
};

export type StakeSummary = {
  active: Cardano.Lovelace;
  live: Cardano.Lovelace;
};

export type StakePoolStats = {
  qty: {
    active: number;
    retired: number;
    retiring: number;
  };
};

export type NetworkInfo = {
  currentEpoch: {
    number: Cardano.Epoch;
    start: {
      /** Local date */
      date: Date;
    };
    end: {
      /** Local date */
      date: Date;
    };
  };
  lovelaceSupply: AssetSupply;
  stake: StakeSummary;
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
  networkInfo: () => Promise<NetworkInfo>;
  // TODO: move stakePoolStats out to other provider type, since it's not required for wallet operation
  stakePoolStats?: () => Promise<StakePoolStats>;
  utxoDelegationAndRewards: (
    addresses: Cardano.Address[],
    rewardAccount?: Cardano.RewardAccount
  ) => Promise<{ utxo: Cardano.Utxo[]; delegationAndRewards?: Cardano.DelegationsAndRewards }>;
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
}
