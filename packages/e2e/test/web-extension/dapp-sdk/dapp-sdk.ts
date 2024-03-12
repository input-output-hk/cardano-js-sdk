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
import { connectToLace } from './features/connectLace';
import { sendCoins } from './features/sendCoins';
import { sendSeveralAssets } from './features/sendSeveralAssets';
import type { ObservableWallet } from '@cardano-sdk/wallet';

const logger = console;
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

document.querySelector('#connect-to-lace')?.addEventListener('click', () => {
  connectToLace({
    dependencies,
    logger,
    onWalletConnected: (wallet: ObservableWallet) => (connectedWallet = wallet)
  });
});

document.querySelector('#send-coins')?.addEventListener('click', async () => {
  if (!connectedWallet) {
    return logger.warn('Please connect the wallet first');
  }

  sendCoins({ connectedWallet });
});

document.querySelector('#send-several-assets')?.addEventListener('click', () => {
  if (!connectedWallet) {
    return logger.warn('Please connect the wallet first');
  }

  sendSeveralAssets({
    connectedWallet,
    logger
  });
});
