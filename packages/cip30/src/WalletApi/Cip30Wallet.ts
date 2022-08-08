import { APIErrorCode, ApiError } from '../errors';
import { Logger } from 'ts-log';
import { RemoteAuthenticator } from '../AuthenticatorApi';
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

export type WalletProperties = { icon: WalletIcon; walletName: WalletName };

export type WalletDependencies = {
  logger: Logger;
  authenticator: RemoteAuthenticator;
  api: WalletApi;
};

/**
 * CIP-30 wallet that is injected to page
 */
export class Cip30Wallet {
  readonly apiVersion: ApiVersion = '0.1.0';
  readonly name: WalletName;
  readonly icon: WalletIcon;

  readonly #logger: Logger;
  readonly #api: WalletApi;
  readonly #authenticator: RemoteAuthenticator;

  constructor(properties: WalletProperties, { api, authenticator, logger }: WalletDependencies) {
    this.enable = this.enable.bind(this);
    this.icon = properties.icon;
    this.isEnabled = this.isEnabled.bind(this);
    this.name = properties.walletName;
    this.#api = api;
    this.#logger = logger;
    this.#authenticator = authenticator;
  }

  /**
   * Returns true if the dApp is already connected to the user's wallet, or if requesting access
   * would return true without user confirmation (e.g. the dApp is allowed), and false otherwise.
   *
   * If this function returns true, then any subsequent calls to wallet.enable()
   * during the current session should succeed and return the API object.
   *
   * Errors: `ApiError`
   */
  public async isEnabled(): Promise<Boolean> {
    return this.#authenticator.haveAccess();
  }

  /**
   * This is the entrypoint to start communication with the user's wallet.
   *
   * The wallet should request the user's permission to connect the web page to the user's wallet,
   * and if permission has been granted, the full API will be returned to the dApp to use.
   *
   * The wallet can choose to maintain the allow list to not necessarily ask the user's permission
   * every time access is requested, but this behavior is up to the wallet and should be transparent
   * to web pages using this API.
   *
   * If a wallet is already connected this function should not request access a second time,
   * and instead just return the API object.
   *
   * Errors: `ApiError`
   */
  public async enable(): Promise<WalletApi> {
    if (await this.#authenticator.requestAccess()) {
      this.#logger.debug(`${location.origin} has been granted access to wallet api`);
      return this.#api;
    }

    this.#logger.debug(`${location.origin} not authorized to access wallet api`);
    throw new ApiError(APIErrorCode.Refused, 'wallet not authorized.');
  }
}

export const WalletApiMethodNames: (keyof WalletApi)[] = [
  'getNetworkId',
  'getUtxos',
  'getCollateral',
  'getBalance',
  'getUsedAddresses',
  'getUnusedAddresses',
  'getChangeAddress',
  'getRewardAddresses',
  'signTx',
  'signData',
  'submitTx'
];
