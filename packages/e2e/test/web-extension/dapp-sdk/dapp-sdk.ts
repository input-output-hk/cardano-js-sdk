/* eslint-disable @typescript-eslint/no-explicit-any */
import { ConnectWalletDependencies } from '@cardano-sdk/dapp-connector-client';
import {
  assetInfoHttpProvider,
  chainHistoryHttpProvider,
  handleHttpProvider,
  networkInfoHttpProvider,
  rewardsHttpProvider,
  stakePoolHttpProvider
} from '@cardano-sdk/cardano-services-client';

import { connectToLace, sendCoins, sendSeveralAssets, singleDelegation, singleUndelegation } from './features';
import { logger } from '@cardano-sdk/util-dev';
import type { ObservableWallet } from '@cardano-sdk/wallet';

const httpProviderDependencies = {
  baseUrl: 'https://dev-preprod.lw.iog.io',
  logger
};

const dependencies: ConnectWalletDependencies = {
  assetProvider: assetInfoHttpProvider(httpProviderDependencies),
  chainHistoryProvider: chainHistoryHttpProvider(httpProviderDependencies),
  handleProvider: handleHttpProvider(httpProviderDependencies),
  logger,
  networkInfoProvider: networkInfoHttpProvider(httpProviderDependencies),
  rewardsProvider: rewardsHttpProvider(httpProviderDependencies),
  stakePoolProvider: stakePoolHttpProvider(httpProviderDependencies)
};

let connectedWallet: ObservableWallet | null;

const CONNECT_WALLET = 'Please connect the wallet first';

document.querySelector('#connect-to-lace')?.addEventListener('click', () => {
  connectToLace({
    dependencies,
    logger,
    onWalletConnected: (wallet: ObservableWallet) => (connectedWallet = wallet)
  });
});

document.querySelector('#send-coins')?.addEventListener('click', async () => {
  if (!connectedWallet) {
    return logger.warn(CONNECT_WALLET);
  }

  await sendCoins({ connectedWallet });
});

document.querySelector('#send-several-assets')?.addEventListener('click', () => {
  if (!connectedWallet) {
    return logger.warn(CONNECT_WALLET);
  }

  sendSeveralAssets({
    connectedWallet,
    logger
  });
});

document.querySelector('#single-delegation')?.addEventListener('click', () => {
  if (!connectedWallet) {
    return logger.warn(CONNECT_WALLET);
  }

  singleDelegation({
    connectedWallet,
    logger
  });
});

document.querySelector('#single-undelegation')?.addEventListener('click', () => {
  if (!connectedWallet) {
    return logger.warn(CONNECT_WALLET);
  }

  singleUndelegation({
    connectedWallet,
    logger
  });
});
