import { AsyncKeyAgent } from '@cardano-sdk/key-management';
import { ObservableWallet, storage } from '@cardano-sdk/wallet';

export interface WalletManagerProps {
  walletName: string;
}

export interface WalletManagerActivateProps<P extends string | number = string, O = unknown> {
  /** User given name for the observableWallet being activated */
  observableWalletName: string;
  /**
   * Internal unique id calculated by {@link WalletManagerUi} based on the keyManager `chainId` and
   * the root public key hash.
   */
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
