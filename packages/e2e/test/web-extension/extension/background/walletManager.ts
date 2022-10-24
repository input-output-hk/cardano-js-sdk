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
import { SingleAddressWallet, storage } from '@cardano-sdk/wallet';
import {
  assetProvider,
  chainHistoryProvider,
  networkInfoProvider,
  rewardsProvider,
  stakePoolProvider,
  txSubmitProvider,
  utxoProvider
} from './config';
import { logger, walletName } from '../util';
import { of } from 'rxjs';
import { runtime } from 'webextension-polyfill';

/**
 * {@link WalletManagerActivateProps.provider} could be used to pass the necessary information
 * to construct providers for different networks.
 * Please check its documentation for examples.
 */
const walletFactory: WalletFactory = {
  create: async (
    props: WalletManagerActivateProps,
    dependencies: { keyAgent: AsyncKeyAgent; stores: storage.WalletStores }
  ) =>
    new SingleAddressWallet(
      { name: props.observableWalletName },
      {
        assetProvider: await assetProvider,
        chainHistoryProvider: await chainHistoryProvider,
        keyAgent: dependencies.keyAgent,
        logger,
        networkInfoProvider: await networkInfoProvider,
        rewardsProvider: await rewardsProvider,
        stakePoolProvider: await stakePoolProvider,
        stores: dependencies.stores,
        txSubmitProvider: await txSubmitProvider,
        utxoProvider: await utxoProvider
      }
    )
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
