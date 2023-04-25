import {
  StoresFactory,
  WalletFactory,
  WalletManagerActivateProps,
  WalletManagerWorker,
  exposeApi,
  walletManagerChannel,
  walletManagerProperties
} from '@cardano-sdk/web-extension';

import { AsyncKeyAgent } from '@cardano-sdk/key-management';
import { storage as WebExtensionStorage, runtime } from 'webextension-polyfill';
import { env, logger } from '../util';
import { from, merge, of } from 'rxjs';
import { getWallet } from '../../../../src';
import { storage } from '@cardano-sdk/wallet';
import { toEmpty } from '@cardano-sdk/util-rxjs';
import { walletName } from '../const';

export interface WalletFactoryDependencies {
  keyAgent: AsyncKeyAgent;
  stores: storage.WalletStores;
}

/**
 * {@link WalletManagerActivateProps.provider} could be used to pass the necessary information
 * to construct providers for different networks.
 * Please check its documentation for examples.
 */
const walletFactory: WalletFactory = {
  create: async (props: WalletManagerActivateProps, { keyAgent, stores }: WalletFactoryDependencies) =>
    (
      await getWallet({
        env,
        keyAgent,
        logger,
        name: props.observableWalletName,
        stores
      })
    ).wallet
};

const storesFactory: StoresFactory = {
  create: ({ walletId }) => storage.createPouchDbWalletStores(walletId, { logger })
};

export const wallet$ = (() => {
  const walletManager = new WalletManagerWorker(
    { walletName },
    { logger, managerStorage: WebExtensionStorage.local, runtime, storesFactory, walletFactory }
  );
  exposeApi(
    { api$: of(walletManager), baseChannel: walletManagerChannel(walletName), properties: walletManagerProperties },
    { logger, runtime }
  );
  return merge(walletManager.activeWallet$, from(walletManager.initialize()).pipe(toEmpty));
})();
