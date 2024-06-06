import {
  ProviderError,
  ProviderFailure,
  isPoolAPYSortField,
  isPoolDataSortField,
  isPoolMetricsSortField,
  isPoolROSSortField
} from '@cardano-sdk/core';
import BigNumber from 'bignumber.js';
import type { PoolSortType } from './types.js';

export const APY_EPOCHS_BACK_LIMIT_DEFAULT = 3;

export const getStakePoolSortType = (field: string): PoolSortType => {
  if (isPoolDataSortField(field)) return 'data';
  if (isPoolMetricsSortField(field)) return 'metrics';
  if (isPoolAPYSortField(field)) return 'apy';
  if (isPoolROSSortField(field)) return 'ros';
  throw new ProviderError(ProviderFailure.Unknown, null, `Invalid sort field "${field}"`);
};

export const QUERIES_NAMESPACE = 'StakePoolQueries';
export const IDS_NAMESPACE = 'StakePoolIds';
export const LIVE_STAKE_CACHE_KEY = 'StakePoolLiveStake';

export enum StakePoolsSubQuery {
  APY = 'apy',
  STATS = 'stats',
  METRICS = 'metrics',
  REWARDS = 'rewards',
  RELAYS = 'relays',
  REGISTRATIONS = 'registrations',
  OWNERS = 'owners',
  RETIREMENTS = 'retirements',
  TOTAL_STAKE = 'total_stake',
  POOL_HASHES = 'pool_hashes',
  POOLS_DATA_ORDERED = 'pools_data_ordered'
}

export const queryCacheKey = (queryName: StakePoolsSubQuery, ...args: unknown[]) =>
  `${QUERIES_NAMESPACE}/${queryName}/${JSON.stringify(args)}`;

export const emptyPoolsExtraInfo = {
  poolMetrics: [],
  poolOwners: [],
  poolRegistrations: [],
  poolRelays: [],
  poolRetirements: [],
  poolRewards: []
};

export const divideBigIntToFloat = (numerator: bigint, denominator: bigint) =>
  new BigNumber(numerator.toString()).dividedBy(new BigNumber(denominator.toString())).toString();
