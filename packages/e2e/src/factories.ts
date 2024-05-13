/* eslint-disable @typescript-eslint/no-explicit-any */
import * as CML from '@dcspark/cardano-multiplatform-lib-nodejs';
import * as Crypto from '@cardano-sdk/crypto';
import {
  AddressDiscovery,
  DEFAULT_POLLING_CONFIG,
  HDSequentialDiscovery,
  Milliseconds,
  ObservableWallet,
  PollingConfig,
  SingleAddressDiscovery,
  createPersonalWallet,
  createSharedWallet,
  storage
} from '@cardano-sdk/wallet';
import {
  AssetProvider,
  Cardano,
  ChainHistoryProvider,
  HandleProvider,
  NetworkInfoProvider,
  ProviderFactory,
  RewardsProvider,
  StakePoolProvider,
  TxSubmitProvider,
  UtxoProvider
} from '@cardano-sdk/core';
import {
  AsyncKeyAgent,
  Bip32Account,
  CommunicationType,
  InMemoryKeyAgent,
  KeyAgentDependencies,
  Witnesser,
  util
} from '@cardano-sdk/key-management';
import { LedgerKeyAgent } from '@cardano-sdk/hardware-ledger';
import { Logger } from 'ts-log';
import { OgmiosTxSubmitProvider } from '@cardano-sdk/ogmios';
import { TrezorKeyAgent } from '@cardano-sdk/hardware-trezor';
import {
  assetInfoHttpProvider,
  chainHistoryHttpProvider,
  handleHttpProvider,
  networkInfoHttpProvider,
  rewardsHttpProvider,
  stakePoolHttpProvider,
  txSubmitHttpProvider,
  utxoHttpProvider
} from '@cardano-sdk/cardano-services-client';
import { createConnectionObject } from '@cardano-ogmios/client';
import { createStubStakePoolProvider } from '@cardano-sdk/util-dev';
import { filter, firstValueFrom } from 'rxjs';
import DeviceConnection from '@cardano-foundation/ledgerjs-hw-app-cardano';
import memoize from 'lodash/memoize';

const isNodeJs = typeof process !== 'undefined' && process.release?.name === 'node';
// tsc doesn't like the 'import' of this package, works with webpack
const customHttpFetchAdapter = isNodeJs ? undefined : require('@vespaiach/axios-fetch-adapter').default;

// CONSTANTS
const HTTP_PROVIDER = 'http';
const OGMIOS_PROVIDER = 'ogmios';
const STUB_PROVIDER = 'stub';
const MISSING_URL_PARAM = 'Missing URL';

export type CreateKeyAgent = (dependencies: KeyAgentDependencies) => Promise<AsyncKeyAgent>;
export const keyManagementFactory = new ProviderFactory<CreateKeyAgent>();
export const assetProviderFactory = new ProviderFactory<AssetProvider>();
export const chainHistoryProviderFactory = new ProviderFactory<ChainHistoryProvider>();
export const networkInfoProviderFactory = new ProviderFactory<NetworkInfoProvider>();
export const rewardsProviderFactory = new ProviderFactory<RewardsProvider>();
export const txSubmitProviderFactory = new ProviderFactory<TxSubmitProvider>();
export const utxoProviderFactory = new ProviderFactory<UtxoProvider>();
export const stakePoolProviderFactory = new ProviderFactory<StakePoolProvider>();
export const bip32Ed25519Factory = new ProviderFactory<Crypto.Bip32Ed25519>();
export const addressDiscoveryFactory = new ProviderFactory<AddressDiscovery>();
export const handleProviderFactory = new ProviderFactory<HandleProvider>();

// Address Discovery strategies

addressDiscoveryFactory.register('SingleAddressDiscovery', async () => new SingleAddressDiscovery());
addressDiscoveryFactory.register(
  'HDSequentialDiscovery',
  async ({ chainHistoryProvider }) => new HDSequentialDiscovery(chainHistoryProvider, 20)
);

// bip32Ed25519

bip32Ed25519Factory.register('CML', async () => new Crypto.CmlBip32Ed25519(CML));
bip32Ed25519Factory.register('Sodium', async () => new Crypto.SodiumBip32Ed25519());

// Asset providers

assetProviderFactory.register(HTTP_PROVIDER, async (params: any, logger: Logger): Promise<AssetProvider> => {
  if (params.baseUrl === undefined) throw new Error(`${assetInfoHttpProvider.name}: ${MISSING_URL_PARAM}`);

  return new Promise<AssetProvider>(async (resolve) => {
    resolve(
      assetInfoHttpProvider({
        adapter: customHttpFetchAdapter,
        baseUrl: params.baseUrl,
        logger
      })
    );
  });
});

chainHistoryProviderFactory.register(
  HTTP_PROVIDER,
  async (params: any, logger: Logger): Promise<ChainHistoryProvider> => {
    if (params.baseUrl === undefined) throw new Error(`${chainHistoryHttpProvider.name}: ${MISSING_URL_PARAM}`);

    return new Promise<ChainHistoryProvider>(async (resolve) => {
      resolve(chainHistoryHttpProvider({ adapter: customHttpFetchAdapter, baseUrl: params.baseUrl, logger }));
    });
  }
);

networkInfoProviderFactory.register(
  HTTP_PROVIDER,
  async (params: any, logger: Logger): Promise<NetworkInfoProvider> => {
    if (params.baseUrl === undefined) throw new Error(`${networkInfoHttpProvider.name}: ${MISSING_URL_PARAM}`);

    return new Promise<NetworkInfoProvider>(async (resolve) => {
      resolve(networkInfoHttpProvider({ adapter: customHttpFetchAdapter, baseUrl: params.baseUrl, logger }));
    });
  }
);

rewardsProviderFactory.register(HTTP_PROVIDER, async (params: any, logger: Logger): Promise<RewardsProvider> => {
  if (params.baseUrl === undefined) throw new Error(`${rewardsHttpProvider.name}: ${MISSING_URL_PARAM}`);

  return new Promise<RewardsProvider>(async (resolve) => {
    resolve(rewardsHttpProvider({ adapter: customHttpFetchAdapter, baseUrl: params.baseUrl, logger }));
  });
});

txSubmitProviderFactory.register(OGMIOS_PROVIDER, async (params: any, logger: Logger): Promise<TxSubmitProvider> => {
  if (params.baseUrl === undefined) throw new Error(`${OgmiosTxSubmitProvider.name}: ${MISSING_URL_PARAM}`);

  const connectionConfig = {
    host: params.baseUrl.hostname,
    port: params.baseUrl.port ? Number.parseInt(params.baseUrl.port) : undefined,
    tls: params.baseUrl?.protocol === 'wss'
  };

  return new Promise<TxSubmitProvider>(async (resolve) => {
    resolve(new OgmiosTxSubmitProvider(createConnectionObject(connectionConfig), { logger }));
  });
});

txSubmitProviderFactory.register(HTTP_PROVIDER, async (params: any, logger: Logger): Promise<TxSubmitProvider> => {
  if (params.baseUrl === undefined) throw new Error(`${txSubmitHttpProvider.name}: ${MISSING_URL_PARAM}`);

  return new Promise<TxSubmitProvider>(async (resolve) => {
    resolve(txSubmitHttpProvider({ adapter: customHttpFetchAdapter, baseUrl: params.baseUrl, logger }));
  });
});

utxoProviderFactory.register(HTTP_PROVIDER, async (params: any, logger: Logger): Promise<UtxoProvider> => {
  if (params.baseUrl === undefined) throw new Error(`${utxoHttpProvider.name}: ${MISSING_URL_PARAM}`);

  return new Promise<UtxoProvider>(async (resolve) => {
    resolve(utxoHttpProvider({ adapter: customHttpFetchAdapter, baseUrl: params.baseUrl, logger }));
  });
});

handleProviderFactory.register(HTTP_PROVIDER, async (params: any, logger: Logger): Promise<HandleProvider> => {
  if (params.baseUrl === undefined) throw new Error(`${handleHttpProvider.name}: ${MISSING_URL_PARAM}`);

  return new Promise<HandleProvider>(async (resolve) => {
    resolve(handleHttpProvider({ adapter: customHttpFetchAdapter, baseUrl: params.baseUrl, logger }));
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

stakePoolProviderFactory.register(HTTP_PROVIDER, async (params: any, logger: Logger): Promise<StakePoolProvider> => {
  if (params.baseUrl === undefined) throw new Error(`${stakePoolHttpProvider.name}: ${MISSING_URL_PARAM}`);

  return new Promise<StakePoolProvider>(async (resolve) => {
    resolve(stakePoolHttpProvider({ adapter: customHttpFetchAdapter, baseUrl: params.baseUrl, logger }));
  });
});

// Key Agents
keyManagementFactory.register('inMemory', async (params: any): Promise<CreateKeyAgent> => {
  let mnemonicWords = (params?.mnemonic || '').split(' ');

  if (mnemonicWords.length <= 1) mnemonicWords = util.generateMnemonicWords();

  return async (dependencies) =>
    util.createAsyncKeyAgent(
      await InMemoryKeyAgent.fromBip39MnemonicWords(
        {
          accountIndex: params.accountIndex,
          chainId: params.chainId,
          getPassphrase: async () => Buffer.from(params.passphrase),
          mnemonicWords
        },
        dependencies
      )
    );
});

keyManagementFactory.register('ledger', async (params: any): Promise<CreateKeyAgent> => {
  let deviceConnection: DeviceConnection | null | undefined;

  return async (dependencies) => {
    const ledgerKeyAgent = await LedgerKeyAgent.createWithDevice(
      {
        accountIndex: params.accountIndex,
        chainId: params.chainId,
        communicationType: CommunicationType.Node,
        deviceConnection
      },
      dependencies
    );

    return util.createAsyncKeyAgent(ledgerKeyAgent);
  };
});

keyManagementFactory.register(
  'trezor',
  async (params: any): Promise<CreateKeyAgent> =>
    async (dependencies) =>
      util.createAsyncKeyAgent(
        await TrezorKeyAgent.createWithDevice(
          {
            accountIndex: params.accountIndex,
            chainId: params.chainId,
            trezorConfig: {
              communicationType: CommunicationType.Node,
              manifest: {
                appUrl: 'https://your.application.com',
                email: 'email@developer.com'
              }
            }
          },
          dependencies
        )
      )
);

// Wallet

/**
 * Utility function to create key agents at different account indices.
 *
 * @param accountIndex The account index.
 * @param provider The provider.
 * @param params The provider parameters.
 * @returns a key agent.
 */
export const keyAgentById = memoize(async (accountIndex: number, provider: string, params: any, logger: Logger) => {
  params.accountIndex = accountIndex;
  return keyManagementFactory.create(provider, params, logger);
});

export type KeyAgentFactoryProps = {
  accountIndex: number;
  mnemonic: string;
  chainId: Cardano.ChainId;
  passphrase: string;
};

export type GetWalletProps = {
  env: any;
  idx?: number;
  logger: Logger;
  name: string;
  polling?: PollingConfig;
  handlePolicyIds?: Cardano.PolicyId[];
  stores?: storage.WalletStores;
  customKeyParams?: KeyAgentFactoryProps;
  keyAgent?: AsyncKeyAgent;
  witnesser?: Witnesser;
};

export type GetSharedWalletProps = {
  env: any;
  logger: Logger;
  name: string;
  polling?: PollingConfig;
  handlePolicyIds?: Cardano.PolicyId[];
  stores?: storage.WalletStores;
  witnesser: Witnesser;
  paymentScript: Cardano.RequireAllOfScript | Cardano.RequireAnyOfScript | Cardano.RequireAtLeastScript;
  stakingScript: Cardano.RequireAllOfScript | Cardano.RequireAnyOfScript | Cardano.RequireAtLeastScript;
};

/** Delays initializing tx when nearing the epoch boundary. Relies on system clock being accurate. */
const patchInitializeTxToRespectEpochBoundary = <T extends ObservableWallet>(
  wallet: T,
  maxPollInterval: Milliseconds
) => {
  const originalInitializeTx = wallet.initializeTx.bind(wallet);
  wallet.initializeTx = async function (...props) {
    const { lastSlot, epochNo } = await firstValueFrom(wallet.currentEpoch$);
    const waitForNextEpoch = Date.now() + maxPollInterval * 1.5 - lastSlot.date.getTime() >= 0;
    if (waitForNextEpoch)
      await firstValueFrom(wallet.currentEpoch$.pipe(filter((nextEpoch) => nextEpoch.epochNo > epochNo)));
    return originalInitializeTx(...props);
  };
  return wallet;
};

/**
 * Create a single wallet instance given the environment variables.
 *
 * @param props Wallet configuration parameters.
 * @returns an object containing the wallet and providers passed to it
 */
export const getWallet = async (props: GetWalletProps) => {
  const { env, idx, logger, name, polling, stores, customKeyParams, keyAgent, witnesser } = props;
  const providers = {
    addressDiscovery: await addressDiscoveryFactory.create(
      env.ADDRESS_DISCOVERY,
      {
        chainHistoryProvider: await chainHistoryProviderFactory.create(
          env.CHAIN_HISTORY_PROVIDER,
          env.CHAIN_HISTORY_PROVIDER_PARAMS,
          logger
        )
      },
      logger
    ),
    assetProvider: await assetProviderFactory.create(env.ASSET_PROVIDER, env.ASSET_PROVIDER_PARAMS, logger),
    chainHistoryProvider: await chainHistoryProviderFactory.create(
      env.CHAIN_HISTORY_PROVIDER,
      env.CHAIN_HISTORY_PROVIDER_PARAMS,
      logger
    ),
    handleProvider: await handleProviderFactory.create(env.HANDLE_PROVIDER, env.HANDLE_PROVIDER_PARAMS, logger),
    networkInfoProvider: await networkInfoProviderFactory.create(
      env.NETWORK_INFO_PROVIDER,
      env.NETWORK_INFO_PROVIDER_PARAMS,
      logger
    ),
    rewardsProvider: await rewardsProviderFactory.create(env.REWARDS_PROVIDER, env.REWARDS_PROVIDER_PARAMS, logger),
    stakePoolProvider: await stakePoolProviderFactory.create(
      env.STAKE_POOL_PROVIDER,
      env.STAKE_POOL_PROVIDER_PARAMS,
      logger
    ),
    txSubmitProvider: await txSubmitProviderFactory.create(
      env.TX_SUBMIT_PROVIDER,
      env.TX_SUBMIT_PROVIDER_PARAMS,
      logger
    ),
    utxoProvider: await utxoProviderFactory.create(env.UTXO_PROVIDER, env.UTXO_PROVIDER_PARAMS, logger)
  };
  const envKeyParams = customKeyParams ? customKeyParams : env.KEY_MANAGEMENT_PARAMS;
  const keyManagementParams = { ...envKeyParams, ...(idx === undefined ? {} : { accountIndex: idx }) };

  const bip32Ed25519 = await bip32Ed25519Factory.create(env.KEY_MANAGEMENT_PARAMS.bip32Ed25519, null, logger);
  const asyncKeyAgent =
    keyAgent ||
    (await (
      await keyManagementFactory.create(env.KEY_MANAGEMENT_PROVIDER, keyManagementParams, logger)
    )({
      bip32Ed25519,
      logger
    }));
  const bip32Account = await Bip32Account.fromAsyncKeyAgent(asyncKeyAgent);
  const wallet = createPersonalWallet(
    { name, polling },
    {
      ...providers,
      bip32Account,
      logger,
      stores,
      witnesser: witnesser || util.createBip32Ed25519Witnesser(asyncKeyAgent)
    }
  );

  const [{ address, rewardAccount }] = await firstValueFrom(wallet.addresses$);
  logger.info(`Created wallet "${wallet.name}": ${address}/${rewardAccount}`);

  const maxInterval =
    polling?.maxInterval ||
    (polling?.interval && polling.interval * DEFAULT_POLLING_CONFIG.maxIntervalMultiplier) ||
    DEFAULT_POLLING_CONFIG.maxInterval;
  return { bip32Account, providers, wallet: patchInitializeTxToRespectEpochBoundary(wallet, maxInterval) };
};

/**
 * Create a shared wallet instance given the environment variables.
 *
 * @param props Wallet configuration parameters.
 * @returns an object containing the wallet and providers passed to it
 */
export const getSharedWallet = async (props: GetSharedWalletProps) => {
  const { env, logger, name, polling, stores, paymentScript, stakingScript, witnesser } = props;
  const providers = {
    assetProvider: await assetProviderFactory.create(env.ASSET_PROVIDER, env.ASSET_PROVIDER_PARAMS, logger),
    chainHistoryProvider: await chainHistoryProviderFactory.create(
      env.CHAIN_HISTORY_PROVIDER,
      env.CHAIN_HISTORY_PROVIDER_PARAMS,
      logger
    ),
    handleProvider: await handleProviderFactory.create(env.HANDLE_PROVIDER, env.HANDLE_PROVIDER_PARAMS, logger),
    networkInfoProvider: await networkInfoProviderFactory.create(
      env.NETWORK_INFO_PROVIDER,
      env.NETWORK_INFO_PROVIDER_PARAMS,
      logger
    ),
    rewardsProvider: await rewardsProviderFactory.create(env.REWARDS_PROVIDER, env.REWARDS_PROVIDER_PARAMS, logger),
    stakePoolProvider: await stakePoolProviderFactory.create(
      env.STAKE_POOL_PROVIDER,
      env.STAKE_POOL_PROVIDER_PARAMS,
      logger
    ),
    txSubmitProvider: await txSubmitProviderFactory.create(
      env.TX_SUBMIT_PROVIDER,
      env.TX_SUBMIT_PROVIDER_PARAMS,
      logger
    ),
    utxoProvider: await utxoProviderFactory.create(env.UTXO_PROVIDER, env.UTXO_PROVIDER_PARAMS, logger)
  };
  const wallet = createSharedWallet(
    { name, polling },
    {
      ...providers,
      logger,
      paymentScript,
      stakingScript,
      stores,
      witnesser
    }
  );

  const [{ address, rewardAccount }] = await firstValueFrom(wallet.addresses$);
  logger.info(`Created wallet "${wallet.name}": ${address}/${rewardAccount}`);

  const maxInterval =
    polling?.maxInterval ||
    (polling?.interval && polling.interval * DEFAULT_POLLING_CONFIG.maxIntervalMultiplier) ||
    DEFAULT_POLLING_CONFIG.maxInterval;
  return { providers, wallet: patchInitializeTxToRespectEpochBoundary(wallet, maxInterval) };
};

export type TestWallet = Awaited<ReturnType<typeof getWallet>>;
