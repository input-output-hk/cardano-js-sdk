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
  stakeAddresses: Cardano.RewardAccount[];
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
  // TODO: split utxoDelegationAndRewards this into 2 or 3 functions
  utxoDelegationAndRewards: (
    addresses: Cardano.Address[],
    rewardAccount?: Cardano.RewardAccount
  ) => Promise<{ utxo: Cardano.Utxo[]; delegationAndRewards?: Cardano.DelegationsAndRewards }>;
  /**
   * TODO: add an optional 'since: Slot' argument for querying transactions and utxos.
   * When doing so we need to also consider how best we can use the volatile block range of the chain
   * to minimise over-fetching and assist the application in handling rollback scenarios.
   */
  queryTransactionsByAddresses: (addresses: Cardano.Address[]) => Promise<Cardano.TxAlonzo[]>;
  queryTransactionsByHashes: (hashes: Cardano.TransactionId[]) => Promise<Cardano.TxAlonzo[]>;
  /**
   * @returns an array of blocks, same length and in the same order as `hashes` argument.
   */
  queryBlocksByHashes: (hashes: Cardano.BlockId[]) => Promise<Cardano.Block[]>;
  currentWalletProtocolParameters: () => Promise<ProtocolParametersRequiredByWallet>;
  genesisParameters: () => Promise<Cardano.CompactGenesis>;
  /**
   * Query rewards history for provided stake addresses.
   *
   * @returns Rewards quantity for every epoch that had any rewards in ascending order.
   */
  rewardsHistory: (props: RewardHistoryProps) => Promise<EpochRewards[]>;
}
