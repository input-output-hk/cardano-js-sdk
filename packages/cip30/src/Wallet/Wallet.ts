import { APIErrorCode, ApiError } from '../errors';
import { Logger, dummyLogger } from 'ts-log';
import { storage, Storage } from 'webextension-polyfill';
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

  private allowList: string[];
  private logger: Logger;
  private readonly options: Required<WalletOptions>;

  private constructor(
    properties: WalletProperties,
    private api: WalletApi,
    private requestAccess: RequestAccess,
    allowList: string[],
    options?: WalletOptions
  ) {
    this.options = { ...defaultOptions, ...options };
    this.name = properties.name;
    this.apiVersion = properties.apiVersion;
    this.icon = properties.icon;
    this.allowList = allowList;
    this.logger = this.options.logger;
  }

  public getPublicApi(hostname: string) {
    return {
      apiVersion: this.apiVersion,
      enable: this.enable.bind(this, hostname),
      icon: this.icon,
      isEnabled: this.isEnabled.bind(this, hostname),
      name: this.name
    };
  }

  static async getAllowList(_storage?: Storage.LocalStorageArea): Promise<string[]> {
    if (!_storage) return Promise.resolve([]);
    try {
      const persistedStorage: Record<string, WalletStorage> = await _storage.get(this.name);
      return persistedStorage[this.name].allowList;
    } catch {
      return [];
    }
  }

  static async initialize(
    properties: WalletProperties,
    api: WalletApi,
    requestAccess: RequestAccess,
    options?: WalletOptions
  ) {
    const allowList = await this.getAllowList(options?.storage);

    return new Wallet(properties, api, requestAccess, allowList, options);
  }

  private async allowApplication(appName: string) {
    this.allowList.push(appName);

    // Todo: Encrypt

    await this.options.storage.set({ [this.name]: { allowList: [...this.allowList, appName] } });
    this.logger.debug(
      {
        allowList: this.allowList,
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
    return this.allowList.includes(hostname);
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
    if (this.allowList.includes(hostname)) {
      this.logger.debug(
        {
          module: 'Wallet',
          walletName: this.name
        },
        `${hostname} has previously been allowed`
      );
      return this.api;
    }

    // gain authorization from wallet owner
    const isAuthed = await this.requestAccess();

    if (!isAuthed) {
      throw new ApiError(APIErrorCode.Refused, 'wallet not authorized.');
    }

    await this.allowApplication(hostname);

    return this.api;
  }
}

export type WalletPublic = ReturnType<Wallet['getPublicApi']>;
