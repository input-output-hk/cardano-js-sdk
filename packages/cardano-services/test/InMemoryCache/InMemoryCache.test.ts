/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  CURRENT_EPOCH_KEY,
  TOTAL_STAKE_KEY,
  cacheMiss,
  createNodeCacheMocked,
  currentEpoch,
  sharedInMemoryCacheTests,
  totalStakeCachedValue
} from './SharedTests';
import { DB_CACHE_TTL_DEFAULT, InMemoryCache } from '../../src/InMemoryCache';
import NodeCache from 'node-cache';

describe('InMemoryCache', () => {
  const cachedValues: any = {
    [CURRENT_EPOCH_KEY]: currentEpoch,
    [TOTAL_STAKE_KEY]: totalStakeCachedValue
  };
  const nodeCacheMocked: jest.MockedClass<any> = createNodeCacheMocked(cachedValues);
  const cache = new InMemoryCache(DB_CACHE_TTL_DEFAULT, nodeCacheMocked);
  sharedInMemoryCacheTests(nodeCacheMocked, cachedValues, cache, 'InMemoryCache');

  describe('with mocked node-cache', () => {
    afterEach(async () => {
      jest.clearAllMocks();
    });

    it('get with cache miss but db query fails the cache is properly cleared', async () => {
      (nodeCacheMocked as jest.MockedClass<any>).get.mockImplementationOnce(() => cacheMiss);
      await expect(cache.get(TOTAL_STAKE_KEY, () => Promise.reject('db'))).rejects.toEqual('db');

      expect(nodeCacheMocked.get).toBeCalled();
      expect(nodeCacheMocked.set).toBeCalled();
      expect(nodeCacheMocked.del).toHaveBeenCalledWith(TOTAL_STAKE_KEY);
    });
  });
  describe('with real node-cache', () => {
    it('get called multiple times does not query twice and returns the same result', async () => {
      const realCache = new InMemoryCache(DB_CACHE_TTL_DEFAULT, new NodeCache());

      let resolveQuery: Function;
      const queryResult = new Promise((resolve) => (resolveQuery = resolve));
      const dbSyncQuery = jest.fn(() => queryResult);

      const result1 = realCache.get(TOTAL_STAKE_KEY, dbSyncQuery);
      const result2 = realCache.get(TOTAL_STAKE_KEY, dbSyncQuery);

      resolveQuery!('db');
      expect(await Promise.all([result1, result2])).toEqual(['db', 'db']);

      expect(dbSyncQuery).toBeCalledTimes(1);
    });
  });
});
