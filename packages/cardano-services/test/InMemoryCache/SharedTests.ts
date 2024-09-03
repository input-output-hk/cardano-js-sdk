import { InMemoryCache } from '../../src';

export const CURRENT_EPOCH_KEY = 'NetworkInfo_current_epoch';
export const TOTAL_STAKE_KEY = 'NetworkInfo_total_stake';
export const totalStakeCachedValue = 4_500_000_001;
export const currentEpoch = 250;
export const cacheMiss = undefined;

export const createNodeCacheMocked = (cachedValues: { [key: string]: unknown }) => ({
  close: jest.fn(),
  del: jest.fn(() => true),
  flushAll: jest.fn(),
  get: jest.fn((key) => cachedValues[key]),
  getVal: jest.fn((key) => cachedValues[key]),
  keys: jest.fn(() => [CURRENT_EPOCH_KEY, TOTAL_STAKE_KEY]),
  set: jest.fn(() => true)
});
export const sharedInMemoryCacheTests = (
  /* eslint-disable-next-line  @typescript-eslint/no-explicit-any */
  nodeCacheMocked: jest.MockedClass<any>,
  cachedValues: { [key: string]: unknown },
  cache: InMemoryCache,
  implName: string
) => {
  describe(`shared tests for ${implName}, with mocked node-cache`, () => {
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
      nodeCacheMocked.get.mockImplementationOnce(() => cacheMiss);

      const response = await cache.get(TOTAL_STAKE_KEY, () => Promise.resolve(dbQueryTotalStakeResponse));
      expect(response).toEqual(dbQueryTotalStakeResponse);
      expect(nodeCacheMocked.get).toBeCalled();
      expect(nodeCacheMocked.set).toBeCalled();
    });

    it('set', async () => {
      expect(cache.set(CURRENT_EPOCH_KEY, currentEpoch, 120)).toEqual(true);
      expect(nodeCacheMocked.set).toBeCalled();
    });

    it('getVal', async () => {
      expect(cache.getVal(TOTAL_STAKE_KEY)).toEqual(cachedValues[TOTAL_STAKE_KEY]);
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
};
