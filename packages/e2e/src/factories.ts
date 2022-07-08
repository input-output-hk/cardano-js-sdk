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
import { KeyManagement } from '@cardano-sdk/wallet';
import { LogLevel, createLogger } from 'bunyan';
import { Logger } from 'ts-log';
import { createConnectionObject } from '@cardano-ogmios/client';
import { createStubStakePoolProvider } from '@cardano-sdk/util-dev';
import { ogmiosTxSubmitProvider } from '@cardano-sdk/ogmios';
import { txSubmitHttpProvider } from '@cardano-sdk/cardano-services-client';
import DeviceConnection from '@cardano-foundation/ledgerjs-hw-app-cardano';
import memoize from 'lodash/memoize';

const BLOCKFROST_PROVIDER = 'blockfrost';
const BLOCKFROST_MISSING_PROJECT_ID = 'Missing project id';
const KEY_AGENT_MISSING_MNEMONIC = 'Missing mnemonic words';
const KEY_AGENT_MISSING_PASSWORD = 'Missing wallet password';
const KEY_AGENT_MISSING_NETWORK_ID = 'Missing network id';
const KEY_AGENT_MISSING_ACCOUNT_INDEX = 'Missing account index';

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
export const keyManagementFactory = new ProviderFactory<KeyManagement.AsyncKeyAgent>();
export const assetProviderFactory = new ProviderFactory<AssetProvider>();
export const chainHistoryProviderFactory = new ProviderFactory<ChainHistoryProvider>();
export const networkInfoProviderFactory = new ProviderFactory<NetworkInfoProvider>();
export const rewardsProviderFactory = new ProviderFactory<RewardsProvider>();
export const txSubmitProviderFactory = new ProviderFactory<TxSubmitProvider>();
export const utxoProviderFactory = new ProviderFactory<UtxoProvider>();
export const stakePoolProviderFactory = new ProviderFactory<StakePoolProvider>();
export const loggerFactory = new ProviderFactory<Logger>();

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
  'stub',
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

// Network info providers
networkInfoProviderFactory.register(
  BLOCKFROST_PROVIDER,
  async (): Promise<NetworkInfoProvider> =>
    new Promise<NetworkInfoProvider>(async (resolve) => {
      resolve(blockfrostNetworkInfoProvider(await getBlockfrostApi()));
    })
);

// Rewards providers
rewardsProviderFactory.register(
  BLOCKFROST_PROVIDER,
  async (): Promise<RewardsProvider> =>
    new Promise<RewardsProvider>(async (resolve) => {
      resolve(blockfrostRewardsProvider(await getBlockfrostApi()));
    })
);

// Tx submit providers
txSubmitProviderFactory.register(
  BLOCKFROST_PROVIDER,
  async (): Promise<TxSubmitProvider> =>
    new Promise<TxSubmitProvider>(async (resolve) => {
      resolve(blockfrostTxSubmitProvider(await getBlockfrostApi()));
    })
);

txSubmitProviderFactory.register('ogmios', async (params: any): Promise<TxSubmitProvider> => {
  if (params.url === undefined) throw new Error('txSubmitHttpProvider: ogmios - Missing URL');

  const connectionConfig = {
    host: params.url.hostname,
    port: params.url.port ? Number.parseInt(params.url.port) : undefined,
    tls: params.url?.protocol === 'wss'
  };

  return new Promise<TxSubmitProvider>(async (resolve) => {
    resolve(ogmiosTxSubmitProvider(createConnectionObject(connectionConfig)));
  });
});

txSubmitProviderFactory.register('http', async (params: any): Promise<TxSubmitProvider> => {
  if (params.url === undefined) throw new Error('txSubmitHttpProvider: http - Missing URL');

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

// Stake Pool providers
stakePoolProviderFactory.register(
  'stub',
  async (): Promise<StakePoolProvider> =>
    new Promise<StakePoolProvider>(async (resolve) => {
      resolve(createStubStakePoolProvider());
    })
);

// Key Agents
keyManagementFactory.register('inMemory', async (params: any): Promise<KeyManagement.AsyncKeyAgent> => {
  const mnemonicWords = (params?.mnemonic || '').split(' ');

  if (mnemonicWords.length === 0) throw new Error(KEY_AGENT_MISSING_MNEMONIC);

  if (params.password === undefined) throw new Error(KEY_AGENT_MISSING_PASSWORD);

  if (params.networkId === undefined) throw new Error(KEY_AGENT_MISSING_NETWORK_ID);

  if (params.accountIndex === undefined) throw new Error(KEY_AGENT_MISSING_ACCOUNT_INDEX);

  return KeyManagement.util.createAsyncKeyAgent(
    await KeyManagement.InMemoryKeyAgent.fromBip39MnemonicWords({
      accountIndex: params.accountIndex,
      getPassword: async () => Buffer.from(params.password),
      mnemonicWords,
      networkId: params.networkId
    })
  );
});

keyManagementFactory.register('ledger', async (params: any): Promise<KeyManagement.AsyncKeyAgent> => {
  if (params.networkId === undefined) throw new Error(KEY_AGENT_MISSING_NETWORK_ID);

  if (params.accountIndex === undefined) throw new Error(KEY_AGENT_MISSING_ACCOUNT_INDEX);

  let deviceConnection: DeviceConnection | null | undefined;
  const ledgerKeyAgent = KeyManagement.LedgerKeyAgent.createWithDevice({
    accountIndex: params.accountIndex,
    communicationType: KeyManagement.CommunicationType.Node,
    deviceConnection,
    networkId: params.networkId,
    protocolMagic: 1_097_911_063
  });

  return KeyManagement.util.createAsyncKeyAgent(await ledgerKeyAgent);
});

keyManagementFactory.register('trezor', async (params: any): Promise<KeyManagement.AsyncKeyAgent> => {
  if (params.networkId === undefined) throw new Error(KEY_AGENT_MISSING_NETWORK_ID);

  if (params.accountIndex === undefined) throw new Error(KEY_AGENT_MISSING_ACCOUNT_INDEX);

  return KeyManagement.util.createAsyncKeyAgent(
    await KeyManagement.TrezorKeyAgent.createWithDevice({
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
    })
  );
});

/**
 * Utility function to create key agents at different account indices.
 *
 * @param accountIndex The ccount index.
 * @param provider The provider.
 * @param params The provider parameters.
 * @returns a key agent.
 */
export const keyAgentById = memoize(async (accountIndex: number, provider: string, params: any) => {
  params.accountIndex = accountIndex;
  return keyManagementFactory.create(provider, params);
});

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
