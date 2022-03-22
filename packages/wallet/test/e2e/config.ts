import * as envalid from 'envalid';
import {
  BlockFrostAPI,
  blockfrostAssetProvider,
  blockfrostTxSubmitProvider,
  blockfrostWalletProvider
} from '@cardano-sdk/blockfrost';
import { Cardano, testnetTimeSettings } from '@cardano-sdk/core';
import { InMemoryKeyAgent } from '../../src/KeyManagement';
import { URL } from 'url';
import { createStubStakePoolSearchProvider, createStubTimeSettingsProvider } from '@cardano-sdk/util-dev';
import { ogmiosTxSubmitProvider } from '@cardano-sdk/ogmios';
import { txSubmitHttpProvider } from '@cardano-sdk/cardano-graphql';

const networkIdOptions = [0, 1];
const stakePoolSearchProviderOptions = ['stub'];
const timeSettingsProviderOptions = ['stub_testnet'];
const txSubmitProviderOptions = ['blockfrost', 'ogmios', 'http'];
const walletProviderOptions = ['blockfrost'];

const env = envalid.cleanEnv(process.env, {
  BLOCKFROST_API_KEY: envalid.str(),
  MNEMONIC_WORDS: envalid.makeValidator<string[]>((input) => {
    const words = input.split(' ');
    if (words.length === 0) throw new Error('MNEMONIC_WORDS not set');
    return words;
  })(),
  NETWORK_ID: envalid.num({ choices: networkIdOptions }),
  OGMIOS_URL: envalid.url(),
  POOL_ID_1: envalid.str(),
  POOL_ID_2: envalid.str(),
  STAKE_POOL_SEARCH_PROVIDER: envalid.str({ choices: stakePoolSearchProviderOptions }),
  TIME_SETTINGS_PROVIDER: envalid.str({ choices: timeSettingsProviderOptions }),
  TX_SUBMIT_HTTP_URL: envalid.url(),
  TX_SUBMIT_PROVIDER: envalid.str({ choices: txSubmitProviderOptions }),
  WALLET_PASSWORD: envalid.str(),
  WALLET_PROVIDER: envalid.str({ choices: walletProviderOptions })
});
const isTestnet = env.NETWORK_ID === 0;

export const walletProvider = (() => {
  if (env.WALLET_PROVIDER === 'blockfrost') {
    const blockfrost = new BlockFrostAPI({ isTestnet, projectId: env.BLOCKFROST_API_KEY });
    return blockfrostWalletProvider(blockfrost);
  }
  throw new Error(`WALLET_PROVIDER unsupported: ${env.WALLET_PROVIDER}`);
})();

export const assetProvider = (() => {
  const blockfrost = new BlockFrostAPI({ isTestnet, projectId: env.BLOCKFROST_API_KEY });
  return blockfrostAssetProvider(blockfrost);
})();

export const txSubmitProvider = (() => {
  const ogmiosUrl = new URL(env.OGMIOS_URL);
  switch (env.TX_SUBMIT_PROVIDER) {
    case 'blockfrost': {
      const blockfrost = new BlockFrostAPI({ isTestnet, projectId: env.BLOCKFROST_API_KEY });
      return blockfrostTxSubmitProvider(blockfrost);
    }
    case 'ogmios': {
      return ogmiosTxSubmitProvider({
        host: ogmiosUrl.host,
        port: ogmiosUrl.port ? Number.parseInt(ogmiosUrl.port) : undefined,
        tls: ogmiosUrl?.protocol === 'wss'
      });
    }
    case 'http': {
      return txSubmitHttpProvider({ url: env.TX_SUBMIT_HTTP_URL });
    }
    default: {
      throw new Error(`TX_SUBMIT_PROVIDER unsupported: ${env.TX_SUBMIT_PROVIDER}`);
    }
  }
})();

export const keyAgentReady = (() =>
  InMemoryKeyAgent.fromBip39MnemonicWords({
    getPassword: async () => Buffer.from(env.WALLET_PASSWORD),
    mnemonicWords: env.MNEMONIC_WORDS,
    networkId: env.NETWORK_ID
  }))();

export const stakePoolSearchProvider = (() => {
  if (env.STAKE_POOL_SEARCH_PROVIDER === 'stub') {
    return createStubStakePoolSearchProvider();
  }
  throw new Error(`STAKE_POOL_SEARCH_PROVIDER unsupported: ${env.STAKE_POOL_SEARCH_PROVIDER}`);
})();

export const timeSettingsProvider = (() => {
  if (env.TIME_SETTINGS_PROVIDER === 'stub_testnet') {
    return createStubTimeSettingsProvider(testnetTimeSettings);
  }
  throw new Error(`TIME_SETTINGS_PROVIDER unsupported: ${env.TIME_SETTINGS_PROVIDER}`);
})();

export const poolId1 = Cardano.PoolId(env.POOL_ID_1);
export const poolId2 = Cardano.PoolId(env.POOL_ID_2);
