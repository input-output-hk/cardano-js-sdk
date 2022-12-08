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
import { env, logger } from '../util';
import { getWallet } from '../../../../src';
import { of } from 'rxjs';
import { runtime } from 'webextension-polyfill';
import { storage } from '@cardano-sdk/wallet';
import { walletName } from '../const';

/**
 * {@link WalletManagerActivateProps.provider} could be used to pass the necessary information
 * to construct providers for different networks.
 * Please check its documentation for examples.
 */
const walletFactory: WalletFactory = {
  create: async (
    props: WalletManagerActivateProps,
    { keyAgent, stores }: { keyAgent: AsyncKeyAgent; stores: storage.WalletStores }
  ) =>
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
  create: ({ observableWalletName }) => storage.createPouchDbWalletStores(observableWalletName, { logger })
};

export const wallet$ = (() => {
  const walletManager = new WalletManagerWorker({ walletName }, { logger, runtime, storesFactory, walletFactory });
  exposeApi(
    { api$: of(walletManager), baseChannel: walletManagerChannel(walletName), properties: walletManagerProperties },
    { logger, runtime }
  );
  return walletManager.activeWallet$;
})();
