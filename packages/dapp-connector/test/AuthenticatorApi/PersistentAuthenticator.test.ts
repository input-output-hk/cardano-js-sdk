import { Origin, PersistentAuthenticator, senderOrigin } from '../../src';
import { Runtime } from 'webextension-polyfill';
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
  const sender1: Runtime.MessageSender = { url: 'https://sender1.com' };
  const sender2: Runtime.MessageSender = { url: 'https://sender2.com' };
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
      expect(await authenticator.requestAccess(sender1)).toBe(true);
      expect(await authenticator.requestAccess(sender1)).toBe(true);
      expect(requestAccess).toBeCalledTimes(1);
      expect(await storage.get()).toContain(senderOrigin(sender1));
    });

    it('resolves to false if denied an error and does not persist the decision', async () => {
      requestAccess.mockResolvedValueOnce(false).mockResolvedValueOnce(true);
      expect(await authenticator.requestAccess(sender1)).toBe(false);
      expect(await storage.get()).not.toContain(senderOrigin(sender1));
      expect(await authenticator.requestAccess(sender1)).toBe(true);
      expect(await storage.get()).toContain(senderOrigin(sender1));
      expect(requestAccess).toBeCalledTimes(2);
    });

    it('resolves to false if any error is encountered and does not persist the decision', async () => {
      requestAccess.mockResolvedValue(true).mockRejectedValueOnce(new Error('any error'));
      expect(await authenticator.requestAccess(sender1)).toBe(false);
      expect(await storage.get()).not.toContain(senderOrigin(sender1));

      storage.set.mockResolvedValue(void 0).mockRejectedValueOnce(new Error('any error'));
      expect(await authenticator.requestAccess(sender1)).toBe(false);
      expect(await storage.get()).not.toContain(senderOrigin(sender1));
    });

    it('caches storage by origin', async () => {
      requestAccess.mockResolvedValueOnce(true).mockResolvedValueOnce(false);
      expect(await authenticator.requestAccess(sender1)).toBe(true);
      expect(await authenticator.requestAccess(sender2)).toBe(false);
      expect(requestAccess).toBeCalledTimes(2);
    });
  });

  describe('revokeAccess', () => {
    beforeEach(async () => {
      requestAccess.mockResolvedValueOnce(true);
      await authenticator.requestAccess(sender1);
      storage.set.mockReset();
    });

    it('unknown origin => returns false', async () => {
      expect(await authenticator.revokeAccess(sender2)).toBe(false);
    });

    describe('allowed origin', () => {
      it('returns true and removes origin from cache', async () => {
        expect(await authenticator.revokeAccess(sender1)).toBe(true);
        expect(await authenticator.revokeAccess(sender1)).toBe(false);
        expect(storage.set).toBeCalledTimes(1);
      });

      it('returns false if storage throws', async () => {
        storage.set.mockRejectedValueOnce(new Error('any error'));
        expect(await authenticator.revokeAccess(sender1)).toBe(false);
      });
    });
  });

  describe('haveAccess', () => {
    beforeEach(async () => {
      requestAccess.mockResolvedValueOnce(true);
      await authenticator.requestAccess(sender1);
    });

    it('unknown origin => returns false', async () => {
      expect(await authenticator.haveAccess(sender2)).toBe(false);
    });

    it('allowed origin => returns true', async () => {
      expect(await authenticator.haveAccess(sender1)).toBe(true);
    });
  });

  describe('clear', () => {
    it('removes all origins', async () => {
      requestAccess.mockResolvedValue(true);
      await authenticator.requestAccess(sender1);
      await authenticator.requestAccess(sender2);
      await authenticator.clear();
      expect(await authenticator.haveAccess(sender1)).toBe(false);
      expect(await authenticator.haveAccess(sender2)).toBe(false);
    });
  });
});
