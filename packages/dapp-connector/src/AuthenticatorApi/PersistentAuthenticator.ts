import { senderOrigin } from '../util.js';
import type { AuthenticatorApi, Origin, RequestAccess } from './types.js';
import type { Logger } from 'ts-log';
import type { PersistentAuthenticatorStorage } from './PersistentAuthenticatorStorage.js';
import type { Runtime } from 'webextension-polyfill';

export interface PersistentAuhenticatorOptions {
  requestAccess: RequestAccess;
}

export interface PersistentAuthenticatorDependencies {
  storage: PersistentAuthenticatorStorage;
  logger: Logger;
}

export class PersistentAuthenticator implements AuthenticatorApi {
  readonly #requestAccess: RequestAccess;
  readonly #storage: PersistentAuthenticatorStorage;
  readonly #logger: Logger;
  #originsReady: Promise<Origin[]>;

  /**
   * Create a new PersistentAuhenticator
   *
   * @throws underlying storage error if it fails to get() during creation of the authenticator
   */
  public constructor(
    { requestAccess }: PersistentAuhenticatorOptions,
    { logger, storage }: PersistentAuthenticatorDependencies
  ) {
    this.#requestAccess = requestAccess;
    this.#storage = storage;
    this.#logger = logger;
    this.#originsReady = storage.get();
  }

  async requestAccess(sender: Runtime.MessageSender) {
    const origin = senderOrigin(sender);
    if (!origin) {
      this.#logger.warn('Invalid sender url', sender);
      return false;
    }
    const origins = await this.#originsReady;
    if (origins.includes(origin)) {
      return true;
    }
    try {
      const accessGranted = await this.#requestAccess(sender);
      if (accessGranted) {
        const newOrigins = [...origins, origin];
        if (await this.#store(newOrigins)) {
          this.#logger.info('[Authenticator] added', origin);
          return true;
        }
      }
    } catch (error) {
      this.#logger.error('[Authenticator] requestAccess failed', error);
    }
    return false;
  }

  async revokeAccess(sender: Runtime.MessageSender) {
    const origin = senderOrigin(sender);
    if (!origin) {
      this.#logger.warn('Invalid sender url', sender);
      return false;
    }
    const origins = await this.#originsReady;
    const idx = origins.indexOf(origin);
    if (idx >= 0) {
      const newOrigins = [...origins.slice(0, idx), ...origins.slice(idx + 1)];
      if (await this.#store(newOrigins)) {
        this.#logger.info('[Authenticator] revoked access for', origin);
        return true;
      }
    } else {
      this.#logger.warn('[Authenticator] attempted to revoke access for unknown origin', origin);
    }
    return false;
  }

  async haveAccess(sender: Runtime.MessageSender) {
    const origin = senderOrigin(sender);
    if (!origin) return false;
    const origins = await this.#originsReady;
    return origins.includes(origin);
  }

  async clear() {
    await this.#store([]);
  }

  async #store(origins: Origin[]) {
    try {
      await this.#storage.set(origins);
      this.#originsReady = Promise.resolve(origins);
      return true;
    } catch (error) {
      this.#logger.error('[Authenticator] storage.set failed', error);
      return false;
    }
  }
}
