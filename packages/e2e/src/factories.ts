/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  Asset,
  AssetProvider,
  Cardano,
  ChainHistoryProvider,
  NetworkInfoProvider,
  ProviderFactory,
  RewardsProvider,
  StakePoolProvider,
  TxSubmitProvider,
  UtxoProvider
} from '@cardano-sdk/core';
import {
  BlockFrostAPI,
  blockfrostAssetProvider,
  blockfrostChainHistoryProvider,
  blockfrostNetworkInfoProvider,
  blockfrostRewardsProvider,
  blockfrostTxSubmitProvider,
  blockfrostUtxoProvider
} from '@cardano-sdk/blockfrost';
import { CardanoWalletFaucetProvider, FaucetProvider } from './FaucetProvider';
import { KeyManagement, SingleAddressWallet, setupWallet, storage } from '@cardano-sdk/wallet';
import { LogLevel, createLogger } from 'bunyan';
import { Logger } from 'ts-log';
import {
  chainHistoryHttpProvider,
  networkInfoHttpProvider,
  rewardsHttpProvider,
  stakePoolHttpProvider,
  txSubmitHttpProvider,
  utxoHttpProvider
} from '@cardano-sdk/cardano-services-client';
import { createConnectionObject } from '@cardano-ogmios/client';
import { createStubStakePoolProvider } from '@cardano-sdk/util-dev';
import { ogmiosTxSubmitProvider } from '@cardano-sdk/ogmios';
import DeviceConnection from '@cardano-foundation/ledgerjs-hw-app-cardano';
import memoize from 'lodash/memoize';

// CONSTANTS
const BLOCKFROST_PROVIDER = 'blockfrost';
const BLOCKFROST_MISSING_PROJECT_ID = 'Missing project id';
const HTTP_PROVIDER = 'http';
const OGMIOS_PROVIDER = 'ogmios';
const STUB_PROVIDER = 'stub';
const KEY_AGENT_MISSING_PASSWORD = 'Missing wallet password';
const KEY_AGENT_MISSING_NETWORK_ID = 'Missing network id';
const KEY_AGENT_MISSING_ACCOUNT_INDEX = 'Missing account index';
const MISSING_URL_PARAM = 'Missing URL';

// Sharing a single BlockFrostAPI object ensures rate limiting is shared across all blockfrost providers
let blockfrostApi: BlockFrostAPI;

/**
 * Gets the singleton blockfrost API instance.
 *
 * @returns The blockfrost API instance, this function always returns the same instance.
 */
const getBlockfrostApi = async () => {
  if (blockfrostApi !== undefined) return blockfrostApi;

  if (process.env.BLOCKFROST_API_KEY === undefined) throw new Error(BLOCKFROST_MISSING_PROJECT_ID);

  return new BlockFrostAPI({ isTestnet: true, projectId: process.env.BLOCKFROST_API_KEY });
};

export const faucetProviderFactory = new ProviderFactory<FaucetProvider>();
export type CreateKeyAgent = (dependencies: KeyManagement.KeyAgentDependencies) => Promise<KeyManagement.AsyncKeyAgent>;
export const keyManagementFactory = new ProviderFactory<CreateKeyAgent>();
export const assetProviderFactory = new ProviderFactory<AssetProvider>();
export const chainHistoryProviderFactory = new ProviderFactory<ChainHistoryProvider>();
export const networkInfoProviderFactory = new ProviderFactory<NetworkInfoProvider>();
export const rewardsProviderFactory = new ProviderFactory<RewardsProvider>();
export const txSubmitProviderFactory = new ProviderFactory<TxSubmitProvider>();
export const utxoProviderFactory = new ProviderFactory<UtxoProvider>();
export const stakePoolProviderFactory = new ProviderFactory<StakePoolProvider>();

// Faucet providers
faucetProviderFactory.register('cardano-wallet', CardanoWalletFaucetProvider.create);

// Asset providers

/**
 * Asset provider which does nothing.
 */
class NullAssetProvider implements AssetProvider {
  getAsset() {
    return new Promise<Asset.AssetInfo>((resolve) =>
      resolve({
        assetId: Cardano.AssetId(''),
        fingerprint: Cardano.AssetFingerprint(''),
        history: [
          {
            quantity: 0n,
            transactionId: Cardano.TransactionId('')
          }
        ],
        name: Cardano.AssetName(''),
        policyId: Cardano.PolicyId(''),
        quantity: 0n
      } as Asset.AssetInfo)
    );
  }
}

assetProviderFactory.register(
  STUB_PROVIDER,
  async (): Promise<AssetProvider> =>
    new Promise<AssetProvider>(async (resolve) => {
      resolve(new NullAssetProvider());
    })
);

assetProviderFactory.register(
  BLOCKFROST_PROVIDER,
  async (): Promise<AssetProvider> =>
    new Promise<AssetProvider>(async (resolve) => {
      resolve(blockfrostAssetProvider(await getBlockfrostApi()));
    })
);

// Chain history providers
chainHistoryProviderFactory.register(
  BLOCKFROST_PROVIDER,
  async (): Promise<ChainHistoryProvider> =>
    new Promise<ChainHistoryProvider>(async (resolve) => {
      resolve(blockfrostChainHistoryProvider(await getBlockfrostApi()));
    })
);

chainHistoryProviderFactory.register(HTTP_PROVIDER, async (params: any): Promise<ChainHistoryProvider> => {
  if (params.url === undefined) throw new Error(`${chainHistoryHttpProvider.name}: ${MISSING_URL_PARAM}`);

  return new Promise<ChainHistoryProvider>(async (resolve) => {
    resolve(chainHistoryHttpProvider(params.url));
  });
});

// Network info providers
networkInfoProviderFactory.register(
  BLOCKFROST_PROVIDER,
  async (): Promise<NetworkInfoProvider> =>
    new Promise<NetworkInfoProvider>(async (resolve) => {
      resolve(blockfrostNetworkInfoProvider(await getBlockfrostApi()));
    })
);

networkInfoProviderFactory.register(HTTP_PROVIDER, async (params: any): Promise<NetworkInfoProvider> => {
  if (params.url === undefined) throw new Error(`${networkInfoHttpProvider.name}: ${MISSING_URL_PARAM}`);

  return new Promise<NetworkInfoProvider>(async (resolve) => {
    resolve(networkInfoHttpProvider(params.url));
  });
});

// Rewards providers
rewardsProviderFactory.register(
  BLOCKFROST_PROVIDER,
  async (): Promise<RewardsProvider> =>
    new Promise<RewardsProvider>(async (resolve) => {
      resolve(blockfrostRewardsProvider(await getBlockfrostApi()));
    })
);

rewardsProviderFactory.register(HTTP_PROVIDER, async (params: any): Promise<RewardsProvider> => {
  if (params.url === undefined) throw new Error(`${rewardsHttpProvider.name}: ${MISSING_URL_PARAM}`);

  return new Promise<RewardsProvider>(async (resolve) => {
    resolve(rewardsHttpProvider(params.url));
  });
});

// Tx submit providers
txSubmitProviderFactory.register(
  BLOCKFROST_PROVIDER,
  async (): Promise<TxSubmitProvider> =>
    new Promise<TxSubmitProvider>(async (resolve) => {
      resolve(blockfrostTxSubmitProvider(await getBlockfrostApi()));
    })
);

txSubmitProviderFactory.register(OGMIOS_PROVIDER, async (params: any): Promise<TxSubmitProvider> => {
  if (params.url === undefined) throw new Error(`${ogmiosTxSubmitProvider.name}: ${MISSING_URL_PARAM}`);

  const connectionConfig = {
    host: params.url.hostname,
    port: params.url.port ? Number.parseInt(params.url.port) : undefined,
    tls: params.url?.protocol === 'wss'
  };

  return new Promise<TxSubmitProvider>(async (resolve) => {
    resolve(ogmiosTxSubmitProvider(createConnectionObject(connectionConfig)));
  });
});

txSubmitProviderFactory.register(HTTP_PROVIDER, async (params: any): Promise<TxSubmitProvider> => {
  if (params.url === undefined) throw new Error(`${txSubmitHttpProvider.name}: ${MISSING_URL_PARAM}`);

  return new Promise<TxSubmitProvider>(async (resolve) => {
    resolve(txSubmitHttpProvider(params.url));
  });
});

// Utxo providers
utxoProviderFactory.register(
  BLOCKFROST_PROVIDER,
  async (): Promise<UtxoProvider> =>
    new Promise<UtxoProvider>(async (resolve) => {
      resolve(blockfrostUtxoProvider(await getBlockfrostApi()));
    })
);

utxoProviderFactory.register(HTTP_PROVIDER, async (params: any): Promise<UtxoProvider> => {
  if (params.url === undefined) throw new Error(`${utxoHttpProvider.name}: ${MISSING_URL_PARAM}`);

  return new Promise<UtxoProvider>(async (resolve) => {
    resolve(utxoHttpProvider(params.url));
  });
});

// Stake Pool providers
stakePoolProviderFactory.register(
  STUB_PROVIDER,
  async (): Promise<StakePoolProvider> =>
    new Promise<StakePoolProvider>(async (resolve) => {
      resolve(createStubStakePoolProvider());
    })
);

stakePoolProviderFactory.register(HTTP_PROVIDER, async (params: any): Promise<StakePoolProvider> => {
  if (params.url === undefined) throw new Error(`${stakePoolHttpProvider.name}: ${MISSING_URL_PARAM}`);

  return new Promise<StakePoolProvider>(async (resolve) => {
    resolve(stakePoolHttpProvider(params.url));
  });
});

// Key Agents
keyManagementFactory.register('inMemory', async (params: any): Promise<CreateKeyAgent> => {
  let mnemonicWords = (params?.mnemonic || '').split(' ');

  if (mnemonicWords.length <= 1) mnemonicWords = KeyManagement.util.generateMnemonicWords();

  if (params.password === undefined) throw new Error(KEY_AGENT_MISSING_PASSWORD);

  if (params.networkId === undefined) throw new Error(KEY_AGENT_MISSING_NETWORK_ID);

  if (params.accountIndex === undefined) throw new Error(KEY_AGENT_MISSING_ACCOUNT_INDEX);

  return async (dependencies) =>
    KeyManagement.util.createAsyncKeyAgent(
      await KeyManagement.InMemoryKeyAgent.fromBip39MnemonicWords(
        {
          accountIndex: params.accountIndex,
          getPassword: async () => Buffer.from(params.password),
          mnemonicWords,
          networkId: params.networkId
        },
        dependencies
      )
    );
});

keyManagementFactory.register('ledger', async (params: any): Promise<CreateKeyAgent> => {
  if (params.networkId === undefined) throw new Error(KEY_AGENT_MISSING_NETWORK_ID);

  if (params.accountIndex === undefined) throw new Error(KEY_AGENT_MISSING_ACCOUNT_INDEX);

  let deviceConnection: DeviceConnection | null | undefined;

  return async (dependencies) => {
    const ledgerKeyAgent = await KeyManagement.LedgerKeyAgent.createWithDevice(
      {
        accountIndex: params.accountIndex,
        communicationType: KeyManagement.CommunicationType.Node,
        deviceConnection,
        networkId: params.networkId,
        protocolMagic: 1_097_911_063
      },
      dependencies
    );

    return KeyManagement.util.createAsyncKeyAgent(ledgerKeyAgent);
  };
});

keyManagementFactory.register('trezor', async (params: any): Promise<CreateKeyAgent> => {
  if (params.networkId === undefined) throw new Error(KEY_AGENT_MISSING_NETWORK_ID);

  if (params.accountIndex === undefined) throw new Error(KEY_AGENT_MISSING_ACCOUNT_INDEX);

  return async (dependencies) =>
    KeyManagement.util.createAsyncKeyAgent(
      await KeyManagement.TrezorKeyAgent.createWithDevice(
        {
          accountIndex: params.accountIndex,
          networkId: params.networkId,
          protocolMagic: 1_097_911_063,
          trezorConfig: {
            communicationType: KeyManagement.CommunicationType.Node,
            manifest: {
              appUrl: 'https://your.application.com',
              email: 'email@developer.com'
            }
          }
        },
        dependencies
      )
    );
});

/**
 * Utility function to create key agents at different account indices.
 *
 * @param accountIndex The account index.
 * @param provider The provider.
 * @param params The provider parameters.
 * @returns a key agent.
 */
export const keyAgentById = memoize(async (accountIndex: number, provider: string, params: any) => {
  params.accountIndex = accountIndex;
  return keyManagementFactory.create(provider, params);
});

/**
 * Create a single wallet instance given the environment variables.
 *
 * @param environment The environment variables.
 * @param stores The wallet store.
 * @param idx The id of the key agent.
 */
export const getWallet = async (environment: any, stores?: storage.WalletStores, idx = 0) => {
  const { wallet } = await setupWallet({
    createKeyAgent: await keyAgentById(idx, environment.KEY_MANAGEMENT_PROVIDER, environment.KEY_MANAGEMENT_PARAMS),
    createWallet: async (keyAgent) =>
      new SingleAddressWallet(
        { name: 'Test Wallet' },
        {
          assetProvider: await assetProviderFactory.create(
            environment.ASSET_PROVIDER,
            environment.ASSET_PROVIDER_PARAMS
          ),
          chainHistoryProvider: await chainHistoryProviderFactory.create(
            environment.CHAIN_HISTORY_PROVIDER,
            environment.CHAIN_HISTORY_PROVIDER_PARAMS
          ),
          keyAgent,
          networkInfoProvider: await networkInfoProviderFactory.create(
            environment.NETWORK_INFO_PROVIDER,
            environment.NETWORK_INFO_PROVIDER_PARAMS
          ),
          rewardsProvider: await rewardsProviderFactory.create(
            environment.REWARDS_PROVIDER,
            environment.REWARDS_PROVIDER_PARAMS
          ),
          stakePoolProvider: await stakePoolProviderFactory.create(
            environment.STAKE_POOL_PROVIDER,
            environment.STAKE_POOL_PROVIDER_PARAMS
          ),
          stores,
          txSubmitProvider: await txSubmitProviderFactory.create(
            environment.TX_SUBMIT_PROVIDER,
            environment.TX_SUBMIT_PROVIDER_PARAMS
          ),
          utxoProvider: await utxoProviderFactory.create(environment.UTXO_PROVIDER, environment.UTXO_PROVIDER_PARAMS)
        }
      )
  });
  return wallet;
};

// Logger

/**
 * Gets the logger instance.
 *
 * @param severity The minimum severity of the log messages that will be logged.
 * @returns The Logger instance.
 */
export const getLogger = function (severity: string): Logger {
  return createLogger({
    level: severity as LogLevel,
    name: 'e2e tests'
  });
};
