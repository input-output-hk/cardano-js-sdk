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
  #origins: Origin[];

  private constructor(
    requestAccess: RequestAccess,
    origins: Origin[],
    storage: PersistentAuthenticatorStorage,
    logger: Logger
  ) {
    this.#requestAccess = requestAccess;
    this.#storage = storage;
    this.#logger = logger;
    this.#origins = origins;
  }

  /**
   * Create a new PersistentAuhenticator
   *
   * @throws underlying storage error if it fails to get() during creation of the authenticator
   */
  static async create(
    { requestAccess }: PersistentAuhenticatorOptions,
    { logger, storage }: PersistentAuthenticatorDependencies
  ) {
    const origins = await storage.get();
    return new PersistentAuthenticator(requestAccess, origins, storage, logger);
  }

  async requestAccess(origin: Origin) {
    if (this.#origins.includes(origin)) {
      return true;
    }
    try {
      const accessGranted = await this.#requestAccess(origin);
      if (accessGranted) {
        const newOrigins = [...this.#origins, origin];
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
    const idx = this.#origins.indexOf(origin);
    if (idx >= 0) {
      const newOrigins = [...this.#origins.slice(0, idx), ...this.#origins.slice(idx + 1)];
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
    return this.#origins.includes(origin);
  }

  async clear() {
    await this.#store([]);
  }

  async #store(origins: Origin[]) {
    try {
      await this.#storage.set(origins);
      this.#origins = origins;
      return true;
    } catch (error) {
      this.#logger.error('[Authenticator] storage.set failed', error);
      return false;
    }
  }
}
