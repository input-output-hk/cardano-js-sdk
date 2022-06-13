import { Cardano } from '@cardano-sdk/core';
export interface PoolUpdateModel {
  id: number; // pool hash id
  update_id: number;
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
  metadata?: Cardano.StakePoolMetadataFields; // TODO: check for Cip6MetadataFields & ExtendedStakePoolMetadata
  updateId: number;
  vrfKeyHash: Cardano.VrfVkHex;
}

export interface PoolDataModel {
  hash_id: number;
  update_id: number;
  pool_id: string;
  reward_address: string;
  pledge: string;
  fixed_cost: string;
  margin: string;
  vrf_key_hash: Buffer;
  metadata_url: string;
  metadata_hash: Buffer;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  offline_data: any;
  pool_hash: Buffer;
}

export interface RelayModel {
  hash_id: number;
  update_id: number;
  ipv4?: string;
  ipv6?: string;
  port?: number;
  dns_name?: string;
  hostname?: string;
}

export interface EpochModel {
  no: number;
}

export interface EpochReward {
  hashId: number;
  epochReward: Cardano.StakePoolEpochRewards;
}

export interface EpochRewardModel {
  epoch_no: number;
  epoch_length: string;
  operator_fees: string;
  active_stake: string;
  member_roi: number;
  total_rewards: string;
}

export interface OwnerAddressModel {
  address: string;
  hash_id: number;
}

interface PoolTransactionModel {
  tx_hash: Buffer;
  hash_id: number;
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

export interface TotalAdaModel {
  total_ada: string;
}

export interface PoolMetricsModel {
  blocks_created: number;
  delegators: number;
  active_stake: string;
  live_stake: string;
  live_pledge: string;
  saturation: number;
  active_stake_percentage: number;
  live_stake_percentage: number;
  pool_hash_id: number;
}

export interface PoolMetrics extends CommonPoolInfo {
  metrics: Omit<Cardano.StakePoolMetrics, 'apy'>;
}

export interface TotalCountModel {
  total_count: number;
}

export interface StakePoolStatsModel {
  active: string;
  retired: string;
  retiring: string;
}

export interface PoolAPYModel {
  hash_id: number;
  apy: number;
}

export interface PoolAPY extends CommonPoolInfo {
  apy: number;
}

export type PoolSortType = 'data' | 'metrics' | 'apy';
export interface OrderByOptions {
  field: string;
  order: 'asc' | 'desc';
}
