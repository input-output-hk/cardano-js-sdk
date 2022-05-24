import { Origin, PersistentAuthenticator } from '../../src';
import { dummyLogger } from 'ts-log';

const createStubStorage = () => {
  let origins: Origin[] = [];
  return {
    get: jest.fn(async () => origins),
    set: jest.fn(async (newOrigins: Origin[]): Promise<void> => {
      origins = newOrigins;
    })
  };
};

describe('PersistentAuthenticator', () => {
  const origin1: Origin = 'origin1';
  const origin2: Origin = 'origin2';
  let requestAccess: jest.Mock;
  let storage: ReturnType<typeof createStubStorage>;
  let authenticator: PersistentAuthenticator;
  const logger = dummyLogger;

  beforeEach(async () => {
    storage = createStubStorage();
    requestAccess = jest.fn();
    authenticator = new PersistentAuthenticator({ requestAccess }, { logger, storage });
  });

  describe('requestAccess', () => {
    it('resolves to true if allowed and persists the decision', async () => {
      requestAccess.mockResolvedValueOnce(true);
      expect(await authenticator.requestAccess(origin1)).toBe(true);
      expect(await authenticator.requestAccess(origin1)).toBe(true);
      expect(requestAccess).toBeCalledTimes(1);
      expect(await storage.get()).toContain(origin1);
    });

    it('resolves to false if denied an error and does not persist the decision', async () => {
      requestAccess.mockResolvedValueOnce(false).mockResolvedValueOnce(true);
      expect(await authenticator.requestAccess(origin1)).toBe(false);
      expect(await storage.get()).not.toContain(origin1);
      expect(await authenticator.requestAccess(origin1)).toBe(true);
      expect(await storage.get()).toContain(origin1);
      expect(requestAccess).toBeCalledTimes(2);
    });

    it('resolves to false if any error is encountered and does not persist the decision', async () => {
      requestAccess.mockResolvedValue(true).mockRejectedValueOnce(new Error('any error'));
      expect(await authenticator.requestAccess(origin1)).toBe(false);
      expect(await storage.get()).not.toContain(origin1);

      storage.set.mockResolvedValue(void 0).mockRejectedValueOnce(new Error('any error'));
      expect(await authenticator.requestAccess(origin1)).toBe(false);
      expect(await storage.get()).not.toContain(origin1);
    });

    it('caches storage by origin', async () => {
      requestAccess.mockResolvedValueOnce(true).mockResolvedValueOnce(false);
      expect(await authenticator.requestAccess(origin1)).toBe(true);
      expect(await authenticator.requestAccess(origin2)).toBe(false);
      expect(requestAccess).toBeCalledTimes(2);
    });
  });

  describe('revokeAccess', () => {
    beforeEach(async () => {
      requestAccess.mockResolvedValueOnce(true);
      await authenticator.requestAccess(origin1);
      storage.set.mockReset();
    });

    it('unknown origin => returns false', async () => {
      expect(await authenticator.revokeAccess(origin2)).toBe(false);
    });

    describe('allowed origin', () => {
      it('returns true and removes origin from cache', async () => {
        expect(await authenticator.revokeAccess(origin1)).toBe(true);
        expect(await authenticator.revokeAccess(origin1)).toBe(false);
        expect(storage.set).toBeCalledTimes(1);
      });

      it('returns false if storage throws', async () => {
        storage.set.mockRejectedValueOnce(new Error('any error'));
        expect(await authenticator.revokeAccess(origin1)).toBe(false);
      });
    });
  });

  describe('haveAccess', () => {
    beforeEach(async () => {
      requestAccess.mockResolvedValueOnce(true);
      await authenticator.requestAccess(origin1);
    });

    it('unknown origin => returns false', async () => {
      expect(await authenticator.haveAccess(origin2)).toBe(false);
    });

    it('allowed origin => returns true', async () => {
      expect(await authenticator.haveAccess(origin1)).toBe(true);
    });
  });

  describe('clear', () => {
    it('removes all origins', async () => {
      requestAccess.mockResolvedValue(true);
      await authenticator.requestAccess(origin1);
      await authenticator.requestAccess(origin2);
      await authenticator.clear();
      expect(await authenticator.haveAccess(origin1)).toBe(false);
      expect(await authenticator.haveAccess(origin2)).toBe(false);
    });
  });
});
