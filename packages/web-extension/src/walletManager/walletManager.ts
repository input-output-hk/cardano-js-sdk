import {
  AccountKeyDerivationPath,
  MessageSender,
  SignTransactionContext,
  WitnessOptions,
  Witnesser
} from '@cardano-sdk/key-management';
import { AnyBip32Wallet, AnyWallet, WalletId, WalletType } from './types';
import { BehaviorSubject, ReplaySubject, firstValueFrom, lastValueFrom } from 'rxjs';
import { Cardano, Serialization } from '@cardano-sdk/core';
import { HexBlob, InvalidArgumentError, deepEquals } from '@cardano-sdk/util';
import { Logger } from 'ts-log';
import { MessengerDependencies } from '../messaging';
import { ObservableWallet, storage } from '@cardano-sdk/wallet';
import { SignerManagerSignApi } from './SignerManager';
import { Storage } from 'webextension-polyfill';
import {
  StoresFactory,
  WalletFactory,
  WalletManagerActivateProps,
  WalletManagerApi,
  WalletManagerProps
} from './walletManager.types';
import { WalletRepository } from './WalletRepository';

/**
 * Checks if the wallet is a bip32 wallet.
 *
 * @param wallet The wallet to check.
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const isAnyBip32Wallet = (wallet: AnyWallet<any>): wallet is AnyBip32Wallet<any> =>
  wallet.type === WalletType.InMemory || wallet.type === WalletType.Ledger || wallet.type === WalletType.Trezor;

export const getWalletStoreId = (walletId: WalletId, chainId: Cardano.ChainId, accountIndex?: number): string => {
  // Index 0 should be backwards compatible (so it should never have the account index concatenated).
  if (accountIndex !== undefined && accountIndex !== 0) {
    return `${chainId.networkId}-${chainId.networkMagic}-${walletId}-${accountIndex}`;
  }

  return `${chainId.networkId}-${chainId.networkMagic}-${walletId}`;
};

export interface WalletManagerDependencies<Metadata extends { name: string }> {
  walletFactory: WalletFactory<Metadata>;
  storesFactory: StoresFactory;
  managerStorage: Storage.StorageArea;
  walletRepository: WalletRepository<Metadata>;
  signerManagerApi: SignerManagerSignApi<Metadata>;
}

/**
 * Helper class for background scripts using wallet manager.
 * Uses wallet and store factories to create wallets.
 * Keeps track of created stores and reuses them when a wallet is reactivated.
 */
export class WalletManager<Metadata extends { name: string }> implements WalletManagerApi {
  activeWalletId$ = new ReplaySubject<WalletManagerActivateProps | null>(1);
  activeWallet$ = new BehaviorSubject<ObservableWallet | null>(null);

  #activeWalletProps: WalletManagerActivateProps | null = null;
  #walletStores = new Map<string, storage.WalletStores>();
  #walletFactory: WalletFactory<Metadata>;
  #storesFactory: StoresFactory;
  #walletRepository: WalletRepository<Metadata>;
  #signerManagerApi: SignerManagerSignApi<Metadata>;
  #logger: Logger;
  #managerStorageKey: string;
  #managerStorage: Storage.StorageArea;

  constructor(
    { name }: WalletManagerProps,
    {
      walletFactory,
      storesFactory,
      logger,
      managerStorage,
      walletRepository,
      signerManagerApi
    }: MessengerDependencies & WalletManagerDependencies<Metadata>
  ) {
    this.#walletRepository = walletRepository;

    this.#walletFactory = walletFactory;
    this.#managerStorageKey = `${name}-active-wallet`;
    this.#managerStorage = managerStorage;
    this.#storesFactory = storesFactory;
    this.#logger = logger;
    this.#signerManagerApi = signerManagerApi;
  }

  /**
   * Switches the network of the active wallet.
   *
   * @param id The network id to switch to.
   */
  switchNetwork(id: Cardano.ChainId): Promise<void> {
    if (!this.#hasActiveWallet()) return Promise.resolve();

    const props = { ...this.#activeWalletProps!, chainId: id };
    return this.activate(props);
  }

  /** `activate` the wallet with props of last activated wallet (load from `managerStorage`) */
  async initialize() {
    const { [this.#managerStorageKey]: lastActivateProps } = await this.#managerStorage.get(this.#managerStorageKey);

    if (!lastActivateProps) {
      this.activeWalletId$.next(null);
      return;
    }

    return this.activate(lastActivateProps);
  }

  /**
   * Create and activate a new ObservableWallet.
   *
   * @param props The properties of the wallet to activate.
   */
  async activate(props: WalletManagerActivateProps): Promise<void> {
    if (this.#isActive(props)) {
      return;
    }

    const { walletId, chainId, accountIndex } = props;

    const wallets = await firstValueFrom(this.#walletRepository.wallets$);
    const activeWallet = wallets.find((wallet) => wallet.walletId === walletId);

    if (!activeWallet) {
      throw new InvalidArgumentError('walletId', `Wallet ${walletId} not found`);
    }

    this.#deactivateWallet();
    this.#activeWalletProps = props;

    const walletStoreId = getWalletStoreId(walletId, chainId, accountIndex);
    const stores = this.#getStores(walletStoreId);

    const witnesser = this.#buildWitnesser(activeWallet, walletId, chainId, accountIndex);

    const [wallet] = await Promise.all([
      this.#walletFactory.create(props, activeWallet, { stores, witnesser }),
      this.#managerStorage.set({
        [this.#managerStorageKey]: props
      })
    ]);

    this.activeWallet$.next(wallet);

    this.activeWalletId$.next(props);
  }

  /** Deactivate wallet. Wallet observable properties will emit only after a new wallet is {@link activate}ed. */
  async deactivate(): Promise<void> {
    this.#deactivateWallet();
  }

  /** Deactivates the active. */
  shutdown(): void {
    this.#deactivateWallet();
  }

  /**
   * Deactivates the active wallet and destroy its existing store.
   *
   * @param walletId The walletId of the wallet to destroy.
   * @param chainId The chainId of the wallet to destroy.
   */
  async destroyData(walletId: WalletId, chainId: Cardano.ChainId): Promise<void> {
    await this.#destroyWalletStores(walletId, chainId);
  }

  /**
   * Checks if the wallet is active.
   *
   * @param walletProps The wallet properties to check.
   * @private
   */
  #isActive(walletProps: WalletManagerActivateProps): boolean {
    if (!this.#activeWalletProps) return false;

    return (
      this.#activeWalletProps?.walletId === walletProps.walletId &&
      this.#activeWalletProps?.accountIndex === walletProps.accountIndex &&
      deepEquals(this.#activeWalletProps?.chainId, walletProps.chainId)
    );
  }

  /** Gets store if wallet was activated previously or creates one when wallet is activated for the first time. */
  #getStores(walletStoreName: string): storage.WalletStores {
    let stores = this.#walletStores.get(walletStoreName);
    if (!stores) {
      stores = this.#storesFactory.create({ name: walletStoreName });
      this.#walletStores.set(walletStoreName, stores);
    }
    return stores;
  }

  /**
   * Destroys all stores for the given wallet id.
   *
   * @param walletId The wallet id to destroy.
   * @param chainId The chain id to destroy.
   * @private
   */
  async #destroyWalletStores(walletId: WalletId, chainId: Cardano.ChainId): Promise<void> {
    if (this.#activeWalletProps?.walletId === walletId)
      throw new InvalidArgumentError('walletId', 'Cannot destroy active wallet');

    const knownWallets = await firstValueFrom(this.#walletRepository.wallets$);

    const storeIds = knownWallets
      .flatMap((wallet) => {
        if (isAnyBip32Wallet(wallet)) {
          return wallet.accounts.map((account) => getWalletStoreId(wallet.walletId, chainId, account.accountIndex));
        }

        return getWalletStoreId(wallet.walletId, chainId);
      })
      .filter((id) => id.includes(walletId));

    if (!storeIds || storeIds.length === 0) return;

    for (const walletStoreId of storeIds) {
      const walletStores = this.#getStores(walletStoreId);

      this.#logger.debug(`Destroying wallet store ${walletStoreId}`);

      // Added a defaultValue to avoid throw due to observable complete without emitting any values.
      await lastValueFrom(walletStores.destroy(), { defaultValue: null });

      this.#walletStores.delete(walletStoreId);
    }
  }

  /**
   * Deactivates the active wallet.
   *
   * @private
   */
  #deactivateWallet(): void {
    const wallet = this.activeWallet$?.getValue();
    // Consumers are subscribed to the wallet observable properties.
    // Do not shutdown the active wallet while these subscriptions are still coupled with the observed wallet.
    // Instead, first decouple the active wallet from the observed wallet.
    this.#stopEmittingFromActiveWallet();
    wallet?.shutdown();
    this.#activeWalletProps = null;
  }

  /**
   * Checks if the wallet is active.
   *
   * @private
   */
  #hasActiveWallet(): boolean {
    return this.#activeWalletProps !== null;
  }

  /**
   * Stops emitting from the active wallet.
   *
   * @private
   */
  #stopEmittingFromActiveWallet(): void {
    this.#hasActiveWallet() && this.activeWallet$.next(null);
  }

  /**
   * Builds the witnesser for the given wallet.
   *
   * @param wallet The wallet to build the witnesser for.
   * @param _walletId The wallet id to build the witnesser for.
   * @param chainId The chain id to build the witnesser for.
   * @param accountIndex The account index to build the witnesser for.
   * @private
   */
  #buildWitnesser(
    wallet: AnyWallet<Metadata>,
    _walletId: WalletId,
    chainId: Cardano.ChainId,
    accountIndex?: number
  ): Witnesser {
    let witnesser;
    switch (wallet.type) {
      case WalletType.InMemory:
      case WalletType.Ledger:
      case WalletType.Trezor:
        witnesser = {
          signBlob: async (derivationPath: AccountKeyDerivationPath, blob: HexBlob, sender?: MessageSender) =>
            await this.#signerManagerApi.signData(
              {
                blob,
                derivationPath,
                signContext: { sender }
              },
              {
                accountIndex: accountIndex!,
                chainId,
                wallet
              }
            ),
          witness: async (tx: Serialization.Transaction, context: SignTransactionContext, options?: WitnessOptions) => {
            const signatures = await this.#signerManagerApi.signTransaction(
              {
                options,
                signContext: context,
                tx: tx.toCbor()
              },
              {
                accountIndex: accountIndex!,
                chainId,
                wallet
              }
            );
            return { signatures };
          }
        };
        break;
      case WalletType.Script:
      default:
        throw new InvalidArgumentError('walletType', `Wallet type '${wallet.type}' is not supported`);
    }

    return witnesser;
  }
}
