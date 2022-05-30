import { SingleAddressWallet, storage } from '@cardano-sdk/wallet';
import {
  assetProvider,
  networkInfoProvider,
  stakePoolSearchProvider,
  txSubmitProvider,
  utxoProvider,
  walletProvider
} from './config';
import { consumeKeyAgent, exposeObservableWallet } from '@cardano-sdk/web-extension';
import { logger, walletName } from '../util';
import { runtime } from 'webextension-polyfill';

const keyAgent = consumeKeyAgent({ walletName }, { logger, runtime });

export const walletReady = (async () => {
  const wallet = new SingleAddressWallet(
    { name: walletName },
    {
      assetProvider: await assetProvider,
      keyAgent,
      logger,
      networkInfoProvider: await networkInfoProvider,
      stakePoolSearchProvider: await stakePoolSearchProvider,
      stores: storage.createPouchdbWalletStores(walletName, { logger }),
      txSubmitProvider: await txSubmitProvider,
      utxoProvider: await utxoProvider,
      walletProvider: await walletProvider
    }
  );
  exposeObservableWallet({ wallet, walletName }, { logger, runtime });
  return wallet;
})();
