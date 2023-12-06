import * as Crypto from '@cardano-sdk/crypto';
import { AsyncKeyAgent } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { Observable } from 'rxjs';
import { ObservableWallet, storage } from '@cardano-sdk/wallet';

export interface WalletManagerProps {
  walletName: string;
}

/** The wallet type */
export enum WalletType {
  MultiSignature = 'MultiSignature',
  SingleSignature = 'SingleSignature'
}

/** The multi signature wallet type */
export enum MultiSignatureWalletType {
  RequireAllSignatures = 'RequireAllSignatures',
  RequireAnySignaturesOf = 'RequireAnySignaturesOf',
  RequireNSignaturesOf = 'RequireNSignaturesOf'
}

/** The single signature wallet properties */
export type SingleSignatureWalletProps = {
  __type: WalletType.SingleSignature;

  /** The public key of the wallet */
  accountIndex: number;
};

/** The multi signature wallet properties */
export type MultiSignatureWalletProps = {
  __type: WalletType.MultiSignature;

  /** The public keys of the participants */
  participants: Array<Crypto.Ed25519PublicKeyHex>;

  /** The multi signature wallet type */
  type: MultiSignatureWalletType;

  /** Only required when the wallet type is `RequireNSignaturesOf`. */
  n?: number;
};

/** The wallet properties */
export type WalletProps = SingleSignatureWalletProps | MultiSignatureWalletProps;

export interface WalletManagerActivateProps<P extends string | number = string, O = unknown> {
  /** User given name for the observableWallet being activated */
  observableWalletName: string;

  /** The wallet type */
  walletProps: WalletProps;

  /** Internal unique id calculated of the wallet. */
  walletId: string;

  /**
   * `provider` could be used to pass the necessary information to construct providers for different networks.
   * Its value is passed to the {@link WalletFactory}, which is required to create {@link WalletManagerWorker}.
   * The structure is in the hands of the user and depends on how the {@link WalletFactory} is implemented.
   * An example of what a provider data could look like:
   * ```ts
   *  props.provider = {
   *    type: ProviderType.CardanoServices,
   *    options: {cardanoServicesUrl: 'https://preview-api.mydomain.io'}
   *   }
   * ```
   * Another example using a mix of provider types:
   * ```ts
   * walletManager.activate({
   *   observableWalletName: 'MixedProvidersOnTestnet',
   *   provider: {
   *     options: {
   *       providers: [
   *         // WalletFactory will use this data to create a cardano-services-client ogmiosTxSubmitProvider
   *         { connectionConfig: ConnectionConfig, type: ProviderType.OgmiosTxSubmit },
   *         // WalletFactory will use this data to create the rest of the services
   *         { baseUrl: 'https://preview-api.mydomain.io', type: ProviderType.CardanoServices }
   *       ]
   *     },
   *     type: ProviderType.Mixed
   *   }
   * })
   * ```
   */
  provider?: { type: P; options: O };
}

export interface WalletManagerApi {
  /**
   * Create and activate a new ObservableWallet.
   * Reuses the store if the wallet was previously deactivated but not destroyed.
   */
  activate(props: WalletManagerActivateProps): Promise<void>;

  /**
   * Switches the network of the active wallet.
   *
   * @param id The chain id of the network to switch to.
   */
  switchNetwork(id: Cardano.ChainId): Promise<void>;

  /** Returns an observable that emits the chain id when it changes. */
  chainIdChanges(): Observable<Cardano.ChainId>;

  /**
   * Deactivate wallet. Wallet observable properties will emit only after a new wallet is {@link activate}ed.
   * The wallet store will be reused if the wallet is reactivated.
   */
  deactivate(): Promise<void>;

  /**
   * Deactivates the active wallet and destroy its existing store,
   * so that a future activation of the same wallet creates a new store.
   */
  destroy(): Promise<void>;
}

export interface WalletFactory {
  create: (
    props: WalletManagerActivateProps,
    dependencies: { keyAgent: AsyncKeyAgent; stores: storage.WalletStores }
  ) => Promise<ObservableWallet>;
}

export interface StoresFactory {
  create: (props: Pick<WalletManagerActivateProps, 'walletId'>) => storage.WalletStores;
}
