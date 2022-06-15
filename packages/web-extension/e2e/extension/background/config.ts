/* eslint-disable sonarjs/no-small-switch */
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
import { Cardano } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { createStubStakePoolProvider } from '@cardano-sdk/util-dev';
import axiosFetchAdapter from '@vespaiach/axios-fetch-adapter';

const loggerMethodNames = ['debug', 'error', 'fatal', 'info', 'trace', 'warn'] as (keyof Logger)[];
const networkIdOptions = [0, 1];
const stakePoolProviderOptions = ['stub'];
const networkInfoProviderOptions = ['blockfrost'];
const txSubmitProviderOptions = ['blockfrost'];
const assetProviderOptions = ['blockfrost'];
const utxoProviderOptions = ['blockfrost'];
const rewardsProviderOptions = ['blockfrost'];
const keyAgentOptions = ['InMemory'];
const chainHistoryProviderOptions = ['blockfrost'];

const env = envalid.cleanEnv(process.env, {
  ASSET_PROVIDER: envalid.str({ choices: assetProviderOptions }),
  BLOCKFROST_API_KEY: envalid.str(),
  CHAIN_HISTORY_PROVIDER: envalid.str({ choices: chainHistoryProviderOptions }),
  KEY_AGENT: envalid.str({ choices: keyAgentOptions }),
  LOGGER_MIN_SEVERITY: envalid.str({ choices: loggerMethodNames as string[], default: 'info' }),
  MNEMONIC_WORDS: envalid.makeValidator<string[]>((input) => {
    const words = input.split(' ');
    if (words.length === 0) throw new Error('MNEMONIC_WORDS not set');
    return words;
  })(),
  NETWORK_ID: envalid.num({ choices: networkIdOptions }),
  NETWORK_INFO_PROVIDER: envalid.str({ choices: networkInfoProviderOptions }),
  POOL_ID_1: envalid.str(),
  POOL_ID_2: envalid.str(),
  REWARDS_PROVIDER: envalid.str({ choices: rewardsProviderOptions }),
  STAKE_POOL_PROVIDER: envalid.str({ choices: stakePoolProviderOptions }),
  TX_SUBMIT_HTTP_URL: envalid.url(),
  TX_SUBMIT_PROVIDER: envalid.str({ choices: txSubmitProviderOptions }),
  UTXO_PROVIDER: envalid.str({ choices: utxoProviderOptions }),
  WALLET_PASSWORD: envalid.str()
});
const isTestnet = env.NETWORK_ID === 0;
const networkId = Number.parseInt(process.env.NETWORK_ID || '');
if (Number.isNaN(networkId)) throw new Error('NETWORK_ID not set');

const logger = console;

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
  if (env.UTXO_PROVIDER === 'blockfrost') {
    return blockfrostUtxoProvider(await blockfrostApi!);
  }
  throw new Error(`UTXO_PROVIDER unsupported: ${env.UTXO_PROVIDER}`);
})();

export const assetProvider = (async () => {
  if (env.ASSET_PROVIDER === 'blockfrost') {
    return blockfrostAssetProvider(await blockfrostApi!);
  }
  throw new Error(`ASSET_PROVIDER unsupported: ${env.ASSET_PROVIDER}`);
})();

export const txSubmitProvider = (async () => {
  switch (env.TX_SUBMIT_PROVIDER) {
    case 'blockfrost': {
      return blockfrostTxSubmitProvider(await blockfrostApi!);
    }
    default: {
      throw new Error(`TX_SUBMIT_PROVIDER unsupported: ${env.TX_SUBMIT_PROVIDER}`);
    }
  }
})();

export const rewardsProvider = (async () => {
  if (env.REWARDS_PROVIDER === 'blockfrost') {
    return blockfrostRewardsProvider(await blockfrostApi!);
  }
  throw new Error(`REWARDS_PROVIDER unsupported: ${env.REWARDS_PROVIDER}`);
})();

export const stakePoolProvider = (async () => {
  if (env.STAKE_POOL_PROVIDER === 'stub') {
    return createStubStakePoolProvider();
  }
  throw new Error(`STAKE_POOL_PROVIDER unsupported: ${env.STAKE_POOL_PROVIDER}`);
})();

export const networkInfoProvider = (async () => {
  if (env.NETWORK_INFO_PROVIDER === 'blockfrost') {
    return blockfrostNetworkInfoProvider(await blockfrostApi!);
  }
  throw new Error(`NETWORK_INFO_PROVIDER unsupported: ${env.NETWORK_INFO_PROVIDER}`);
})();

export const chainHistoryProvider = (async () => {
  if (env.CHAIN_HISTORY_PROVIDER === 'blockfrost') {
    return blockfrostChainHistoryProvider(await blockfrostApi!);
  }
  throw new Error(`CHAIN_HISTORY_PROVIDER unsupported: ${env.CHAIN_HISTORY_PROVIDER}`);
})();

export const poolId1 = Cardano.PoolId(env.POOL_ID_1);
export const poolId2 = Cardano.PoolId(env.POOL_ID_2);
