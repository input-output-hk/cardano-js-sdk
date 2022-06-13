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
