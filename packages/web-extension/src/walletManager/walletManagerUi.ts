import { ObservableWallet } from '@cardano-sdk/wallet';
import { Shutdown } from '@cardano-sdk/util';

import { AsyncKeyAgent } from '@cardano-sdk/key-management';
import { MessengerDependencies, consumeRemoteApi } from '../messaging';
import { WalletManagerActivateProps, WalletManagerApi, WalletManagerProps } from './walletManager.types';
import { exposeKeyAgent } from '../keyAgent';
import { observableWalletProperties } from '../observableWallet';
import { walletChannel, walletManagerChannel, walletManagerProperties } from './util';

/**
 * Helper class for UI scripts.
 * Provides ObservableWallet activation/deactivation functionality while exposing a single ObservableWallet object.
 */
export class WalletManagerUi implements Shutdown, WalletManagerApi {
  #remoteApi: WalletManagerApi & Shutdown;
  #dependencies: MessengerDependencies;

  /**
   * Observable wallet. Its properties can be subscribed to at any point, even before activating a wallet.
   * All subscriptions emit values from the most recent activated wallet without having to resubscribe
   * when another wallet is activated.
   */
  wallet: ObservableWallet;

  constructor({ walletName }: WalletManagerProps, dependencies: MessengerDependencies) {
    this.#dependencies = dependencies;
    this.#remoteApi = consumeRemoteApi(
      { baseChannel: walletManagerChannel(walletName), properties: walletManagerProperties },
      dependencies
    );
    this.wallet = consumeRemoteApi(
      { baseChannel: walletChannel(walletName), properties: observableWalletProperties },
      dependencies
    );
  }

  /** {@link wallet} observable properties will emit from this new wallet */
  activate(props: WalletManagerActivateProps & { keyAgent: AsyncKeyAgent }): Promise<void> {
    const { keyAgent, observableWalletName, provider } = props;
    const { logger, runtime } = this.#dependencies;
    exposeKeyAgent(
      {
        keyAgent,
        walletName: observableWalletName
      },
      { logger, runtime }
    );

    // Do not pass the whole props object here.
    // It contains `keyAgent` and that causes errors in the remoteApi, probably because it's not part of the api
    return this.#remoteApi.activate({ observableWalletName, provider });
  }

  deactivate(): Promise<void> {
    return this.#remoteApi.deactivate();
  }

  clearStore(observableWalletName: string): Promise<void> {
    return this.#remoteApi.clearStore(observableWalletName);
  }

  /** Closes wallet and manager messaging channels */
  shutdown(): void {
    this.#remoteApi.shutdown();
    this.wallet.shutdown();
  }
}
