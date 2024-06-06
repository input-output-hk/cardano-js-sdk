import { PoolAPYSortFields, PoolDataSortFields, PoolMetricsSortFields, PoolROSSortFields } from '@cardano-sdk/core';
import { getStakePoolSortType } from '../../../src/StakePool/DbSyncStakePoolProvider/util.js';
import type { PoolSortType } from '../../../src/index.js';

describe('getStakePoolSortType', () => {
  it('returns metrics for PoolMetricsSortFields', () => {
    for (const field of PoolMetricsSortFields) expect(getStakePoolSortType(field)).toEqual<PoolSortType>('metrics');
  });
  it('returns data for PoolDataSortFields', () => {
    for (const field of PoolDataSortFields) expect(getStakePoolSortType(field)).toEqual<PoolSortType>('data');
  });
  it('returns apy for PoolAPYSortFields', () => {
    for (const field of PoolAPYSortFields) expect(getStakePoolSortType(field)).toEqual<PoolSortType>('apy');
  });
  it('returns ros for PoolROSSortFields', () => {
    for (const field of PoolROSSortFields) expect(getStakePoolSortType(field)).toEqual<PoolSortType>('ros');
  });
  it('throws an error if field is not valid', () => {
    expect(() => getStakePoolSortType('other')).toThrow('Invalid sort field');
  });
});
