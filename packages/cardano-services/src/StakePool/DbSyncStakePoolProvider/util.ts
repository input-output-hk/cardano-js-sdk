import { PoolSortType } from './types';
import {
  ProviderError,
  ProviderFailure,
  isPoolAPYSortField,
  isPoolDataSortField,
  isPoolMetricsSortField
} from '@cardano-sdk/core';

export const getStakePoolSortType = (field: string): PoolSortType => {
  if (isPoolDataSortField(field)) return 'data';
  if (isPoolMetricsSortField(field)) return 'metrics';
  if (isPoolAPYSortField(field)) return 'apy';
  throw new ProviderError(ProviderFailure.Unknown, null, 'Invalid sort field');
};

export const QUERIES_NAMESPACE = 'StakePoolQueries';
export const IDS_NAMESPACE = 'StakePoolIds';

export enum StakePoolsSubQuery {
  APY = 'apy',
  STATS = 'stats',
  METRICS = 'metrics',
  REWARDS = 'rewards',
  RELAYS = 'relays',
  REGISTRATIONS = 'registrations',
  OWNERS = 'owners',
  RETIREMENTS = 'retirements',
  TOTAL_ADA_AMOUNT = 'total_ada_amount',
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
