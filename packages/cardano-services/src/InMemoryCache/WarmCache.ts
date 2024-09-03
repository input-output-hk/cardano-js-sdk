import { AsyncAction, InMemoryCache, Key } from './InMemoryCache';
import { Seconds } from '@cardano-sdk/core';
import NodeCache from 'node-cache';

interface WarmCacheItem<T> {
  asyncAction: AsyncAction<T>;
  value: T;
  ttl: number;
  updateTime: number;
}

export class WarmCache extends InMemoryCache {
  constructor(ttl: Seconds, expireCheckPeriod: Seconds) {
    const cache = new NodeCache({
      checkperiod: expireCheckPeriod,
      deleteOnExpire: true,
      stdTTL: ttl,
      useClones: false
    });
    super(ttl, cache);

    this.cache.on('expired', (key, value) => {
      this.#warm(key, value, this.cache);
    });
  }

  public mockCache(cache: NodeCache) {
    this.cache = cache;
  }
  public async get<T>(key: Key, asyncAction: AsyncAction<T>, ttl = this.ttlDefault): Promise<T> {
    const cachedValue: WarmCacheItem<T> | undefined = this.cache.get(key);

    if (cachedValue && cachedValue.value) {
      return cachedValue.value;
    }

    const updateTime = Date.now();
    const promise = this.#setWarmCacheItem<T>(key, asyncAction, ttl, this.cache, updateTime);

    this.cache.set(
      key,
      {
        asyncAction,
        ttl,
        updateTime,
        value: promise
        // value: _resolved ? Promise.resolve(value) : Promise.reject(value)
      } as WarmCacheItem<T>,
      ttl
    );

    return promise;
  }

  #warm<T>(key: string, item: WarmCacheItem<T> | undefined, cacheNode: NodeCache) {
    if (item && item.asyncAction) {
      this.#setWarmCacheItem(key, item.asyncAction, item.ttl, cacheNode, Date.now()).catch(
        () => 'rejected in the background'
      );
    }
  }

  async #setWarmCacheItem<T>(
    key: Key,
    asyncAction: AsyncAction<T>,
    ttl: number,
    cacheNode: NodeCache,
    updateTime: number
  ) {
    const handleValue = (value: T, _resolved = true) => {
      const item = this.cache.get(key) as WarmCacheItem<T>;
      if (item && item.updateTime > updateTime) {
        return item.value;
      }
      const promise = _resolved ? Promise.resolve(value) : Promise.reject(value);

      cacheNode.set(
        key,
        {
          asyncAction,
          ttl,
          updateTime,
          value: promise
          // value: _resolved ? Promise.resolve(value) : Promise.reject(value)
        } as WarmCacheItem<T>,
        ttl
      );
      return promise;
    };

    try {
      const value = await asyncAction();
      return handleValue(value, true);
    } catch (error) {
      return handleValue(error as T, false);
    }
  }
}
