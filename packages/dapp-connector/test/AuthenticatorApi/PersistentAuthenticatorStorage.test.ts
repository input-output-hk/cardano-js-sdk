import { createPersistentAuthenticatorStorage } from '../../src/index.js';

describe('createPersistentAuthenticatorStorage', () => {
  it('wraps calls to underlying storage under specified key', async () => {
    const storageKey = 'key';
    const underlyingStorage = {
      clear: jest.fn(),
      get: jest.fn(),
      remove: jest.fn(),
      set: jest.fn()
    };
    const storage = createPersistentAuthenticatorStorage(storageKey, underlyingStorage);
    const origins = ['origin'];
    await storage.set(origins);
    expect(underlyingStorage.set).toBeCalledWith({ [storageKey]: origins });
    await storage.get();
    expect(underlyingStorage.get).toBeCalledTimes(1);
  });
});
