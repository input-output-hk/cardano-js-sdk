import { APIErrorCode, ApiError } from '../errors';
import {
  Bytes,
  Cbor,
  Cip30WalletApiWithPossibleExtensions,
  CipExtensionApis,
  Paginate,
  WalletApi,
  WalletApiExtension,
  WalletMethod
} from './types';
import { Cardano } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { RemoteAuthenticator } from '../AuthenticatorApi';

export const CipMethodsMapping: Record<number, WalletMethod[]> = {
  30: [
    'getNetworkId',
    'getUtxos',
    'getCollateral',
    'getBalance',
    'getExtensions',
    'getUsedAddresses',
    'getUnusedAddresses',
    'getChangeAddress',
    'getRewardAddresses',
    'signTx',
    'signData',
    'submitTx'
  ],
  95: ['getRegisteredPubStakeKeys', 'getUnregisteredPubStakeKeys', 'getPubDRepKey']
};
export const WalletApiMethodNames: WalletMethod[] = Object.values(CipMethodsMapping).flat();

/** CIP30 API version */
export type ApiVersion = string;

/** Unique identifier, used to inject into the cardano namespace */
export type WalletName = string;

/**
 * A URI image (e.g. data URI base64 or other) for img src for the wallet
 * which can be used inside of the dApp for the purpose of asking the user
 * which wallet they would like to connect with.
 */
export type WalletIcon = string;

export type WalletProperties = {
  icon: WalletIcon;
  walletName: WalletName;
  supportedExtensions?: WalletApiExtension[];
  /** Deviations from the CIP30 spec */
  cip30ApiDeviations?: {
    /**
     * Instead of throwing an error when no collateral is found, return empty array.
     * This is the way the Nami wallet works and some DApps rely on it (i.e. https://app.indigoprotocol.io/)
     */
    getCollateralEmptyArray?: boolean;
    /**
     * Add the `on` and `off` methods to the experimental object.
     * The methods do not have an implementation, but are used to satisfy
     * some DApps that expect them to be present.
     */
    onOffDummyMethods?: boolean;
  };
};

export type WalletDependencies = {
  logger: Logger;
  authenticator: RemoteAuthenticator;
  api: WalletApi;
};

export type Cip30EnableOptions = { extensions: WalletApiExtension[] };

/** CIP-30 wallet that is injected to page */
export class Cip30Wallet {
  readonly apiVersion: ApiVersion = '0.1.0';
  readonly name: WalletName;
  readonly icon: WalletIcon;
  /** Support the full api by default */
  readonly supportedExtensions: WalletApiExtension[] = [{ cip: 95 }];

  readonly #logger: Logger;
  readonly #api: WalletApi;
  readonly #authenticator: RemoteAuthenticator;
  readonly #deviations: WalletProperties['cip30ApiDeviations'];

  constructor(properties: WalletProperties, { api, authenticator, logger }: WalletDependencies) {
    this.icon = properties.icon;
    this.name = properties.walletName;
    this.#api = api;
    this.#logger = logger;
    this.#authenticator = authenticator;
    this.#deviations = properties.cip30ApiDeviations;
    this.enable = this.enable.bind(this);
    this.isEnabled = this.isEnabled.bind(this);
    if (properties.supportedExtensions) {
      this.supportedExtensions = properties.supportedExtensions;
    }
  }

  #validateExtensions(extensions: WalletApiExtension[] = []): void {
    if (
      !Array.isArray(extensions) ||
      extensions.some(
        (extension) =>
          !extension || typeof extension !== 'object' || !extension.cip || Number.isNaN(Number(extension.cip))
      )
    ) {
      this.#logger.debug(`Invalid extensions: ${extensions}`);
      throw new ApiError(APIErrorCode.InvalidRequest, `invalid extensions ${extensions}`);
    }
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
  public async enable(options?: Cip30EnableOptions): Promise<Cip30WalletApiWithPossibleExtensions> {
    this.#validateExtensions(options?.extensions);

    if (await this.#authenticator.requestAccess()) {
      this.#logger.debug(`${location.origin} has been granted access to wallet api`);
      const extensions = options?.extensions?.filter(({ cip: requestedCip }) =>
        this.supportedExtensions.some(({ cip: supportedCip }) => supportedCip === requestedCip)
      );
      return this.#wrapAndEnableApi(extensions);
    }
    this.#logger.debug(`${location.origin} not authorized to access wallet api`);
    throw new ApiError(APIErrorCode.Refused, 'wallet not authorized.');
  }

  async #wrapGetCollateral(params?: { amount?: Cbor }) {
    const collateral = await this.#api.getCollateral(params);
    return this.#deviations?.getCollateralEmptyArray ? collateral ?? [] : collateral;
  }

  /**
   * Wrap the proxy API object with a regular javascript object to avoid interop issues with some dApps.
   *
   * Only return the allowed API methods.
   */
  #wrapAndEnableApi(enabledExtensions?: WalletApiExtension[]): Cip30WalletApiWithPossibleExtensions {
    const walletApi = this.#api;
    const baseApi: Cip30WalletApiWithPossibleExtensions = {
      // Add experimental.getCollateral to CIP-30 API
      experimental: {
        getCollateral: async (params?: { amount?: Cbor }) => this.#wrapGetCollateral(params),
        ...(this.#deviations?.onOffDummyMethods && { off: () => void 0, on: () => void 0 })
      },
      getBalance: () => walletApi.getBalance(),
      getChangeAddress: () => walletApi.getChangeAddress(),
      getCollateral: (params?: { amount?: Cbor }) => this.#wrapGetCollateral(params),
      getExtensions: () => Promise.resolve(enabledExtensions || []),
      getNetworkId: () => walletApi.getNetworkId(),
      getRewardAddresses: () => walletApi.getRewardAddresses(),
      getUnusedAddresses: () => walletApi.getUnusedAddresses(),
      getUsedAddresses: (paginate?: Paginate) => walletApi.getUsedAddresses(paginate),
      getUtxos: (amount?: Cbor, paginate?: Paginate) => walletApi.getUtxos(amount, paginate),
      signData: (addr: Cardano.PaymentAddress | Bytes, payload: Bytes) => walletApi.signData(addr, payload),
      signTx: (tx: Cbor, partialSign?: Boolean) => walletApi.signTx(tx, partialSign),
      submitTx: (tx: Cbor) => walletApi.submitTx(tx)
    };

    const additionalCipApis: CipExtensionApis = {
      cip95: {
        getPubDRepKey: () => walletApi.getPubDRepKey(),
        getRegisteredPubStakeKeys: () => walletApi.getRegisteredPubStakeKeys(),
        getUnregisteredPubStakeKeys: () => walletApi.getUnregisteredPubStakeKeys()
      }
    };

    if (enabledExtensions) {
      for (const extension of enabledExtensions) {
        const cipName = `cip${extension.cip}` as keyof CipExtensionApis;
        if (additionalCipApis[cipName]) {
          baseApi[cipName] = additionalCipApis[cipName];
        }
      }
    }

    return baseApi;
  }
}
