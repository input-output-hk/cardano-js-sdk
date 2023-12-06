/* eslint-disable max-statements */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { AddressType, Bip32Account, GroupedAddress, util } from '@cardano-sdk/key-management';
import {
  AssetId,
  createStubStakePoolProvider,
  mockProviders as mocks,
  somePartialStakePools
} from '@cardano-sdk/util-dev';
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
  PersonalWallet,
  PollingConfig,
  TxSubmitProviderStats,
  WalletNetworkInfoProviderStats
} from '../../src';
import { WalletStores, createInMemoryWalletStores } from '../../src/persistence';
import { firstValueFrom } from 'rxjs';
import { dummyLogger as logger } from 'ts-log';
import { stakeKeyDerivationPath, testAsyncKeyAgent, testKeyAgent } from '../../../key-management/test/mocks';
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

const createWallet = async (stores: WalletStores, providers: Providers, pollingConfig?: PollingConfig) => {
  const groupedAddress: GroupedAddress = {
    accountIndex: 0,
    address,
    index: 0,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount,
    stakeKeyDerivationPath,
    type: AddressType.External
  };
  const asyncKeyAgent = await testAsyncKeyAgent(undefined, testKeyAgent());
  const bip32Account = await Bip32Account.fromAsyncKeyAgent(asyncKeyAgent);
  bip32Account.deriveAddress = jest.fn().mockResolvedValue(groupedAddress);
  const { rewardsProvider, utxoProvider, chainHistoryProvider, networkInfoProvider, connectionStatusTracker$ } =
    providers;
  const txSubmitProvider = mocks.mockTxSubmitProvider();
  const assetProvider = mocks.mockAssetProvider();
  const stakePoolProvider = createStubStakePoolProvider();

  return new PersonalWallet(
    { name, polling: pollingConfig },
    {
      assetProvider,
      bip32Account,
      chainHistoryProvider,
      connectionStatusTracker$,
      logger,
      networkInfoProvider,
      rewardsProvider,
      stakePoolProvider,
      stores,
      txSubmitProvider,
      utxoProvider,
      witnesser: util.createBip32Ed25519Witnesser(asyncKeyAgent)
    }
  );
};

const assertWalletProperties = async (
  wallet: PersonalWallet,
  expectedDelegateeId: Cardano.PoolId | undefined,
  expectedRewardsHistory = flatten([...mocks.rewardsHistory.values()])
) => {
  expect(wallet.bip32Account).toBeTruthy();
  expect(wallet.witnesser).toBeTruthy();
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
  expect(wallet.currentEpoch$.value?.epochNo).toEqual(mocks.currentEpoch.number);
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
  expect(await firstValueFrom(wallet.assetInfo$)).toEqual(
    new Map([
      [AssetId.TSLA, mocks.asset],
      [mocks.handleAssetId, mocks.handleAssetInfo]
    ])
  );
  // inputAddressResolver
  expect(typeof wallet.util).toBe('object');
};

describe('PersonalWallet shutdown', () => {
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
    let isCurrentEpoch$Completed = false;
    let tip$Completed = false;
    let eraSummaries$Completed = false;
    let addresses$Completed = false;
    let protocolParameters$Completed = false;
    let genesisParameters$Completed = false;
    let assets$Completed = false;

    const stores = createInMemoryWalletStores();
    const wallet1 = await createWallet(stores, {
      chainHistoryProvider: mocks.mockChainHistoryProvider(),
      networkInfoProvider: mocks.mockNetworkInfoProvider(),
      rewardsProvider: mocks.mockRewardsProvider(),
      utxoProvider: mocks.mockUtxoProvider()
    });

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

    wallet1.assetInfo$.subscribe({
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
