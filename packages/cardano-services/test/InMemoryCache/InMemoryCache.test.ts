/* eslint-disable @typescript-eslint/no-explicit-any */
import { DB_CACHE_TTL_DEFAULT, InMemoryCache } from '../../src/InMemoryCache/index.js';
import NodeCache from 'node-cache';

describe('InMemoryCache', () => {
  const CURRENT_EPOCH_KEY = 'NetworkInfo_current_epoch';
  const TOTAL_STAKE_KEY = 'NetworkInfo_total_stake';
  const totalStakeCachedValue = 4_500_000_001;
  const currentEpoch = 250;
  const cachedValues: any = {
    [CURRENT_EPOCH_KEY]: currentEpoch,
    [TOTAL_STAKE_KEY]: totalStakeCachedValue
  };
  const cacheMiss = undefined;

  describe('with mocked node-cache', () => {
    const nodeCacheMocked: jest.MockedClass<any> = {
      close: jest.fn(),
      del: jest.fn(() => true),
      flushAll: jest.fn(),
      get: jest.fn((key) => cachedValues[key]),
      getVal: jest.fn((key) => cachedValues[key]),
      keys: jest.fn(() => [CURRENT_EPOCH_KEY, TOTAL_STAKE_KEY]),
      set: jest.fn(() => true)
    };
    const cache = new InMemoryCache(DB_CACHE_TTL_DEFAULT, nodeCacheMocked);

    afterEach(async () => {
      jest.clearAllMocks();
    });

    it('get with cache hit', async () => {
      const response = await cache.get(TOTAL_STAKE_KEY, () => Promise.resolve());
      expect(response).toEqual(totalStakeCachedValue);
      expect(nodeCacheMocked.get).toBeCalled();
      expect(nodeCacheMocked.set).not.toBeCalled();
    });

    it('get with cache miss', async () => {
      const dbQueryTotalStakeResponse = '445566778899';
      (nodeCacheMocked as jest.MockedClass<any>).get.mockImplementationOnce(() => cacheMiss);

      const response = await cache.get(TOTAL_STAKE_KEY, () => Promise.resolve(dbQueryTotalStakeResponse));
      expect(response).toEqual(dbQueryTotalStakeResponse);
      expect(nodeCacheMocked.get).toBeCalled();
      expect(nodeCacheMocked.set).toBeCalled();
    });

    it('get with cache miss but db query fails the cache is properly cleared', async () => {
      (nodeCacheMocked as jest.MockedClass<any>).get.mockImplementationOnce(() => cacheMiss);
      await expect(cache.get(TOTAL_STAKE_KEY, () => Promise.reject('db'))).rejects.toEqual('db');

      expect(nodeCacheMocked.get).toBeCalled();
      expect(nodeCacheMocked.set).toBeCalled();
      expect(nodeCacheMocked.del).toHaveBeenCalledWith(TOTAL_STAKE_KEY);
    });

    it('set', async () => {
      expect(cache.set(CURRENT_EPOCH_KEY, currentEpoch, 120)).toEqual(true);
      expect(nodeCacheMocked.set).toBeCalled();
    });

    it('getVal', async () => {
      expect(cache.getVal(TOTAL_STAKE_KEY)).toEqual(totalStakeCachedValue);
      expect(nodeCacheMocked.get).toBeCalled();
    });

    it('keys', async () => {
      const keys = cache.keys();
      expect(keys).toEqual([CURRENT_EPOCH_KEY, TOTAL_STAKE_KEY]);
      expect(nodeCacheMocked.keys).toBeCalled();
    });

    it('shutdown', async () => {
      cache.shutdown();
      expect(nodeCacheMocked.close).toBeCalled();
    });

    it('clear', async () => {
      cache.clear();
      expect(nodeCacheMocked.flushAll).toBeCalled();
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
