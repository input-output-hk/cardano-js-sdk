/* eslint-disable @typescript-eslint/no-empty-function */
import { InMemoryCache } from './InMemoryCache.js';
import type { AsyncAction, Key } from './InMemoryCache.js';
import type NodeCache from 'node-cache';

export class NoCache extends InMemoryCache {
  constructor() {
    super(0, null as unknown as NodeCache);
  }

  public get<T>(_key: Key, asyncAction: AsyncAction<T>, _ttl?: number): Promise<T> {
    return asyncAction();
  }

  public getVal<T>() {
    return undefined as T;
  }

  public set() {
    return false;
  }

  public invalidate() {}

  public keys(): string[] {
    return [];
  }

  public shutdown() {}

  public clear() {}
}
