/* eslint-disable no-console */
import * as envalid from 'envalid';
import {
  BlockFrostAPI,
  blockfrostAssetProvider,
  blockfrostTxSubmitProvider,
  blockfrostWalletProvider
} from '@cardano-sdk/blockfrost';
import { Cardano, testnetTimeSettings } from '@cardano-sdk/core';
import { InMemoryKeyAgent } from '../../src/KeyManagement';
import { LogLevel, createLogger } from 'bunyan';
import { Logger } from 'ts-log';
import { URL } from 'url';
import { createConnectionObject } from '@cardano-ogmios/client';
import { createStubStakePoolSearchProvider, createStubTimeSettingsProvider } from '@cardano-sdk/util-dev';
import { ogmiosTxSubmitProvider } from '@cardano-sdk/ogmios';
import { txSubmitHttpProvider } from '@cardano-sdk/cardano-graphql';
import waitOn from 'wait-on';

const loggerMethodNames = ['debug', 'error', 'fatal', 'info', 'trace', 'warn'] as (keyof Logger)[];
const networkIdOptions = [0, 1];
const stakePoolSearchProviderOptions = ['stub'];
const timeSettingsProviderOptions = ['stub_testnet'];
const txSubmitProviderOptions = ['blockfrost', 'ogmios', 'http'];
const walletProviderOptions = ['blockfrost'];

const env = envalid.cleanEnv(process.env, {
  BLOCKFROST_API_KEY: envalid.str(),
  LOGGER_MIN_SEVERITY: envalid.str({ choices: loggerMethodNames as string[], default: 'info' }),
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
const networkId = Number.parseInt(process.env.NETWORK_ID || '');
if (Number.isNaN(networkId)) throw new Error('NETWORK_ID not set');

const logger = createLogger({
  level: env.LOGGER_MIN_SEVERITY as LogLevel,
  name: 'wallet e2e tests'
});

const waitOnBlockfrost = (blockfrost: BlockFrostAPI) =>
  waitOn({ resources: [blockfrost.apiUrl], validateStatus: (status) => status === 403 });

export const walletProvider = (async () => {
  if (env.WALLET_PROVIDER === 'blockfrost') {
    logger.debug('WalletProvider:blockfrost - Initializing');
    const blockfrost = new BlockFrostAPI({ isTestnet, projectId: env.BLOCKFROST_API_KEY });
    await waitOnBlockfrost(blockfrost);
    logger.debug('WalletProvider:blockfrost - Responding');
    return blockfrostWalletProvider(blockfrost);
  }
  throw new Error(`WALLET_PROVIDER unsupported: ${env.WALLET_PROVIDER}`);
})();

export const assetProvider = (async () => {
  const blockfrost = new BlockFrostAPI({ isTestnet, projectId: env.BLOCKFROST_API_KEY });
  logger.debug('AssetProvider:blockfrost - Initializing');
  await waitOnBlockfrost(blockfrost);
  logger.debug('AssetProvider:blockfrost - Responding');
  return blockfrostAssetProvider(blockfrost);
})();

export const txSubmitProvider = (async () => {
  const ogmiosUrl = new URL(env.OGMIOS_URL);
  switch (env.TX_SUBMIT_PROVIDER) {
    case 'blockfrost': {
      logger.debug('TxSubmitProvider:blockfrost - Initializing');
      const blockfrost = new BlockFrostAPI({ isTestnet, projectId: env.BLOCKFROST_API_KEY });
      await waitOnBlockfrost(blockfrost);
      logger.debug('TxSubmitProvider:blockfrost - Responding');
      return blockfrostTxSubmitProvider(blockfrost);
    }
    case 'ogmios': {
      logger.debug('TxSubmitProvider:ogmios - Initializing');
      const connectionConfig = {
        host: ogmiosUrl.hostname,
        port: ogmiosUrl.port ? Number.parseInt(ogmiosUrl.port) : undefined,
        tls: ogmiosUrl?.protocol === 'wss'
      };
      const connection = createConnectionObject(connectionConfig);
      const provider = ogmiosTxSubmitProvider(connectionConfig);
      await waitOn({
        resources: [connection.address.http],
        validateStatus: (status) => status === 404
      });
      logger.debug('TxSubmitProvider:ogmios - Responding');
      return provider;
    }
    case 'http': {
      logger.debug('TxSubmitProvider:http - Initializing');
      const provider = await txSubmitHttpProvider({ url: env.TX_SUBMIT_HTTP_URL });
      await waitOn({ resources: [`${env.TX_SUBMIT_HTTP_URL}/health`] });
      logger.debug('TxSubmitProvider:http - Responding');
      return provider;
    }
    default: {
      throw new Error(`TX_SUBMIT_PROVIDER unsupported: ${env.TX_SUBMIT_PROVIDER}`);
    }
  }
})();

export const keyAgentByIdx = (accountIndex: number) => {
  const mnemonicWords = (process.env.MNEMONIC_WORDS || '').split(' ');
  if (mnemonicWords.length === 0) throw new Error('MNEMONIC_WORDS not set');
  const password = process.env.WALLET_PASSWORD;
  if (!password) throw new Error('WALLET_PASSWORD not set');
  return InMemoryKeyAgent.fromBip39MnemonicWords({
    accountIndex,
    getPassword: async () => Buffer.from(password),
    mnemonicWords,
    networkId
  });
};

export const keyAgentReady = (() => keyAgentByIdx(0))();

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
