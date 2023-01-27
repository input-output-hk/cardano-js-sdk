import { BehaviorSubject, Observable, filter, lastValueFrom } from 'rxjs';
import { Logger } from 'ts-log';
import { ObservableWallet, storage } from '@cardano-sdk/wallet';
import { Shutdown, isNotNil } from '@cardano-sdk/util';

import { MessengerDependencies, MinimalRuntime, exposeApi } from '../messaging';
import {
  StoresFactory,
  WalletFactory,
  WalletManagerActivateProps,
  WalletManagerApi,
  WalletManagerProps
} from './walletManager.types';
import { consumeKeyAgent } from '../keyAgent';
import { observableWalletProperties } from '../observableWallet';
import { walletChannel } from './util';

export interface WalletManagerDependencies {
  walletFactory: WalletFactory;
  storesFactory: StoresFactory;
}

/**
 * Helper class for background scripts using wallet manager.
 * Uses wallet and store factories to create wallets.
 * Keeps track of created stores and reuses them when a wallet is reactivated.
 */
export class WalletManagerWorker implements WalletManagerApi {
  activeWallet$: Observable<ObservableWallet>;

  #activeWalletId: string | null = null;
  #api$ = new BehaviorSubject<ObservableWallet | null>(null);
  #hostSubscription: Shutdown;
  #keyAgentSubscription: Shutdown;
  #walletStores = new Map<string, storage.WalletStores>();

  #walletFactory: WalletFactory;
  #storesFactory: StoresFactory;
  #logger: Logger;
  #runtime: MinimalRuntime;

  constructor(
    { walletName }: WalletManagerProps,
    { walletFactory, storesFactory, logger, runtime }: MessengerDependencies & WalletManagerDependencies
  ) {
    this.activeWallet$ = this.#api$.pipe(filter(isNotNil));
    this.#walletFactory = walletFactory;
    this.#storesFactory = storesFactory;
    this.#logger = logger;
    this.#runtime = runtime;
    this.#hostSubscription = exposeApi(
      {
        api$: this.#api$.asObservable(),
        baseChannel: walletChannel(walletName),
        properties: observableWalletProperties
      },
      { logger, runtime }
    );
  }

  async activate(props: WalletManagerActivateProps): Promise<void> {
    const { walletId } = props;
    if (this.#isActiveWallet(walletId)) {
      return;
    }
    this.#deactivateWallet();
    this.#activeWalletId = walletId;

    // Key agent is created by UI script on a per wallet unique channel derived from the keyAgent
    const keyAgent = consumeKeyAgent(
      { walletName: this.#activeWalletId },
      { logger: this.#logger, runtime: this.#runtime }
    );
    this.#keyAgentSubscription = keyAgent;
    const stores = this.#getStores(this.#activeWalletId);

    // Wallet factory is responsible for creating the wallet and the providers based on cardanoServicesUrl
    const wallet = await this.#walletFactory.create(props, { keyAgent, stores });
    this.#api$.next(wallet);
  }

  async deactivate(): Promise<void> {
    this.#deactivateWallet();
  }

  /**
   * Deactivates the active wallet and closes the remote api channels.
   */
  shutdown(): void {
    this.#deactivateWallet();

    this.#hostSubscription.shutdown();
    this.#api$.complete();
  }

  async destroy(): Promise<void> {
    await this.#destroyWalletStore();
    this.#deactivateWallet();
  }

  /** Gets store if wallet was activated previously or creates one when wallet is activated for the first time. */
  #getStores(walletId: string): storage.WalletStores {
    let stores = this.#walletStores.get(walletId);
    if (!stores) {
      stores = this.#storesFactory.create({ walletId });
      this.#walletStores.set(walletId, stores);
    }
    return stores;
  }

  async #destroyWalletStore(): Promise<void> {
    if (this.#activeWalletId) {
      const walletStore = this.#walletStores.get(this.#activeWalletId);
      // Added a defaultValue to avoid throw due to observable complete without emitting any values.
      if (walletStore) await lastValueFrom(walletStore.destroy(), { defaultValue: null });
      this.#walletStores.delete(this.#activeWalletId);
    }
  }

  #deactivateWallet(): void {
    const wallet = this.#api$?.getValue();
    // Consumers are subscribed to the wallet observable properties.
    // Do not shutdown the active wallet while these subscriptions are still coupled with the observed wallet.
    // Instead, first decouple the active wallet from the observed wallet.
    this.#stopEmittingFromActiveWallet();
    wallet?.shutdown();
    this.#keyAgentSubscription?.shutdown();
    this.#activeWalletId = null;
  }

  #hasActiveWallet(): boolean {
    return this.#activeWalletId !== null;
  }

  #isActiveWallet(walletId: string): boolean {
    return this.#activeWalletId === walletId;
  }

  #stopEmittingFromActiveWallet(): void {
    this.#hasActiveWallet() && this.#api$.next(null);
  }
}
