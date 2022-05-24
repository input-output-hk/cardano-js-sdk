import { AuthenticatorApi, Origin, RequestAccess } from './types';
import { Logger } from 'ts-log';
import { PersistentAuthenticatorStorage } from './PersistentAuthenticatorStorage';

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

  async requestAccess(origin: Origin) {
    const origins = await this.#originsReady;
    if (origins.includes(origin)) {
      return true;
    }
    try {
      const accessGranted = await this.#requestAccess(origin);
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

  async revokeAccess(origin: Origin) {
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

  async haveAccess(origin: Origin) {
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
