import type { Origin } from './types.js';
import type { Storage } from 'webextension-polyfill';

export type PersistentAuthenticatorStorage = {
  get(): Promise<Origin[]>;
  set(origins: Origin[]): Promise<void>;
};

export const createPersistentAuthenticatorStorage = (
  storageKey: string,
  store: Storage.StorageArea
): PersistentAuthenticatorStorage => ({
  async get() {
    const objects = await store.get(storageKey);
    return objects?.[storageKey] || [];
  },
  async set(origins: Origin[]) {
    await store.set({
      [storageKey]: origins
    });
  }
});
