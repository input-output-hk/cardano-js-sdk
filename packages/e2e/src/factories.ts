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
  UtxoProvider,
  WalletProvider
} from '@cardano-sdk/core';
import {
  BlockFrostAPI,
  blockfrostAssetProvider,
  blockfrostChainHistoryProvider,
  blockfrostNetworkInfoProvider,
  blockfrostRewardsProvider,
  blockfrostTxSubmitProvider,
  blockfrostUtxoProvider,
  blockfrostWalletProvider
} from '@cardano-sdk/blockfrost';
import { CardanoWalletFaucetProvider, FaucetProvider } from './FaucetProvider';
import { KeyManagement } from '@cardano-sdk/wallet';
import { createStubStakePoolProvider } from '@cardano-sdk/util-dev';
import DeviceConnection from '@cardano-foundation/ledgerjs-hw-app-cardano';

const BLOCKFROST_MISSING_FLAG = 'Missing isTestnet flag';
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
 * @param isTestnet True to query the testnet network; and otherwise
 * to query the mainnet network.
 * @param projectId The blockfrost project api/api key.
 * @returns The blockfrost API instance, this function always returns the same instance.
 */
const getBlockfrostApi = async (isTestnet: boolean, projectId: string) => {
  if (blockfrostApi !== undefined) return blockfrostApi;

  return new BlockFrostAPI({ isTestnet, projectId });
};

export const faucetProviderFactory = new ProviderFactory<FaucetProvider>();
export const keyManagementFactory = new ProviderFactory<KeyManagement.AsyncKeyAgent>();
export const assetProviderFactory = new ProviderFactory<AssetProvider>();
export const chainHistoryProviderFactory = new ProviderFactory<ChainHistoryProvider>();
export const networkInfoProviderFactory = new ProviderFactory<NetworkInfoProvider>();
export const rewardsProviderFactory = new ProviderFactory<RewardsProvider>();
export const txSubmitProviderFactory = new ProviderFactory<TxSubmitProvider>();
export const utxoProviderFactory = new ProviderFactory<UtxoProvider>();
export const walletProviderFactory = new ProviderFactory<WalletProvider>();
export const stakePoolProviderFactory = new ProviderFactory<StakePoolProvider>();

// Faucet providers
faucetProviderFactory.register(CardanoWalletFaucetProvider.name, CardanoWalletFaucetProvider.create);

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
  NullAssetProvider.name,
  async (): Promise<AssetProvider> =>
    new Promise<AssetProvider>(async (resolve) => {
      resolve(new NullAssetProvider());
    })
);

assetProviderFactory.register(
  blockfrostAssetProvider.name,
  async (params: any): Promise<AssetProvider> =>
    new Promise<AssetProvider>(async (resolve) => {
      if (params.isTestnet === undefined) throw new Error(BLOCKFROST_MISSING_FLAG);

      if (params.projectId === undefined) throw new Error(BLOCKFROST_MISSING_PROJECT_ID);

      resolve(blockfrostAssetProvider(await getBlockfrostApi(params.isTestnet, params.projectId)));
    })
);

// Chain history providers
chainHistoryProviderFactory.register(
  blockfrostChainHistoryProvider.name,
  async (params: any): Promise<ChainHistoryProvider> =>
    new Promise<ChainHistoryProvider>(async (resolve) => {
      if (params.isTestnet === undefined) throw new Error(BLOCKFROST_MISSING_FLAG);

      if (params.projectId === undefined) throw new Error(BLOCKFROST_MISSING_PROJECT_ID);

      resolve(blockfrostChainHistoryProvider(await getBlockfrostApi(params.isTestnet, params.projectId)));
    })
);

// Network info providers
networkInfoProviderFactory.register(
  blockfrostNetworkInfoProvider.name,
  async (params: any): Promise<NetworkInfoProvider> =>
    new Promise<NetworkInfoProvider>(async (resolve) => {
      if (params.isTestnet === undefined) throw new Error(BLOCKFROST_MISSING_FLAG);

      if (params.projectId === undefined) throw new Error(BLOCKFROST_MISSING_PROJECT_ID);

      resolve(blockfrostNetworkInfoProvider(await getBlockfrostApi(params.isTestnet, params.projectId)));
    })
);

// Rewards providers
rewardsProviderFactory.register(
  blockfrostRewardsProvider.name,
  async (params: any): Promise<RewardsProvider> =>
    new Promise<RewardsProvider>(async (resolve) => {
      if (params.isTestnet === undefined) throw new Error(BLOCKFROST_MISSING_FLAG);

      if (params.projectId === undefined) throw new Error(BLOCKFROST_MISSING_PROJECT_ID);

      resolve(blockfrostRewardsProvider(await getBlockfrostApi(params.isTestnet, params.projectId)));
    })
);

// Tx submit providers
txSubmitProviderFactory.register(
  blockfrostTxSubmitProvider.name,
  async (params: any): Promise<TxSubmitProvider> =>
    new Promise<TxSubmitProvider>(async (resolve) => {
      if (params.isTestnet === undefined) throw new Error(BLOCKFROST_MISSING_FLAG);

      if (params.projectId === undefined) throw new Error(BLOCKFROST_MISSING_PROJECT_ID);

      resolve(blockfrostTxSubmitProvider(await getBlockfrostApi(params.isTestnet, params.projectId)));
    })
);

// Utxo providers
utxoProviderFactory.register(
  blockfrostUtxoProvider.name,
  async (params: any): Promise<UtxoProvider> =>
    new Promise<UtxoProvider>(async (resolve) => {
      if (params.isTestnet === undefined) throw new Error(BLOCKFROST_MISSING_FLAG);

      if (params.projectId === undefined) throw new Error(BLOCKFROST_MISSING_PROJECT_ID);

      resolve(blockfrostUtxoProvider(await getBlockfrostApi(params.isTestnet, params.projectId)));
    })
);

// Wallet providers
walletProviderFactory.register(
  blockfrostWalletProvider.name,
  async (params: any): Promise<WalletProvider> =>
    new Promise<WalletProvider>(async (resolve) => {
      if (params.isTestnet === undefined) throw new Error(BLOCKFROST_MISSING_FLAG);

      if (params.projectId === undefined) throw new Error(BLOCKFROST_MISSING_PROJECT_ID);

      resolve(blockfrostWalletProvider(await getBlockfrostApi(params.isTestnet, params.projectId)));
    })
);

// Stake Pool providers
stakePoolProviderFactory.register(
  'NullStubStakePoolProvider',
  async (): Promise<StakePoolProvider> =>
    new Promise<StakePoolProvider>(async (resolve) => {
      resolve(createStubStakePoolProvider());
    })
);

// Key Agents
keyManagementFactory.register(
  KeyManagement.InMemoryKeyAgent.name,
  async (params: any): Promise<KeyManagement.AsyncKeyAgent> => {
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
  }
);

keyManagementFactory.register(
  KeyManagement.LedgerKeyAgent.name,
  async (params: any): Promise<KeyManagement.AsyncKeyAgent> => {
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
  }
);

keyManagementFactory.register(
  KeyManagement.TrezorKeyAgent.name,
  async (params: any): Promise<KeyManagement.AsyncKeyAgent> => {
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
  }
);
