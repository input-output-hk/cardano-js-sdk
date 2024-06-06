import type { Cardano, Paginated, QueryStakePoolsArgs } from '@cardano-sdk/core';
import type { Percent } from '@cardano-sdk/util';
export interface PoolUpdateModel {
  id: string; // pool hash id
  update_id: string;
}

export interface PoolUpdate {
  id: number;
  updateId: number;
}

export interface CommonPoolInfo {
  hashId: number;
}

export interface PoolData extends CommonPoolInfo {
  hexId: Cardano.PoolIdHex;
  id: Cardano.PoolId;
  rewardAccount: Cardano.RewardAccount;
  pledge: bigint;
  cost: bigint;
  margin: Cardano.Fraction;
  metadataJson?: Cardano.PoolMetadataJson;
  metadata?: Cardano.StakePoolMetadata;
  updateId: number;
  vrfKeyHash: Cardano.VrfVkHex;
}

export interface PoolDataModel {
  hash_id: string;
  update_id: string;
  pool_id: string;
  reward_address: string;
  pledge: string;
  fixed_cost: string;
  margin: string;
  vrf_key_hash: Buffer;
  metadata_url: string;
  metadata_hash: Buffer;
  // Extended metadata is attached at a later stage after it has been fetched from ext data url. It could be CIP-6 or AP format
  offline_data: Omit<Cardano.StakePoolMetadata, 'ext'>;
  pool_hash: Buffer;
}

export interface RelayModel {
  hash_id: string;
  update_id: string;
  ipv4?: string;
  ipv6?: string;
  port?: number;
  dns_name?: string;
  hostname?: string;
}

export interface Epoch {
  no: number;
  optimalPoolCount?: number;
}

export interface EpochModel {
  no: number;
  optimal_pool_count?: number;
}

export interface OwnerAddressModel {
  address: string;
  hash_id: string;
}

interface PoolTransactionModel {
  tx_hash: Buffer;
  hash_id: string;
}

interface PoolTransaction extends CommonPoolInfo {
  transactionId: Cardano.TransactionId;
}

export interface PoolOwner extends CommonPoolInfo {
  address: Cardano.RewardAccount;
}

export interface PoolRelay extends CommonPoolInfo {
  relay: Cardano.Relay;
  updateId: number;
}

export interface PoolRetirementModel extends PoolTransactionModel {
  retiring_epoch: number;
}

export interface PoolRegistrationModel extends PoolTransactionModel {
  active_epoch_no: number;
}

export interface PoolRetirement extends PoolTransaction {
  retiringEpoch: number;
}

export interface PoolRegistration extends PoolTransaction {
  activeEpochNo: number;
}

export interface SubQuery {
  id: { name: string; isPrimary?: boolean };
  query: string;
}

export interface PoolMetricsModel {
  blocks_created: number;
  delegators: number;
  active_stake: string;
  live_stake: string;
  live_pledge: string;
  saturation: string;
  active_stake_percentage: number;
  live_stake_percentage: number;
  pool_hash_id: string;
}

export interface BlockfrostPoolMetricsModel extends PoolMetricsModel {
  reward_address: string;
  extra: string;
  status: string;
}

export interface PoolMetrics extends CommonPoolInfo {
  metrics: {
    blocksCreated: number;
    livePledge: Cardano.Lovelace;
    activeStake: Cardano.Lovelace;
    liveStake: Cardano.Lovelace;
    activeStakePercentage: Percent;
    saturation: Percent;
    delegators: number;
    lastRos: Percent;
    ros: Percent;
  };
}

export interface BlockfrostPoolMetrics extends PoolMetrics {
  rewardAccount: Cardano.RewardAccount;
  owners: Cardano.RewardAccount[];
  registration: Cardano.TransactionId[];
  retirement: Cardano.TransactionId[];
  status: Cardano.StakePoolStatus;
}

export interface StakePoolStatsModel {
  active: string;
  retired: string;
  retiring: string;
}

export interface PoolAPYModel {
  hash_id: string;
  apy: number;
}

export interface PoolAPY extends CommonPoolInfo {
  apy: number;
}

export type PoolSortType = 'apy' | 'data' | 'metrics' | 'ros';
export interface OrderByOptions {
  field: string;
  order: 'asc' | 'desc';
}

export type THashId = number;
export type TUpdateId = number;
export type PoolIdsMap = Record<THashId, TUpdateId>;

export type HashIdStakePoolMap = Record<THashId, Cardano.StakePool | undefined>;

export type OrderedResult = PoolMetrics[] | PoolData[] | PoolAPY[];

export type PoolsToCache = { [hashId: THashId]: Cardano.StakePool };

export type StakePoolResults = {
  results: Paginated<Cardano.StakePool>;
  poolsToCache: PoolsToCache;
};

export type QueryPoolsApyArgs = Partial<QueryStakePoolsArgs>;
