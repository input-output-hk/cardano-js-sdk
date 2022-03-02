import { APIErrorCode, ApiError } from '../errors';
import { Logger, dummyLogger } from 'ts-log';
import { WalletApi } from './types';
import { WindowMaybeWithCardano } from '../injectWindow';

/**
 * CIP30 API version
 */
export type ApiVersion = string;

/**
 * Unique identifier, used to inject into the cardano namespace
 */
export type WalletName = string;

/**
 * A URI image (e.g. data URI base64 or other) for img src for the wallet which can be used inside of the dApp for the purpose of asking the user which wallet they would like to connect with.
 */
export type WalletIcon = string;

export type WalletProperties = { name: WalletName; apiVersion: ApiVersion; icon: WalletIcon };

/**
 * Resolve true to authorise access to the WalletAPI, or resolve false to deny.
 *
 * Errors: `ApiError`
 */
export type RequestAccess = () => Promise<boolean>;

export type WalletOptions = {
  logger?: Logger;
  persistAllowList?: boolean;
  storage?: Storage;
};

const defaultOptions = {
  logger: dummyLogger,
  persistAllowList: false,
  storage: window.localStorage
};

export class Wallet {
  readonly apiVersion: ApiVersion;
  readonly name: WalletName;
  readonly icon: WalletIcon;

  private allowList: string[];
  private logger: Logger;
  private readonly options: Required<WalletOptions>;

  constructor(
    properties: WalletProperties,
    private api: WalletApi,
    private requestAccess: RequestAccess,
    options?: WalletOptions
  ) {
    this.options = { ...defaultOptions, ...options };
    this.name = properties.name;
    this.apiVersion = properties.apiVersion;
    this.icon = properties.icon;
    this.allowList = this.options.persistAllowList ? this.getAllowList() : [];
    this.logger = this.options.logger;
  }

  public getPublicApi(window: WindowMaybeWithCardano) {
    return {
      enable: this.enable.bind(this, window),
      isEnabled: this.isEnabled.bind(this, window),
      name: this.name,
      apiVersion: this.apiVersion,
      icon: this.icon
    };
  }

  private getAllowList(): string[] {
    // JSON.parse(null) seems to be legit
    return JSON.parse(this.options.storage.getItem(this.name)!) || [];
  }

  private allowApplication(appName: string) {
    this.allowList.push(appName);

    if (this.options.persistAllowList) {
      const currentList = this.getAllowList();
      // Todo: Encrypt
      this.options.storage?.setItem(this.name, JSON.stringify([...currentList, appName]));
      this.logger.debug(
        {
          allowList: this.getAllowList(),
          module: 'Wallet',
          walletName: this.name
        },
        'Allow list persisted'
      );
    }
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
  public async isEnabled(window: WindowMaybeWithCardano): Promise<Boolean> {
    const appName = window.location.hostname;
    return this.allowList.includes(appName);
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
  public async enable(window: WindowMaybeWithCardano): Promise<WalletApi> {
    const appName = window.location.hostname;

    if (this.options.persistAllowList && this.allowList.includes(appName)) {
      this.logger.debug(
        {
          module: 'Wallet',
          walletName: this.name
        },
        `${appName} has previously been allowed`
      );
      return this.api;
    }

    // gain authorization from wallet owner
    const isAuthed = await this.requestAccess();

    if (!isAuthed) {
      throw new ApiError(APIErrorCode.Refused, 'wallet not authorized.');
    }

    this.allowApplication(appName);

    return this.api;
  }
}

export type WalletPublic = ReturnType<Wallet['getPublicApi']>;
