import { CACHE_TTL_DEFAULT } from './defaults';
import NodeCache from 'node-cache';

export type Key = string | number;
export type AsyncAction<T> = () => Promise<T>;

export class InMemoryCache {
  #cache: NodeCache;
  #ttlDefault: number;

  constructor(cacheTtlInMins: number = CACHE_TTL_DEFAULT, cache: NodeCache = new NodeCache()) {
    this.#ttlDefault = cacheTtlInMins * 60;
    this.#cache = cache;
  }

  /**
   * Get a cached key value, if not found execute db query and cache the result with that key
   *
   * @param key cache key
   * @param asyncAction async function to get the value
   * @param ttl cache duration in seconds
   * @returns The value stored with the key
   */
  public async get<T>(key: Key, asyncAction: AsyncAction<T>, ttl = this.#ttlDefault): Promise<T> {
    const cachedValue: T | undefined = this.#cache.get(key);
    if (cachedValue) {
      return cachedValue;
    }

    const resultPromise = asyncAction();
    this.#cache.set(
      key,
      resultPromise.catch(() => this.#cache.del(key)),
      ttl
    );
    return resultPromise;
  }

  /**
   * Get a cached key
   *
   * @param key cache key
   * @returns The value stored in the key
   */
  public getVal<T>(key: Key) {
    return this.#cache.get<T>(key);
  }

  /**
   * Set a cached key
   *
   * @param key Cache key
   * @param value A value to cache
   * @param ttl The time to live in seconds.
   */
  public set<T>(key: Key, value: T, ttl: number) {
    return this.#cache.set<T>(key, value, ttl);
  }

  /**
   * Invalidate cached values
   *
   * @param keys cache key to delete or a array of cache keys
   */
  public invalidate(keys: Key | Key[]) {
    this.#cache.del(keys);
  }

  /**
   * List all keys within this cache
   *
   * @returns An array of all keys
   */
  public keys() {
    return this.#cache.keys();
  }

  /**
   * Clear the interval timeout which is set on check period option. Default: 600
   */
  public shutdown() {
    this.#cache.close();
  }

  /**
   * Clear the whole data and reset the stats
   */
  public clear() {
    this.#cache.flushAll();
  }
}
