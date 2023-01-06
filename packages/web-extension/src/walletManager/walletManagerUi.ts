import { AsyncKeyAgent } from '@cardano-sdk/key-management';
import { ObservableWallet } from '@cardano-sdk/wallet';
import { Shutdown } from '@cardano-sdk/util';

import { MessengerDependencies, consumeRemoteApi } from '../messaging';
import { WalletManagerActivateProps, WalletManagerApi, WalletManagerProps } from './walletManager.types';
import { exposeKeyAgent } from '../keyAgent';
import { getWalletId, walletChannel, walletManagerChannel, walletManagerProperties } from './util';
import { observableWalletProperties } from '../observableWallet';

/**
 * Helper class for UI scripts.
 * Provides ObservableWallet activation/deactivation functionality while exposing a single ObservableWallet object.
 * Not implementing the {@link WalletManagerApi} interface is intentional. {@link WalletManagerApi} `activate` method
 * requires a unique `walletId`, which is calculated by {@link WalletManagerUi} before passing the message to
 * {@link WalletManagerWorker}. It is not meant to be calculated or maintained by the user.
 */
export class WalletManagerUi implements Shutdown {
  #remoteApi: WalletManagerApi & Shutdown;
  #dependencies: MessengerDependencies;
  #keyAgentApi: Shutdown | null = null;
  #activeWalletId: string | null = null;

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

  /**
   * Create and activate a new ObservableWallet.
   * Reuses the store if the wallet was previously deactivated but not destroyed.
   * {@link wallet} observable properties will emit from this new wallet
   */
  async activate(
    props: Pick<WalletManagerActivateProps, 'provider' | 'observableWalletName'> & { keyAgent: AsyncKeyAgent }
  ): Promise<void> {
    const { keyAgent, provider, observableWalletName } = props;
    const { logger, runtime } = this.#dependencies;
    const walletId = await getWalletId(keyAgent);

    if (this.#activeWalletId === walletId) {
      // Don't activate same wallet twice
      return Promise.resolve();
    }
    this.#activeWalletId = walletId;

    // activate could be called without calling deactivate first
    this.#shutdownKeyAgent();

    this.#keyAgentApi = exposeKeyAgent(
      {
        keyAgent,
        walletName: walletId // Not using observableWalletName because we want unique channels
      },
      { logger, runtime }
    );

    // Do not pass the whole props object here.
    // It contains `keyAgent` and that causes errors in the remoteApi, probably because it's not part of the api
    return this.#remoteApi.activate({ observableWalletName, provider, walletId });
  }

  /** {@link WalletManagerApi.deactivate} */
  deactivate(): Promise<void> {
    this.#activeWalletId = null;
    this.#shutdownKeyAgent();
    return this.#remoteApi.deactivate();
  }

  /** {@link WalletManagerApi.destroy} */
  destroy(): Promise<void> {
    this.#activeWalletId = null;
    this.#shutdownKeyAgent();
    return this.#remoteApi.destroy();
  }

  /** Closes wallet and manager messaging channels */
  shutdown(): void {
    this.#remoteApi.shutdown();
    this.wallet.shutdown();
    this.#shutdownKeyAgent();
  }

  #shutdownKeyAgent(): void {
    this.#keyAgentApi?.shutdown();
    this.#keyAgentApi = null;
  }
}
