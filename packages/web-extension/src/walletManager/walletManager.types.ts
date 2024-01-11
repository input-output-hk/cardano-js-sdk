import { AnyWallet, WalletId } from './types';
import { Cardano } from '@cardano-sdk/core';
import { Observable } from 'rxjs';
import { ObservableWallet, storage } from '@cardano-sdk/wallet';
import { Witnesser } from '@cardano-sdk/key-management';

export interface WalletManagerProps {
  name: string;
}

export interface WalletManagerActivateProps<P extends string | number = string, O = unknown> {
  /** The walletId of the wallet to activate */
  walletId: WalletId;

  accountIndex?: number;

  /** The chainId of the network to activate the wallet in */
  chainId: Cardano.ChainId;

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
  activeWalletId$: Observable<WalletManagerActivateProps>;

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

  /**
   * Deactivate wallet. Wallet observable properties will emit only after a new wallet is {@link activate}ed.
   * The wallet store will be reused if the wallet is reactivated.
   */
  deactivate(): Promise<void>;

  /**
   * Destroy the specified store so that a future activation of the same wallet creates a new store.
   *
   * This method will destroy all stores for all accounts for the given ChainId.
   *
   * @param walletId The walletId of the wallet to destroy.
   * @param chainId The chainId of the network to destroy the wallet in.
   */
  destroyData(walletId: WalletId, chainId: Cardano.ChainId): Promise<void>;
}

export interface WalletFactory<Metadata extends { name: string }> {
  create: (
    props: WalletManagerActivateProps,
    wallet: AnyWallet<Metadata>,
    dependencies: { witnesser: Witnesser; stores: storage.WalletStores }
  ) => Promise<ObservableWallet>;
}

export interface StoresFactory {
  create: (props: { name: string }) => storage.WalletStores;
}
