/* eslint-disable sonarjs/no-small-switch */
import * as envalid from 'envalid';
import {
  BlockFrostAPI,
  blockfrostAssetProvider,
  blockfrostNetworkInfoProvider,
  blockfrostTxSubmitProvider,
  blockfrostWalletProvider
} from '@cardano-sdk/blockfrost';
import { Cardano } from '@cardano-sdk/core';
import { KeyManagement } from '@cardano-sdk/wallet';
import { Logger } from 'ts-log';
import { createStubStakePoolSearchProvider } from '@cardano-sdk/util-dev';
import { memoize } from 'lodash-es';

const loggerMethodNames = ['debug', 'error', 'fatal', 'info', 'trace', 'warn'] as (keyof Logger)[];
const networkIdOptions = [0, 1];
const stakePoolSearchProviderOptions = ['stub'];
const networkInfoProviderOptions = ['blockfrost'];
const txSubmitProviderOptions = ['blockfrost'];
const walletProviderOptions = ['blockfrost'];
const assetProviderOptions = ['blockfrost'];
const keyAgentOptions = ['InMemory'];

const env = envalid.cleanEnv(process.env, {
  ASSET_PROVIDER: envalid.str({ choices: assetProviderOptions }),
  BLOCKFROST_API_KEY: envalid.str(),
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
  STAKE_POOL_SEARCH_PROVIDER: envalid.str({ choices: stakePoolSearchProviderOptions }),
  TX_SUBMIT_HTTP_URL: envalid.url(),
  TX_SUBMIT_PROVIDER: envalid.str({ choices: txSubmitProviderOptions }),
  WALLET_PASSWORD: envalid.str(),
  WALLET_PROVIDER: envalid.str({ choices: walletProviderOptions })
});
const isTestnet = env.NETWORK_ID === 0;
const networkId = Number.parseInt(process.env.NETWORK_ID || '');
if (Number.isNaN(networkId)) throw new Error('NETWORK_ID not set');

const logger = console;

// Sharing a single BlockFrostAPI object ensures rate limiting is shared across all blockfrost providers
const blockfrostApi = [
  env.WALLET_PASSWORD,
  env.TX_SUBMIT_PROVIDER,
  env.ASSET_PROVIDER,
  env.NETWORK_INFO_PROVIDER
].includes('blockfrost')
  ? (async () => {
      logger.debug('WalletProvider:blockfrost - Initializing');
      const blockfrost = new BlockFrostAPI({ isTestnet, projectId: env.BLOCKFROST_API_KEY });
      logger.debug('WalletProvider:blockfrost - Responding');
      return blockfrost;
    })()
  : null;

export const walletProvider = (async () => {
  if (env.WALLET_PROVIDER === 'blockfrost') {
    return blockfrostWalletProvider(await blockfrostApi!);
  }
  throw new Error(`WALLET_PROVIDER unsupported: ${env.WALLET_PROVIDER}`);
})();

export const assetProvider = (async () => {
  if (env.ASSET_PROVIDER === 'blockfrost') {
    return blockfrostAssetProvider(await blockfrostApi!);
  }
  throw new Error(`NETWORK_INFO_PROVIDER unsupported: ${env.NETWORK_INFO_PROVIDER}`);
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

export const keyAgentByIdx = memoize(async (accountIndex: number) => {
  switch (env.KEY_AGENT) {
    case 'InMemory': {
      const mnemonicWords = (process.env.MNEMONIC_WORDS || '').split(' ');
      if (mnemonicWords.length === 0) throw new Error('MNEMONIC_WORDS not set');
      const password = process.env.WALLET_PASSWORD;
      if (!password) throw new Error('WALLET_PASSWORD not set');
      return await KeyManagement.InMemoryKeyAgent.fromBip39MnemonicWords({
        accountIndex,
        getPassword: async () => Buffer.from(password),
        mnemonicWords,
        networkId
      });
    }
    default: {
      throw new Error(`KEY_AGENT unsupported: ${process.env.KEY_AGENT}`);
    }
  }
});

export const keyAgentReady = (() => keyAgentByIdx(0))();

export const stakePoolSearchProvider = (async () => {
  if (env.STAKE_POOL_SEARCH_PROVIDER === 'stub') {
    return createStubStakePoolSearchProvider();
  }
  throw new Error(`STAKE_POOL_SEARCH_PROVIDER unsupported: ${env.STAKE_POOL_SEARCH_PROVIDER}`);
})();

export const networkInfoProvider = (async () => {
  if (env.NETWORK_INFO_PROVIDER === 'blockfrost') {
    return blockfrostNetworkInfoProvider(await blockfrostApi!);
  }
  throw new Error(`NETWORK_INFO_PROVIDER unsupported: ${env.NETWORK_INFO_PROVIDER}`);
})();

export const poolId1 = Cardano.PoolId(env.POOL_ID_1);
export const poolId2 = Cardano.PoolId(env.POOL_ID_2);
