import { APIErrorCode, ApiError } from '../errors';
import { Logger, dummyLogger } from 'ts-log';
import { Storage, storage } from 'webextension-polyfill';
import { WalletApi } from './types';

/**
 * CIP30 API version
 */
export type ApiVersion = string;

/**
 * Unique identifier, used to inject into the cardano namespace
 */
export type WalletName = string;

/**
 * A URI image (e.g. data URI base64 or other) for img src for the wallet
 * which can be used inside of the dApp for the purpose of asking the user
 * which wallet they would like to connect with.
 */
export type WalletIcon = string;

export type WalletProperties = { apiVersion: ApiVersion; icon: WalletIcon; name: WalletName };

/**
 * Resolve true to authorise access to the WalletAPI, or resolve false to deny.
 *
 * Errors: `ApiError`
 */
export type RequestAccess = () => Promise<boolean>;

export type WalletOptions = {
  logger?: Logger;
  storage?: Storage.LocalStorageArea;
};

const defaultOptions = {
  logger: dummyLogger,
  persistAllowList: false,
  storage: storage.local
};

type WalletStorage = {
  allowList: string[];
};

export class Wallet {
  readonly apiVersion: ApiVersion;
  readonly name: WalletName;
  readonly icon: WalletIcon;

  #allowList: string[];
  #logger: Logger;
  #api: WalletApi;
  #requestAccess: RequestAccess;
  readonly #options: Required<WalletOptions>;

  constructor(properties: WalletProperties, api: WalletApi, requestAccess: RequestAccess, options?: WalletOptions) {
    this.apiVersion = properties.apiVersion;
    this.enable = this.enable.bind(this);
    this.icon = properties.icon;
    this.isEnabled = this.isEnabled.bind(this);
    this.name = properties.name;

    this.#api = api;
    this.#options = { ...defaultOptions, ...options };
    this.#logger = options?.logger || this.#options.logger;
    this.#requestAccess = requestAccess;
  }

  async #getAllowList(storageKey: string): Promise<string[]> {
    if (!storageKey) return Promise.resolve([]);
    try {
      const persistedStorage: Record<string, WalletStorage> = await this.#options.storage.get(storageKey);
      return persistedStorage[storageKey].allowList;
    } catch {
      return [];
    }
  }

  async #allowApplication(appName: string) {
    this.#allowList.push(appName);

    // Todo: Encrypt
    await this.#options.storage.set({ [this.name]: { allowList: [...this.#allowList, appName] } });
    this.#logger.debug(
      {
        allowList: this.#allowList,
        module: 'Wallet',
        walletName: this.name
      },
      'Allow list persisted'
    );
  }

  /**
   * Returns true if the dApp is already connected to the user's wallet, or if requesting access
   * would return true without user confirmation (e.g. the dApp is whitelisted), and false otherwise.
   *
   * If this function returns true, then any subsequent calls to wallet.enable()
   * during the current session should succeed and return the API object.
   *
   * Errors: `ApiError`
   */
  public async isEnabled(hostname: string): Promise<Boolean> {
    try {
      if (!this.#allowList) {
        this.#allowList = await this.#getAllowList(this.name);
      }
      return this.#allowList.includes(hostname);
    } catch (error) {
      this.#logger.error(error);
      throw error;
    }
  }

  /**
   * This is the entrypoint to start communication with the user's wallet.
   *
   * The wallet should request the user's permission to connect the web page to the user's wallet,
   * and if permission has been granted, the full API will be returned to the dApp to use.
   *
   * The wallet can choose to maintain a whitelist to not necessarily ask the user's permission
   * every time access is requested, but this behavior is up to the wallet and should be transparent
   * to web pages using this API.
   *
   * If a wallet is already connected this function should not request access a second time,
   * and instead just return the API object.
   *
   * Errors: `ApiError`
   */
  public async enable(hostname: string): Promise<WalletApi> {
    if (await this.isEnabled(hostname)) {
      this.#logger.debug(
        {
          module: 'Wallet',
          walletName: this.name
        },
        `${hostname} has previously been allowed`
      );
      return this.#api;
    }

    // gain authorization from wallet owner
    const isAuthed = await this.#requestAccess();

    if (!isAuthed) {
      throw new ApiError(APIErrorCode.Refused, 'wallet not authorized.');
    }

    await this.#allowApplication(hostname);

    return this.#api;
  }
}
