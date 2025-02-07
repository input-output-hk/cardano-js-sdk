import { type Cache, fromSerializableObject, toSerializableObject } from '@cardano-sdk/util';
import { Storage } from 'webextension-polyfill';

type StorageLocal = Pick<Storage.StorageArea, 'get' | 'set' | 'remove'>;

type MetadataItem = {
  accessTime: number;
};

export type Metadata = Record<string, MetadataItem>;

const sizeOfChunkToBePurged = 0.1;

export const makeMetadataKey = (resourceName: string) => `${resourceName}-metadata`;

export const makeItemKey = (resourceName: string, key: string) => `${resourceName}-item-${key}`;

const isGetBytesInUsePresent = (
  storageLocal: StorageLocal
): storageLocal is StorageLocal & { getBytesInUse: (keys?: string | string[]) => Promise<number> } =>
  'getBytesInUse' in storageLocal;

export const makePersistentCacheStorageFactory =
  (createVolatileCache: <T>() => Map<string, T>) =>
  <T>({
    extensionLocalStorage,
    fallbackMaxCollectionItemsGuard,
    resourceName,
    quotaInBytes
  }: {
    extensionLocalStorage: StorageLocal;
    fallbackMaxCollectionItemsGuard: number;
    resourceName: string;
    quotaInBytes: number;
  }): Cache<T> => {
    const loaded = createVolatileCache<T>();
    const metadataKey = makeMetadataKey(resourceName);
    const getItemKey = (key: string) => makeItemKey(resourceName, key);

    const getMetadata = async () => {
      const result = await extensionLocalStorage.get(metadataKey);
      return result[metadataKey] as Metadata;
    };

    const updateAccessTime = async (key: string) => {
      const metadata = await getMetadata();
      const nextMetadata: Metadata = {
        ...metadata,
        [key]: {
          accessTime: Date.now()
        }
      };
      await extensionLocalStorage.set({ [metadataKey]: nextMetadata });
    };

    const isQuotaExceeded = async () => {
      const metadata = await getMetadata();
      const allCollectionKeys = [metadataKey, ...Object.keys(metadata)];

      // Polyfill we use does not list the getBytesInUse method but that method exists in chrome API
      if (isGetBytesInUsePresent(extensionLocalStorage)) {
        const bytesInUse = await extensionLocalStorage.getBytesInUse(allCollectionKeys);
        return bytesInUse > quotaInBytes;
      }

      return allCollectionKeys.length > fallbackMaxCollectionItemsGuard;
    };

    const evict = async () => {
      let metadata = await getMetadata();
      const mostDatedKeysToPurge = Object.entries(metadata)
        .map(([key, { accessTime }]) => ({ accessTime, key }))
        .sort((a, b) => a.accessTime - b.accessTime)
        .filter((_, index, self) => {
          const numberOfItemsToPurge = Math.abs(self.length * sizeOfChunkToBePurged);
          return index < numberOfItemsToPurge;
        })
        .map((i) => i.key);

      await extensionLocalStorage.remove(mostDatedKeysToPurge);
      metadata = await getMetadata();
      for (const key of mostDatedKeysToPurge) {
        delete metadata[key];
      }
      await extensionLocalStorage.set({ [metadataKey]: metadata });
    };

    return {
      async get(key: string) {
        const itemKey = getItemKey(key);

        let value = loaded.get(itemKey);
        if (!value) {
          const result = await extensionLocalStorage.get(itemKey);
          value = fromSerializableObject(result[itemKey]);
        }

        if (value) {
          void updateAccessTime(itemKey);
        }

        return value;
      },
      async set(key: string, value: T) {
        const itemKey = getItemKey(key);
        loaded.set(itemKey, value);
        await extensionLocalStorage.set({ [itemKey]: toSerializableObject(value) });

        void (async () => {
          await updateAccessTime(itemKey);
          if (await isQuotaExceeded()) await evict();
        })();
      }
    };
  };

export const createPersistentCacheStorage = makePersistentCacheStorageFactory(() => new Map());

export type CreatePersistentCacheStorage = typeof createPersistentCacheStorage;
