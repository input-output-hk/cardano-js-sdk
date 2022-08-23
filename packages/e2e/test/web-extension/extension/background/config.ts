/* eslint-disable sonarjs/no-small-switch */
/* eslint-disable no-console */
/* eslint-disable @typescript-eslint/no-explicit-any */
import * as envalid from 'envalid';
import {
  BlockFrostAPI,
  blockfrostAssetProvider,
  blockfrostChainHistoryProvider,
  blockfrostNetworkInfoProvider,
  blockfrostRewardsProvider,
  blockfrostTxSubmitProvider,
  blockfrostUtxoProvider
} from '@cardano-sdk/blockfrost';
import {
  assetInfoHttpProvider,
  chainHistoryHttpProvider,
  networkInfoHttpProvider,
  rewardsHttpProvider,
  txSubmitHttpProvider,
  utxoHttpProvider
} from '@cardano-sdk/cardano-services-client';
import { createConnectionObject } from '@cardano-ogmios/client';
import { createStubStakePoolProvider } from '@cardano-sdk/util-dev';
import { ogmiosTxSubmitProvider } from '@cardano-sdk/ogmios';
import axiosFetchAdapter from '@vespaiach/axios-fetch-adapter';

const networkIdOptions = [0, 1];
const stakePoolProviderOptions = ['stub', 'http'];
const networkInfoProviderOptions = ['blockfrost', 'http'];
const txSubmitProviderOptions = ['blockfrost', 'http'];
const assetProviderOptions = ['blockfrost', 'http'];
const utxoProviderOptions = ['blockfrost', 'http'];
const rewardsProviderOptions = ['blockfrost', 'http'];
const chainHistoryProviderOptions = ['blockfrost', 'http'];

const env = envalid.cleanEnv(process.env, {
  ASSET_PROVIDER: envalid.str({ choices: assetProviderOptions }),
  ASSET_PROVIDER_PARAMS: envalid.json({ default: {} }),
  BLOCKFROST_API_KEY: envalid.str(),
  CHAIN_HISTORY_PROVIDER: envalid.str({ choices: chainHistoryProviderOptions }),
  CHAIN_HISTORY_PROVIDER_PARAMS: envalid.json({ default: {} }),
  LOGGER_MIN_SEVERITY: envalid.str({ default: 'info' }),
  MNEMONIC_WORDS: envalid.makeValidator<string[]>((input) => {
    const words = input.split(' ');
    if (words.length === 0) throw new Error('MNEMONIC_WORDS not set');
    return words;
  })(),
  NETWORK_ID: envalid.num({ choices: networkIdOptions }),
  NETWORK_INFO_PROVIDER: envalid.str({ choices: networkInfoProviderOptions }),
  NETWORK_INFO_PROVIDER_PARAMS: envalid.json({ default: {} }),
  REWARDS_PROVIDER: envalid.str({ choices: rewardsProviderOptions }),
  REWARDS_PROVIDER_PARAMS: envalid.json({ default: {} }),
  STAKE_POOL_PROVIDER: envalid.str({ choices: stakePoolProviderOptions }),
  STAKE_POOL_PROVIDER_PARAMS: envalid.json({ default: {} }),
  TX_SUBMIT_PROVIDER: envalid.str({ choices: txSubmitProviderOptions }),
  TX_SUBMIT_PROVIDER_PARAMS: envalid.json({ default: {} }),
  UTXO_PROVIDER: envalid.str({ choices: utxoProviderOptions }),
  UTXO_PROVIDER_PARAMS: envalid.json({ default: {} })
});

const logger = console;

const isTestnet = env.NETWORK_ID === 0;
const networkId = Number.parseInt(process.env.NETWORK_ID || '');
if (Number.isNaN(networkId)) throw new Error('NETWORK_ID not set');

// Sharing a single BlockFrostAPI object ensures rate limiting is shared across all blockfrost providers
const blockfrostApi = [
  env.TX_SUBMIT_PROVIDER,
  env.ASSET_PROVIDER,
  env.NETWORK_INFO_PROVIDER,
  env.UTXO_PROVIDER,
  env.CHAIN_HISTORY_PROVIDER
].includes('blockfrost')
  ? (async () => {
      logger.debug('WalletProvider:blockfrost - Initializing');
      const blockfrost = new BlockFrostAPI({
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        adapter: axiosFetchAdapter as any, // type mismatch: adapter uses axios 0.26, while blockfrost-js uses 0.21
        isTestnet,
        projectId: env.BLOCKFROST_API_KEY
      });
      logger.debug('WalletProvider:blockfrost - Responding');
      return blockfrost;
    })()
  : null;

export const utxoProvider = (async () => {
  switch (env.UTXO_PROVIDER) {
    case 'blockfrost': {
      return blockfrostUtxoProvider(await blockfrostApi!);
    }
    case 'http': {
      return utxoHttpProvider({ adapter: axiosFetchAdapter, baseUrl: env.UTXO_PROVIDER_PARAMS.baseUrl, logger });
    }
    default: {
      throw new Error(`UTXO_PROVIDER unsupported: ${env.UTXO_PROVIDER}`);
    }
  }
})();

export const assetProvider = (async () => {
  switch (env.ASSET_PROVIDER) {
    case 'blockfrost': {
      return blockfrostAssetProvider(await blockfrostApi!);
    }
    case 'http': {
      return assetInfoHttpProvider({ adapter: axiosFetchAdapter, baseUrl: env.ASSET_PROVIDER_PARAMS.baseUrl, logger });
    }
    default: {
      throw new Error(`ASSET_PROVIDER unsupported: ${env.ASSET_PROVIDER}`);
    }
  }
})();

export const txSubmitProvider = (async () => {
  switch (env.TX_SUBMIT_PROVIDER) {
    case 'blockfrost': {
      return blockfrostTxSubmitProvider(await blockfrostApi!);
    }
    case 'http': {
      return txSubmitHttpProvider({
        adapter: axiosFetchAdapter,
        baseUrl: env.TX_SUBMIT_PROVIDER_PARAMS.baseUrl,
        logger
      });
    }
    case 'ogmios': {
      const connectionConfig = {
        host: env.TX_SUBMIT_PROVIDER_PARAMS.baseUrl.hostname,
        port: env.TX_SUBMIT_PROVIDER_PARAMS.baseUrl.port
          ? Number.parseInt(env.TX_SUBMIT_PROVIDER_PARAMS.baseUrl.port)
          : undefined,
        tls: env.TX_SUBMIT_PROVIDER_PARAMS.baseUrl?.protocol === 'wss'
      };

      return ogmiosTxSubmitProvider(createConnectionObject(connectionConfig), logger);
    }
    default: {
      throw new Error(`TX_SUBMIT_PROVIDER unsupported: ${env.TX_SUBMIT_PROVIDER}`);
    }
  }
})();

export const rewardsProvider = (async () => {
  switch (env.REWARDS_PROVIDER) {
    case 'blockfrost': {
      return blockfrostRewardsProvider(await blockfrostApi!);
    }
    case 'http': {
      return rewardsHttpProvider({ adapter: axiosFetchAdapter, baseUrl: env.REWARDS_PROVIDER_PARAMS.baseUrl, logger });
    }
    default: {
      throw new Error(`REWARDS_PROVIDER unsupported: ${env.REWARDS_PROVIDER}`);
    }
  }
})();

export const stakePoolProvider = (async () => {
  if (env.STAKE_POOL_PROVIDER === 'stub') {
    return createStubStakePoolProvider();
  }
  throw new Error(`STAKE_POOL_PROVIDER unsupported: ${env.STAKE_POOL_PROVIDER}`);
})();

export const networkInfoProvider = (async () => {
  switch (env.NETWORK_INFO_PROVIDER) {
    case 'blockfrost': {
      return blockfrostNetworkInfoProvider(await blockfrostApi!);
    }
    case 'http': {
      return networkInfoHttpProvider({
        adapter: axiosFetchAdapter,
        baseUrl: env.NETWORK_INFO_PROVIDER_PARAMS.baseUrl,
        logger
      });
    }
    default: {
      throw new Error(`NETWORK_INFO_PROVIDER unsupported: ${env.NETWORK_INFO_PROVIDER}`);
    }
  }
})();

export const chainHistoryProvider = (async () => {
  switch (env.CHAIN_HISTORY_PROVIDER) {
    case 'blockfrost': {
      return blockfrostChainHistoryProvider(await blockfrostApi!, logger);
    }
    case 'http': {
      return chainHistoryHttpProvider({
        adapter: axiosFetchAdapter,
        baseUrl: env.CHAIN_HISTORY_PROVIDER_PARAMS.baseUrl,
        logger
      });
    }
    default: {
      throw new Error(`CHAIN_HISTORY_PROVIDER unsupported: ${env.CHAIN_HISTORY_PROVIDER}`);
    }
  }
})();
