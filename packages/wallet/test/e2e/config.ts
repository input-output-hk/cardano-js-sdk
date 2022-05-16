import * as envalid from 'envalid';
import {
  BlockFrostAPI,
  blockfrostAssetProvider,
  blockfrostNetworkInfoProvider,
  blockfrostTxSubmitProvider,
  blockfrostUtxoProvider,
  blockfrostWalletProvider
} from '@cardano-sdk/blockfrost';
import { Cardano } from '@cardano-sdk/core';
import { CommunicationType, InMemoryKeyAgent, LedgerKeyAgent, TrezorKeyAgent } from '../../src/KeyManagement';
import { LogLevel, createLogger } from 'bunyan';
import { Logger } from 'ts-log';
import { URL } from 'url';
import { createAsyncKeyAgent } from '../../src/KeyManagement/util';
import { createConnectionObject } from '@cardano-ogmios/client';
import { createStubStakePoolProvider } from '@cardano-sdk/util-dev';
import { memoize } from 'lodash-es';
import { ogmiosTxSubmitProvider } from '@cardano-sdk/ogmios';
import { txSubmitHttpProvider } from '@cardano-sdk/cardano-services-client';
import DeviceConnection from '@cardano-foundation/ledgerjs-hw-app-cardano';
import waitOn from 'wait-on';

const loggerMethodNames = ['debug', 'error', 'fatal', 'info', 'trace', 'warn'] as (keyof Logger)[];
const networkIdOptions = [0, 1];
const stakePoolProviderOptions = ['stub'];
const networkInfoProviderOptions = ['blockfrost'];
const txSubmitProviderOptions = ['blockfrost', 'ogmios', 'http'];
const utxoProviderOptions = ['blockfrost'];
const walletProviderOptions = ['blockfrost'];
const assetProviderOptions = ['blockfrost'];
const keyAgentOptions = ['InMemory', 'Ledger', 'Trezor'];

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
  OGMIOS_URL: envalid.url(),
  POOL_ID_1: envalid.str(),
  POOL_ID_2: envalid.str(),
  STAKE_POOL_PROVIDER: envalid.str({ choices: stakePoolProviderOptions }),
  TX_SUBMIT_HTTP_URL: envalid.url(),
  TX_SUBMIT_PROVIDER: envalid.str({ choices: txSubmitProviderOptions }),
  UTXO_PROVIDER: envalid.str({ choices: utxoProviderOptions }),
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
      await waitOn({ resources: [blockfrost.apiUrl], validateStatus: (status) => status === 403 });
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
  const ogmiosUrl = new URL(env.OGMIOS_URL);
  switch (env.TX_SUBMIT_PROVIDER) {
    case 'blockfrost': {
      return blockfrostTxSubmitProvider(await blockfrostApi!);
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
      const provider = txSubmitHttpProvider(env.TX_SUBMIT_HTTP_URL);
      await waitOn({ resources: [`${env.TX_SUBMIT_HTTP_URL}/health`] });
      logger.debug('TxSubmitProvider:http - Responding');
      return provider;
    }
    default: {
      throw new Error(`TX_SUBMIT_PROVIDER unsupported: ${env.TX_SUBMIT_PROVIDER}`);
    }
  }
})();

let deviceConnection: DeviceConnection | null | undefined;
export const keyAgentByIdx = memoize(async (accountIndex: number) =>
  createAsyncKeyAgent(
    await (async (): Promise<KeyAgent> => {
      switch (env.KEY_AGENT) {
        case 'Ledger': {
          const ledgerKeyAgent = await LedgerKeyAgent.createWithDevice({
            accountIndex,
            communicationType: CommunicationType.Node,
            deviceConnection,
            networkId
          });
          deviceConnection = ledgerKeyAgent.deviceConnection;
          return ledgerKeyAgent;
        }
        case 'Trezor': {
          return await TrezorKeyAgent.createWithDevice({
            accountIndex,
            networkId,
            trezorConfig: {
              communicationType: CommunicationType.Node,
              manifest: {
                appUrl: 'https://your.application.com',
                email: 'email@developer.com'
              }
            }
         });
	}
        case 'InMemory': {
          const mnemonicWords = (process.env.MNEMONIC_WORDS || '').split(' ');
          if (mnemonicWords.length === 0) throw new Error('MNEMONIC_WORDS not set');
          const password = process.env.WALLET_PASSWORD;
          if (!password) throw new Error('WALLET_PASSWORD not set');
          return await InMemoryKeyAgent.fromBip39MnemonicWords({
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
    })()
  )
);

export const keyAgentReady = (() => keyAgentByIdx(0))();

export const stakePoolProvider = (() => {
  if (env.STAKE_POOL_PROVIDER === 'stub') {
    return createStubStakePoolProvider();
  }
  throw new Error(`STAKE_POOL_SEARCH_PROVIDER unsupported: ${env.STAKE_POOL_SEARCH_PROVIDER}`);
})();

export const networkInfoProvider = (async () => {
  if (env.NETWORK_INFO_PROVIDER === 'blockfrost') {
    return blockfrostNetworkInfoProvider(await blockfrostApi!);
  }
  throw new Error(`NETWORK_INFO_PROVIDER unsupported: ${env.NETWORK_INFO_PROVIDER}`);
})();

export const utxoProvider = (async () => {
  if (env.UTXO_PROVIDER === 'blockfrost') {
    return blockfrostUtxoProvider(await blockfrostApi!);
  }
  throw new Error(`UTXO_PROVIDER unsupported: ${env.UTXO_PROVIDER}`);
})();

export const poolId1 = Cardano.PoolId(env.POOL_ID_1);
export const poolId2 = Cardano.PoolId(env.POOL_ID_2);
