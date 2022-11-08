import { BehaviorSubject, Observable, filter } from 'rxjs';
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
  #api$ = new BehaviorSubject<ObservableWallet | null>(null);
  #hostSubscription: Shutdown;
  #keyAgentSubscription: Shutdown;
  #walletStores = new Map<string, storage.WalletStores>();

  #walletFactory: WalletFactory;
  #storesFactory: StoresFactory;
  #logger: Logger;
  #runtime: MinimalRuntime;

  activeWallet$: Observable<ObservableWallet>;

  constructor(
    { walletName }: WalletManagerProps,
    { walletFactory, storesFactory, logger, runtime }: MessengerDependencies & WalletManagerDependencies
  ) {
    this.activeWallet$ = this.#api$.pipe(filter(isNotNil));
    this.#walletFactory = walletFactory;
    this.#storesFactory = storesFactory;
    this.#logger = logger;
    this.#runtime;
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
    const { observableWalletName } = props;
    if (await this.#isActive(observableWalletName)) {
      return;
    }
    this.#deactivateWallet();

    // Key agent is created by UI script on a per wallet unique channel
    const keyAgent = consumeKeyAgent(
      { walletName: observableWalletName },
      { logger: this.#logger, runtime: this.#runtime }
    );
    this.#keyAgentSubscription = keyAgent;
    const stores = this.#getStores(observableWalletName);

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

  async clearStore(observableWalletName: string): Promise<void> {
    if (!(await this.#isActive(observableWalletName))) {
      this.#walletStores.delete(observableWalletName);
    }
  }

  /** Gets store if wallet was activated previously or creates one when wallet is activated for the first time. */
  #getStores(observableWalletName: string): storage.WalletStores {
    let stores = this.#walletStores.get(observableWalletName);
    if (!stores) {
      stores = this.#storesFactory.create({ observableWalletName });
      this.#walletStores.set(observableWalletName, stores);
    }
    return stores;
  }

  async #isActive(observableWalletName: string): Promise<boolean> {
    return (await this.#api$.value?.getName()) === observableWalletName;
  }

  #deactivateWallet(): void {
    const wallet = this.#api$?.getValue();
    // Consumers are subscribed to the wallet observable properties.
    // Do not shutdown the active wallet while these subscriptions are still coupled with the observed wallet.
    // Instead, first decouple the active wallet from the observed wallet.
    this.#stopEmittingFromActiveWallet();
    wallet?.shutdown();
    this.#keyAgentSubscription?.shutdown();
  }

  #hasActiveWallet(): boolean {
    return isNotNil(this.#api$.getValue());
  }

  #stopEmittingFromActiveWallet(): void {
    this.#hasActiveWallet() && this.#api$.next(null);
  }
}
