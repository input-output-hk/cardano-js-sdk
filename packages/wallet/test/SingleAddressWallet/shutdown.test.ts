/* eslint-disable max-statements */
/* eslint-disable @typescript-eslint/no-explicit-any */
import * as mocks from '../mocks';
import { AddressType, GroupedAddress } from '@cardano-sdk/key-management';
import { AssetId, createStubStakePoolProvider, somePartialStakePools } from '@cardano-sdk/util-dev';
import {
  Cardano,
  ChainHistoryProvider,
  NetworkInfoProvider,
  RewardsProvider,
  UtxoProvider,
  coalesceValueQuantities
} from '@cardano-sdk/core';
import {
  ConnectionStatusTracker,
  PollingConfig,
  SingleAddressWallet,
  TxSubmitProviderStats,
  WalletNetworkInfoProviderStats,
  setupWallet
} from '../../src';
import { WalletStores, createInMemoryWalletStores } from '../../src/persistence';
import { currentEpoch } from '../mocks';
import { firstValueFrom } from 'rxjs';
import { dummyLogger as logger } from 'ts-log';
import { testAsyncKeyAgent, testKeyAgent } from '../../../key-management/test/mocks';
import flatten from 'lodash/flatten';

const name = 'Test Wallet';
const address = mocks.utxo[0][0].address!;
const rewardAccount = mocks.rewardAccount;

interface Providers {
  rewardsProvider: RewardsProvider;
  utxoProvider: UtxoProvider;
  chainHistoryProvider: ChainHistoryProvider;
  networkInfoProvider: NetworkInfoProvider;
  connectionStatusTracker$?: ConnectionStatusTracker;
}

const createWallet = async (
  stores: WalletStores,
  providers: Providers,
  shutdownSpy?: () => void,
  pollingConfig?: PollingConfig
) => {
  const { wallet } = await setupWallet({
    createKeyAgent: async (dependencies) => {
      const groupedAddress: GroupedAddress = {
        accountIndex: 0,
        address,
        index: 0,
        networkId: Cardano.NetworkId.testnet,
        rewardAccount,
        stakeKeyDerivationPath: mocks.stakeKeyDerivationPath,
        type: AddressType.External
      };
      const asyncKeyAgent = await testAsyncKeyAgent(
        [groupedAddress],
        dependencies,
        testKeyAgent([groupedAddress], dependencies),
        shutdownSpy
      );
      asyncKeyAgent.deriveAddress = jest.fn().mockResolvedValue(groupedAddress);
      return asyncKeyAgent;
    },
    createWallet: async (keyAgent) => {
      const { rewardsProvider, utxoProvider, chainHistoryProvider, networkInfoProvider, connectionStatusTracker$ } =
        providers;
      const txSubmitProvider = mocks.mockTxSubmitProvider();
      const assetProvider = mocks.mockAssetProvider();
      const stakePoolProvider = createStubStakePoolProvider();

      return new SingleAddressWallet(
        { name, polling: pollingConfig },
        {
          assetProvider,
          chainHistoryProvider,
          connectionStatusTracker$,
          keyAgent,
          logger,
          networkInfoProvider,
          rewardsProvider,
          stakePoolProvider,
          stores,
          txSubmitProvider,
          utxoProvider
        }
      );
    }
  });
  return wallet;
};

const assertWalletProperties = async (
  wallet: SingleAddressWallet,
  expectedDelegateeId: Cardano.PoolId | undefined,
  expectedRewardsHistory = flatten([...mocks.rewardsHistory.values()])
) => {
  expect(wallet.keyAgent).toBeTruthy();
  // name
  expect(wallet.name).toBe(name);
  // utxo
  const utxoAvailable = await firstValueFrom(wallet.utxo.available$);
  const utxoTotal = await firstValueFrom(wallet.utxo.total$);
  expect(utxoAvailable).toEqual(mocks.utxo);
  expect(utxoTotal).toEqual(mocks.utxo);
  // balance
  const balanceAvailable = await firstValueFrom(wallet.balance.utxo.available$);
  expect(balanceAvailable?.coins).toEqual(coalesceValueQuantities(mocks.utxo.map((utxo) => utxo[1].value)).coins);
  expect(await firstValueFrom(wallet.balance.rewardAccounts.rewards$)).toBe(mocks.rewardAccountBalance);
  // transactions
  const transactionsHistory = await firstValueFrom(wallet.transactions.history$);
  expect(transactionsHistory?.length).toBeGreaterThan(0);
  // tip$
  await firstValueFrom(wallet.tip$);
  expect(wallet.tip$.value).toEqual(mocks.ledgerTip);
  // currentEpoch$
  expect(wallet.currentEpoch$.value?.epochNo).toEqual(currentEpoch.number);
  // protocolParameters$
  await firstValueFrom(wallet.protocolParameters$);
  expect(wallet.protocolParameters$.value).toEqual(mocks.protocolParameters);
  // genesisParameters$
  await firstValueFrom(wallet.genesisParameters$);
  expect(wallet.genesisParameters$.value).toEqual(mocks.genesisParameters);
  // delegation
  const rewardsHistory = await firstValueFrom(wallet.delegation.rewardsHistory$);
  const expectedRewards = expectedRewardsHistory;
  expect(rewardsHistory.all).toEqual(expectedRewards);
  const rewardAccounts = await firstValueFrom(wallet.delegation.rewardAccounts$);
  expect(rewardAccounts).toHaveLength(1);
  expect(rewardAccounts[0].address).toBe(rewardAccount);
  expect(rewardAccounts[0].delegatee?.nextNextEpoch?.id).toEqual(expectedDelegateeId);
  expect(rewardAccounts[0].rewardBalance).toBe(mocks.rewardAccountBalance);
  // addresses$
  const addresses = await firstValueFrom(wallet.addresses$);
  expect(addresses[0].address).toEqual(address);
  expect(addresses[0].rewardAccount).toEqual(rewardAccount);
  // assets$
  expect(await firstValueFrom(wallet.assets$)).toEqual(new Map([[AssetId.TSLA, mocks.asset]]));
  // inputAddressResolver
  expect(typeof wallet.util).toBe('object');
};

describe('SingleAddressWallet shutdown', () => {
  // These two properties are not reachable via the public interface of the wallet.
  let txSubmitProviderStats: any;
  let walletNetworkInfoProviderStats: any;

  beforeAll(() => {
    txSubmitProviderStats = jest.spyOn(TxSubmitProviderStats.prototype, 'shutdown');
    walletNetworkInfoProviderStats = jest.spyOn(WalletNetworkInfoProviderStats.prototype, 'shutdown');
  });

  afterAll(() => {
    jest.restoreAllMocks();
  });

  it('completes all wallet Subjects', async () => {
    let isKeyAgentShutdown = false;
    let isCurrentEpoch$Completed = false;
    let tip$Completed = false;
    let eraSummaries$Completed = false;
    let addresses$Completed = false;
    let protocolParameters$Completed = false;
    let genesisParameters$Completed = false;
    let assets$Completed = false;

    const stores = createInMemoryWalletStores();
    const wallet1 = await createWallet(
      stores,
      {
        chainHistoryProvider: mocks.mockChainHistoryProvider(),
        networkInfoProvider: mocks.mockNetworkInfoProvider(),
        rewardsProvider: mocks.mockRewardsProvider(),
        utxoProvider: mocks.mockUtxoProvider()
      },
      () => {
        isKeyAgentShutdown = true;
      }
    );

    // Verify all observables have completed.
    wallet1.currentEpoch$.subscribe({
      complete: () => {
        isCurrentEpoch$Completed = true;
      }
    });

    wallet1.currentEpoch$.subscribe({
      complete: () => {
        isCurrentEpoch$Completed = true;
      }
    });

    wallet1.tip$.subscribe({
      complete: () => {
        tip$Completed = true;
      }
    });

    wallet1.eraSummaries$.subscribe({
      complete: () => {
        eraSummaries$Completed = true;
      }
    });

    wallet1.addresses$.subscribe({
      complete: () => {
        addresses$Completed = true;
      }
    });

    wallet1.protocolParameters$.subscribe({
      complete: () => {
        protocolParameters$Completed = true;
      }
    });

    wallet1.genesisParameters$.subscribe({
      complete: () => {
        genesisParameters$Completed = true;
      }
    });

    wallet1.assets$.subscribe({
      complete: () => {
        assets$Completed = true;
      }
    });

    await assertWalletProperties(wallet1, somePartialStakePools[0].id);

    // Verify all other properties have been shutdown.
    const utxo = jest.spyOn(wallet1.utxo, 'shutdown');
    const transactions = jest.spyOn(wallet1.transactions, 'shutdown');
    const delegation = jest.spyOn(wallet1.delegation, 'shutdown');
    const syncStatus = jest.spyOn(wallet1.syncStatus, 'shutdown');
    const assetProviderStatsShutdown = jest.spyOn(wallet1.assetProvider.stats, 'shutdown');
    const chainHistoryProviderStats = jest.spyOn(wallet1.chainHistoryProvider.stats, 'shutdown');
    const rewardsProviderStats = jest.spyOn(wallet1.rewardsProvider.stats, 'shutdown');
    const stakePoolProviderStats = jest.spyOn(wallet1.stakePoolProvider.stats, 'shutdown');
    const utxoProviderStats = jest.spyOn(wallet1.utxoProvider.stats, 'shutdown');

    wallet1.shutdown();

    expect(assetProviderStatsShutdown).toHaveBeenCalledTimes(1);
    expect(chainHistoryProviderStats).toHaveBeenCalledTimes(1);
    expect(rewardsProviderStats).toHaveBeenCalledTimes(1);
    expect(stakePoolProviderStats).toHaveBeenCalledTimes(1);
    expect(txSubmitProviderStats).toHaveBeenCalledTimes(1);
    expect(utxoProviderStats).toHaveBeenCalledTimes(1);
    expect(walletNetworkInfoProviderStats).toHaveBeenCalledTimes(1);
    expect(isKeyAgentShutdown).toBeTruthy();
    expect(isCurrentEpoch$Completed).toBeTruthy();
    expect(tip$Completed).toBeTruthy();
    expect(eraSummaries$Completed).toBeTruthy();
    expect(addresses$Completed).toBeTruthy();
    expect(protocolParameters$Completed).toBeTruthy();
    expect(genesisParameters$Completed).toBeTruthy();
    expect(assets$Completed).toBeTruthy();
    expect(utxo).toHaveBeenCalledTimes(1);
    expect(transactions).toHaveBeenCalledTimes(1);
    expect(delegation).toHaveBeenCalledTimes(1);
    expect(syncStatus).toHaveBeenCalledTimes(1);
  });
});
