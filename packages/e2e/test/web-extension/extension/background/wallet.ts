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
import { consumeKeyAgent, exposeObservableWallet } from '@cardano-sdk/web-extension';
import { logger, walletName } from '../util';
import { runtime } from 'webextension-polyfill';

const keyAgent = consumeKeyAgent({ walletName }, { logger, runtime });

export const walletReady = (async () => {
  const wallet = new SingleAddressWallet(
    { name: walletName },
    {
      assetProvider: await assetProvider,
      chainHistoryProvider: await chainHistoryProvider,
      keyAgent,
      logger,
      networkInfoProvider: await networkInfoProvider,
      rewardsProvider: await rewardsProvider,
      stakePoolProvider: await stakePoolProvider,
      stores: storage.createPouchdbWalletStores(walletName, { logger }),
      txSubmitProvider: await txSubmitProvider,
      utxoProvider: await utxoProvider
    }
  );
  exposeObservableWallet({ wallet, walletName }, { logger, runtime });
  return wallet;
})();
