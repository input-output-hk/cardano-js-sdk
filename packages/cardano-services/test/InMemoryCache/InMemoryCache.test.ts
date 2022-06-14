/* eslint-disable @typescript-eslint/no-explicit-any */
import { CACHE_TTL_DEFAULT, InMemoryCache } from '../../src/InMemoryCache';
import NodeCache from 'node-cache';

jest.mock('node-cache');

describe('InMemoryCache', () => {
  let nodeCache: NodeCache;
  let cache: InMemoryCache;

  const CURRENT_EPOCH_KEY = 'NetworkInfo_current_epoch';
  const TOTAL_STAKE_KEY = 'NetworkInfo_total_stake';
  const totalStakeCachedValue = 4_500_000_000;
  const currentEpoch = 250;
  const cachedValues: any = {
    [CURRENT_EPOCH_KEY]: currentEpoch,
    [TOTAL_STAKE_KEY]: totalStakeCachedValue
  };

  beforeAll(() => {
    (NodeCache as jest.MockedClass<any>).mockImplementation(() => ({
      close: jest.fn(),
      flushAll: jest.fn(),
      get: jest.fn((key) => cachedValues[key]),
      getVal: jest.fn((key) => cachedValues[key]),
      keys: jest.fn(() => [CURRENT_EPOCH_KEY, TOTAL_STAKE_KEY]),
      set: jest.fn(() => true)
    }));
    nodeCache = new NodeCache();
    cache = new InMemoryCache(CACHE_TTL_DEFAULT, nodeCache);
  });

  afterEach(async () => {
    jest.clearAllMocks();
  });

  it('get with cache hit', async () => {
    const response = await cache.get(TOTAL_STAKE_KEY, () => Promise.resolve());
    expect(response).toEqual(totalStakeCachedValue);
    expect(nodeCache.get).toBeCalled();
    expect(nodeCache.set).not.toBeCalled();
  });

  it('get with cache miss', async () => {
    const cacheMiss = undefined;
    const dbQueryTotalStakeResponse = '445566778899';
    (nodeCache as jest.MockedClass<any>).get.mockImplementationOnce(() => cacheMiss);

    const response = await cache.get(TOTAL_STAKE_KEY, () => Promise.resolve(dbQueryTotalStakeResponse));
    expect(response).toEqual(dbQueryTotalStakeResponse);
    expect(nodeCache.get).toBeCalled();
    expect(nodeCache.set).toBeCalled();
  });

  it('set', async () => {
    expect(cache.set(CURRENT_EPOCH_KEY, currentEpoch, 120)).toEqual(true);
    expect(nodeCache.set).toBeCalled();
  });

  it('getVal', async () => {
    expect(cache.getVal(TOTAL_STAKE_KEY)).toEqual(totalStakeCachedValue);
    expect(nodeCache.get).toBeCalled();
  });

  it('keys', async () => {
    const keys = cache.keys();
    expect(keys).toEqual([CURRENT_EPOCH_KEY, TOTAL_STAKE_KEY]);
    expect(nodeCache.keys).toBeCalled();
  });

  it('shutdown', async () => {
    cache.shutdown();
    expect(nodeCache.close).toBeCalled();
  });

  it('clear', async () => {
    cache.clear();
    expect(nodeCache.flushAll).toBeCalled();
  });
});
