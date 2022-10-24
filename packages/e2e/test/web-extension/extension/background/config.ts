/* eslint-disable sonarjs/no-small-switch */
/* eslint-disable no-console */
/* eslint-disable @typescript-eslint/no-explicit-any */
import * as envalid from 'envalid';
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
const networkInfoProviderOptions = ['http'];
const txSubmitProviderOptions = ['http'];
const assetProviderOptions = ['http'];
const utxoProviderOptions = ['http'];
const rewardsProviderOptions = ['http'];
const chainHistoryProviderOptions = ['http'];

const env = envalid.cleanEnv(process.env, {
  ASSET_PROVIDER: envalid.str({ choices: assetProviderOptions }),
  ASSET_PROVIDER_PARAMS: envalid.json({ default: {} }),
  CHAIN_HISTORY_PROVIDER: envalid.str({ choices: chainHistoryProviderOptions }),
  CHAIN_HISTORY_PROVIDER_PARAMS: envalid.json({ default: {} }),
  LOGGER_MIN_SEVERITY: envalid.str({ default: 'info' }),
  MNEMONIC_WORDS_WALLET1: envalid.makeValidator<string[]>((input) => {
    const words = input.split(' ');
    if (words.length === 0) throw new Error('MNEMONIC_WORDS_WALLET1 not set');
    return words;
  })(),
  MNEMONIC_WORDS_WALLET2: envalid.makeValidator<string[]>((input) => {
    const words = input.split(' ');
    if (words.length === 0) throw new Error('MNEMONIC_WORDS_WALLET2 not set');
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

const networkId = Number.parseInt(process.env.NETWORK_ID || '');
if (Number.isNaN(networkId)) throw new Error('NETWORK_ID not set');

export const utxoProvider = (async () => {
  switch (env.UTXO_PROVIDER) {
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
