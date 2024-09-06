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
import { DB_CACHE_TTL_DEFAULT } from '../../src/InMemoryCache';
import { Seconds } from '@cardano-sdk/core';
import { WarmCache } from '../../src/InMemoryCache/WarmCache';

describe('WarmCache', () => {
  const cachedValues = {
    [CURRENT_EPOCH_KEY]: {
      asyncAction: () => Promise.resolve(currentEpoch),
      value: currentEpoch
    },
    [TOTAL_STAKE_KEY]: {
      asyncAction: () => Promise.resolve(totalStakeCachedValue),
      value: totalStakeCachedValue
    }
  };

  describe('with mocked node-cache', () => {
    const nodeCacheMocked: jest.MockedClass<any> = createNodeCacheMocked(cachedValues);

    const cache = new WarmCache(DB_CACHE_TTL_DEFAULT, Seconds(1));
    cache.mockCache(nodeCacheMocked);

    sharedInMemoryCacheTests(nodeCacheMocked, cachedValues, cache, 'WarmCache');

    afterEach(async () => {
      jest.clearAllMocks();
    });

    it('get with cache miss but db query fails the cache is properly handled', async () => {
      jest.useFakeTimers();
      jest.setSystemTime(1_725_528_828_051);
      (nodeCacheMocked as jest.MockedClass<any>).get.mockImplementationOnce(() => cacheMiss);
      const promise = Promise.reject('db');
      const asyncAction = jest.fn(() => promise);
      await expect(cache.get(TOTAL_STAKE_KEY, asyncAction)).rejects.toEqual('db');

      await Promise.resolve();
      expect(asyncAction).toBeCalledTimes(1);
      expect(nodeCacheMocked.set).toBeCalledTimes(2);
      expect(nodeCacheMocked.set).toHaveBeenCalledWith(
        TOTAL_STAKE_KEY,
        { asyncAction, ttl: 7200, updateTime: 1_725_528_828_051, value: promise },
        7200
      );
    });
  });

  describe('with real node-cache', () => {
    jest.useFakeTimers();

    const WARM = 'warm';
    const WARMER = 'warmer';
    const HOT = 'hot';
    const COLD = 'cold';

    it('get called multiple times does not query twice and returns the same result', async () => {
      const realCache = new WarmCache(DB_CACHE_TTL_DEFAULT, Seconds(10));

      let resolveQuery: Function;
      const queryResult = new Promise((resolve) => (resolveQuery = resolve));
      const dbSyncQuery = jest.fn(() => queryResult);

      await Promise.resolve();
      const result1 = realCache.get(TOTAL_STAKE_KEY, dbSyncQuery);
      await Promise.resolve();
      const result2 = realCache.get(TOTAL_STAKE_KEY, dbSyncQuery);

      resolveQuery!('db');
      expect(await result1).toEqual(await result2);

      expect(dbSyncQuery).toBeCalledTimes(1);
    });

    it('get warmer in the background', async () => {
      const mockedFunc = jest
        .fn()
        .mockImplementation(() => Promise.reject('default'))
        .mockImplementationOnce(() => Promise.resolve(COLD))
        .mockImplementationOnce(() => Promise.resolve(WARM))
        .mockImplementationOnce(() => Promise.resolve(WARMER))
        .mockImplementationOnce(() => Promise.resolve(HOT));

      const realCache = new WarmCache(Seconds(5), Seconds(0.1));

      // first round - no warming
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(COLD);
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(COLD);
      expect(mockedFunc).toBeCalledTimes(1);

      // second round - first warming
      mockedFunc.mockClear();
      jest.advanceTimersByTime(5100);
      await Promise.resolve();
      expect(mockedFunc).toBeCalledTimes(1);
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(WARM);
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(WARM);
      expect(mockedFunc).toBeCalledTimes(1);

      // third round - second warming
      mockedFunc.mockClear();
      jest.advanceTimersByTime(5100);
      await Promise.resolve();
      expect(mockedFunc).toBeCalledTimes(1);
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(WARMER);
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(WARMER);
      expect(mockedFunc).toBeCalledTimes(1);

      // fourth round - third warming
      mockedFunc.mockClear();
      jest.advanceTimersByTime(5100);
      await Promise.resolve();
      expect(mockedFunc).toBeCalledTimes(1);
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(HOT);
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(HOT);
      expect(mockedFunc).toBeCalledTimes(1);

      realCache.shutdown();
    });

    it('warming handles rejects in the background', async () => {
      const mockedFunc = jest
        .fn()
        .mockImplementation(() => Promise.resolve('default'))
        .mockImplementationOnce(() => Promise.reject(COLD))
        .mockImplementationOnce(() => Promise.resolve(WARM))
        .mockImplementationOnce(() => Promise.reject(COLD))
        .mockImplementationOnce(() => Promise.resolve(WARMER))
        .mockImplementationOnce(() => Promise.resolve(HOT));

      const realCache = new WarmCache(Seconds(5), Seconds(0.1));

      // first round - no warming
      await expect(realCache.get('key1', mockedFunc)).rejects.toBe(COLD);
      expect(mockedFunc).toBeCalledTimes(1);

      // first round - warming of rejected
      mockedFunc.mockClear();
      jest.advanceTimersByTime(5100);
      await Promise.resolve();
      expect(mockedFunc).toBeCalledTimes(1);
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(WARM);
      expect(mockedFunc).toBeCalledTimes(1);

      // second round - first warming but rejected in the background
      mockedFunc.mockClear();
      jest.advanceTimersByTime(5100);
      await Promise.resolve();
      expect(mockedFunc).toBeCalledTimes(1); // a new call in the background
      await expect(realCache.get('key1', mockedFunc)).rejects.toBe(COLD);

      // third round - second warming, rejected get warmed in the background
      mockedFunc.mockClear();
      jest.advanceTimersByTime(5100);
      await Promise.resolve();
      expect(mockedFunc).toBeCalledTimes(1); // new call in the background
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(WARMER);
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(WARMER);
      expect(mockedFunc).toBeCalledTimes(1); // no new call

      // fourth round - third warming
      mockedFunc.mockClear();
      jest.advanceTimersByTime(5100);
      await Promise.resolve();
      expect(mockedFunc).toBeCalledTimes(1); // a new call in the background
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(HOT);
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(HOT);
      expect(mockedFunc).toBeCalledTimes(1); // no new call

      realCache.shutdown();
    });

    it('warming handles lagging and race conditions', async () => {
      const mockedFunc = jest
        .fn()
        .mockImplementation(() => Promise.reject('default'))
        .mockImplementationOnce(() => Promise.resolve(COLD))
        .mockImplementationOnce(() => Promise.resolve(WARM))
        .mockImplementationOnce(() => new Promise((_resolve, reject) => setTimeout(() => reject('timeout'), 2000)))
        .mockImplementationOnce(() => Promise.resolve(WARMER))
        .mockImplementationOnce(() => Promise.resolve(HOT));

      const realCache = new WarmCache(Seconds(5), Seconds(0.1));

      // first round - no warming
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(COLD);
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(COLD);
      expect(mockedFunc).toBeCalledTimes(1);

      // second round - warming
      mockedFunc.mockClear();
      jest.advanceTimersByTime(5100);
      await Promise.resolve();
      expect(mockedFunc).toBeCalledTimes(1);
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(WARM);

      // third round - timeout call finished, but couldn't override a newer call finished
      mockedFunc.mockClear();
      jest.advanceTimersByTime(5100);
      await Promise.resolve();
      expect(mockedFunc).toBeCalledTimes(1);
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(WARMER);
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(WARMER);
      expect(mockedFunc).toBeCalledTimes(2);

      // fourth round
      mockedFunc.mockClear();
      jest.advanceTimersByTime(5100);
      await Promise.resolve();
      expect(mockedFunc).toBeCalledTimes(1);
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(HOT);
      await expect(realCache.get('key1', mockedFunc)).resolves.toBe(HOT);
      expect(mockedFunc).toBeCalledTimes(1);

      realCache.shutdown();
    });
  });
});
