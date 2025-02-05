import {
  Metadata,
  makeItemKey,
  makeMetadataKey,
  makePersistentCacheStorageFactory
} from '../../src/storage/persistentCacheStorage/persistentCacheStorage';
import { setTimeout } from 'node:timers/promises';

Object.defineProperty(global, 'performance', {
  writable: true
});

const fakeDate = new Date();

jest.useFakeTimers().setSystemTime(fakeDate);

const resourceName = 'resource-name';
const metadataKey = makeMetadataKey(resourceName);
const itemKeyX = makeItemKey(resourceName, 'x');
const itemKeyY = makeItemKey(resourceName, 'y');
const defaultStorageLocalCache = new Map<string, number | Metadata>([
  [itemKeyX, 1],
  [
    metadataKey,
    {
      [itemKeyX]: {
        accessTime: fakeDate.getTime() - 1
      }
    }
  ]
]);

const preparePersistentStorage = ({
  bytesInUse = 1,
  inMemoryCache = new Map(),
  storageLocalCache = new Map(defaultStorageLocalCache)
}: // eslint-disable-next-line @typescript-eslint/no-explicit-any
{ bytesInUse?: number; inMemoryCache?: Map<string, any>; storageLocalCache?: Map<string, any> } = {}) => {
  const extensionLocalStorage = {
    get: jest.fn().mockImplementation(async (key: string) => ({ [key]: storageLocalCache.get(key) })),
    getBytesInUse: jest.fn().mockImplementation(async () => bytesInUse),
    remove: jest.fn().mockImplementation(async () => void 0),
    set: jest.fn().mockImplementation(async (change: Record<string, number>) => {
      for (const [key, value] of Object.entries(change)) {
        storageLocalCache.set(key, value);
      }
    })
  };
  const persistentCache = makePersistentCacheStorageFactory(() => inMemoryCache)({
    extensionLocalStorage,
    fallbackMaxCollectionItemsGuard: 30,
    quotaInBytes: 1024,
    resourceName
  });

  return { extensionLocalStorage, persistentCache, storageLocalCache };
};

describe('createPersistentCacheStorage', () => {
  describe('get', () => {
    it('queries storage.local when no data is in memory cache', async () => {
      const { persistentCache, extensionLocalStorage } = preparePersistentStorage();
      const value = await persistentCache.get('x');

      expect(value).toEqual(1);
      expect(extensionLocalStorage.get).toHaveBeenCalledTimes(2);
      expect(extensionLocalStorage.get).toHaveBeenNthCalledWith(1, itemKeyX);
    });

    it('does not query storage.local when data is in memory cache', async () => {
      const { persistentCache, extensionLocalStorage } = preparePersistentStorage({
        inMemoryCache: new Map([[itemKeyX, 1]])
      });
      const value = await persistentCache.get('x');

      expect(value).toEqual(1);
      expect(extensionLocalStorage.get).toHaveBeenCalledTimes(1);
    });

    it('updates accessTime when accessed from memory cache', async () => {
      const { persistentCache, extensionLocalStorage } = preparePersistentStorage({
        inMemoryCache: new Map([[itemKeyX, 1]])
      });
      await persistentCache.get('x');
      await setTimeout();

      expect(extensionLocalStorage.set).toHaveBeenCalledTimes(1);
      expect(extensionLocalStorage.set).toHaveBeenNthCalledWith(1, {
        [metadataKey]: {
          [itemKeyX]: {
            accessTime: fakeDate.getTime()
          }
        }
      });
    });

    it('updates accessTime when accessed from extension storage cache', async () => {
      const { persistentCache, extensionLocalStorage } = preparePersistentStorage();
      await persistentCache.get('x');
      await setTimeout();

      expect(extensionLocalStorage.set).toHaveBeenCalledTimes(1);
      expect(extensionLocalStorage.set).toHaveBeenNthCalledWith(1, {
        [metadataKey]: {
          [itemKeyX]: {
            accessTime: fakeDate.getTime()
          }
        }
      });
    });
  });

  describe('set', () => {
    it('adds item to memory cache', async () => {
      const inMemoryCache = new Map();
      const { persistentCache } = preparePersistentStorage({
        inMemoryCache
      });
      jest.spyOn(inMemoryCache, 'set');

      await persistentCache.set('y', 2);

      expect(inMemoryCache.set).toHaveBeenCalledTimes(1);
      expect(inMemoryCache.set).toHaveBeenNthCalledWith(1, itemKeyY, 2);
    });

    it('stores item in the extension storage', async () => {
      const { persistentCache, extensionLocalStorage } = preparePersistentStorage();
      await persistentCache.set('y', 2);

      expect(extensionLocalStorage.set).toHaveBeenCalledTimes(1);
      expect(extensionLocalStorage.set).toHaveBeenNthCalledWith(1, {
        [itemKeyY]: 2
      });
    });

    it('updates accessTime', async () => {
      const { persistentCache, extensionLocalStorage, storageLocalCache } = preparePersistentStorage();
      const metadataBeforeUpdate = storageLocalCache.get(metadataKey);
      await persistentCache.set('y', 2);
      await setTimeout();

      expect(extensionLocalStorage.set).toHaveBeenCalledTimes(2);
      expect(extensionLocalStorage.set).toHaveBeenNthCalledWith(2, {
        [metadataKey]: {
          [itemKeyY]: {
            accessTime: fakeDate.getTime()
          },
          ...metadataBeforeUpdate
        }
      });
    });

    it('queries size of all items managed by the cache', async () => {
      const { persistentCache, extensionLocalStorage } = preparePersistentStorage();
      await persistentCache.set('y', 2);
      await setTimeout();

      expect(extensionLocalStorage.getBytesInUse).toHaveBeenCalledTimes(1);
      expect(extensionLocalStorage.getBytesInUse).toHaveBeenNthCalledWith(
        1,
        expect.arrayContaining([itemKeyY, ...defaultStorageLocalCache.keys()])
      );
    });

    it('removes 10% of most dated items if quota exceeded', async () => {
      let storageLocalCache: Map<string, number | Metadata> = new Map([
        [itemKeyX, 1],
        [makeItemKey(resourceName, 'a'), 1],
        [makeItemKey(resourceName, 'b'), 1],
        [makeItemKey(resourceName, 'c'), 1],
        [makeItemKey(resourceName, 'd'), 1],
        [makeItemKey(resourceName, 'e'), 1],
        [makeItemKey(resourceName, 'f'), 1],
        [makeItemKey(resourceName, 'g'), 1],
        [makeItemKey(resourceName, 'h'), 1]
      ]);

      const metadataContent = [...storageLocalCache].reduce((acc, [key]) => {
        acc[key] = {
          accessTime: key === itemKeyX ? fakeDate.getTime() - 1 : fakeDate.getTime()
        };
        return acc;
      }, {} as Metadata);

      storageLocalCache = new Map<string, number | Metadata>([
        [metadataKey, metadataContent],
        ...defaultStorageLocalCache
      ]);

      const { persistentCache, extensionLocalStorage } = preparePersistentStorage({
        bytesInUse: 1025,
        storageLocalCache
      });
      await persistentCache.set('y', 2);
      await setTimeout();

      expect(extensionLocalStorage.remove).toHaveBeenCalledTimes(1);
      expect(extensionLocalStorage.remove).toHaveBeenNthCalledWith(1, [itemKeyX]);
    });
  });
});
