import { ConnectWalletDependencies } from '@cardano-sdk/dapp-connector-client';
import {
  assetInfoHttpProvider,
  chainHistoryHttpProvider,
  handleHttpProvider,
  networkInfoHttpProvider,
  rewardsHttpProvider,
  stakePoolHttpProvider
} from '@cardano-sdk/cardano-services-client';
import { logger } from '@cardano-sdk/util-dev';

const httpProviderDependencies = {
  baseUrl: 'https://dev-preprod.lw.iog.io',
  logger
};

export const connectWalletDependencies: ConnectWalletDependencies = {
  assetProvider: assetInfoHttpProvider(httpProviderDependencies),
  chainHistoryProvider: chainHistoryHttpProvider(httpProviderDependencies),
  handleProvider: handleHttpProvider(httpProviderDependencies),
  logger,
  networkInfoProvider: networkInfoHttpProvider(httpProviderDependencies),
  rewardsProvider: rewardsHttpProvider(httpProviderDependencies),
  stakePoolProvider: stakePoolHttpProvider(httpProviderDependencies)
};
