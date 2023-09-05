import { Cardano, Paginated } from '@cardano-sdk/core';
import { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import { Percent, isNotNil } from '@cardano-sdk/util';
import { RelayModel, mapRelay } from '../DbSyncStakePoolProvider';

export type Margin = {
  numerator: number;
  denominator: number;
};

export type PoolModel = {
  pool_id: string;
  pool_status: string;
  params_pledge: string;
  params_cost: string;
  params_margin: Margin;
  params_relays: RelayModel[];
  params_owners: string[];
  params_vrf: string;
  params_reward_account: string;
  params_metadata_url: string | null;
  params_metadata_hash: string | null;
  metadata_ticker: string | null;
  metadata_name: string | null;
  metadata_homepage: string | null;
  metadata_description: string | null;
  metadata_ext: JSON | null;
  metrics_minted_blocks: number;
  metrics_live_delegators: number;
  metrics_active_stake: string;
  metrics_live_stake: string;
  metrics_active_size: string;
  metrics_live_size: string;
  metrics_live_saturation: string;
  metrics_live_pledge: string;
  metrics_apy: string | null;
  total_count: string;
};

export type PoolStatsModel = {
  status: string;
  count: number;
};

export type PoolStats = {
  activating: number;
  active: number;
  retiring: number;
  retired: number;
};

export type SortOrder = 'ASC' | 'DESC' | undefined;

const mapMetadataJson = ({
  params_metadata_url,
  params_metadata_hash
}: PoolModel): Cardano.PoolMetadataJson | undefined => {
  if (params_metadata_url && params_metadata_hash) {
    return {
      hash: params_metadata_hash as Hash32ByteBase16,
      url: params_metadata_url
    };
  }
};

const mapMetadata = ({
  metadata_name,
  metadata_ticker,
  metadata_homepage,
  metadata_description
}: PoolModel): Cardano.StakePoolMetadata | undefined => {
  if (
    isNotNil(metadata_name) &&
    isNotNil(metadata_ticker) &&
    isNotNil(metadata_description) &&
    isNotNil(metadata_homepage)
  ) {
    return {
      description: metadata_description,
      homepage: metadata_homepage,
      name: metadata_name,
      ticker: metadata_ticker
    };
  }
};

// Following our generated db snapshot - we could have a stake pool with no associated metrics in the projection db, however Cardano.StakePool.metrics is a required
const defaultMetrics: Cardano.StakePoolMetrics = {
  apy: undefined,
  blocksCreated: 0,
  delegators: 0,
  livePledge: 0n,
  saturation: Percent(0),
  size: {
    active: Percent(0),
    live: Percent(0)
  },
  stake: {
    active: 0n,
    live: 0n
  }
};

const mapMetrics = (pool: PoolModel): Cardano.StakePoolMetrics => {
  if (pool.metrics_live_pledge === null) return defaultMetrics;

  return {
    apy: pool.metrics_apy ? Percent(Number.parseFloat(pool.metrics_apy)) : undefined,
    blocksCreated: pool.metrics_minted_blocks,
    delegators: pool.metrics_live_delegators,
    livePledge: BigInt(pool.metrics_live_pledge),
    saturation: Percent(Number.parseFloat(pool.metrics_live_saturation)),
    size: {
      active: Percent(Number.parseFloat(pool.metrics_active_size)),
      live: Percent(Number.parseFloat(pool.metrics_live_size))
    },
    stake: {
      active: BigInt(pool.metrics_active_stake),
      live: BigInt(pool.metrics_live_stake)
    }
  };
};

export const mapStakePoolsResult = (rawResult: PoolModel[]): Paginated<Cardano.StakePool> => {
  const pageResults: Cardano.StakePool[] = rawResult.map((poolModel) => ({
    cost: BigInt(poolModel.params_cost),
    hexId: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolModel.pool_id as Cardano.PoolId)),
    id: Cardano.PoolId(poolModel.pool_id),
    margin: {
      denominator: Number(poolModel.params_margin.denominator),
      numerator: Number(poolModel.params_margin.numerator)
    } as Cardano.Fraction,
    metadata: mapMetadata(poolModel),
    metadataJson: mapMetadataJson(poolModel),
    metrics: mapMetrics(poolModel),
    owners: poolModel.params_owners as Cardano.RewardAccount[],
    pledge: BigInt(poolModel.params_pledge),
    relays: poolModel.params_relays.map(mapRelay).map((r) => r.relay),
    rewardAccount: Cardano.RewardAccount(poolModel.params_reward_account),
    status: poolModel.pool_status as Cardano.StakePoolStatus,
    vrf: poolModel.params_vrf as Cardano.VrfVkHex
  }));

  return {
    pageResults,
    totalResultCount: rawResult.length > 0 ? Number(rawResult[0].total_count) : 0
  };
};

export const mapPoolStats = (rawResult: PoolStatsModel[]): PoolStats => {
  const result = rawResult.reduce(
    (acc, curr) => (acc = { ...acc, [curr.status]: Number(curr.count) }),
    {} as PoolStats
  );
  for (const status of Object.values(Cardano.StakePoolStatus)) {
    if (!(status in result)) {
      result[status] = 0;
    }
  }
  return result;
};
