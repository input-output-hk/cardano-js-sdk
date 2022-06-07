/* eslint-disable max-statements */
/* eslint-disable @typescript-eslint/no-explicit-any */
import * as mocks from '../mocks';
import { AssetId, createStubStakePoolProvider, somePartialStakePools } from '@cardano-sdk/util-dev';
import {
  Cardano,
  ChainHistoryProvider,
  RewardsProvider,
  UtxoProvider,
  WalletProvider,
  testnetTimeSettings
} from '@cardano-sdk/core';
import { KeyManagement, ObservableWallet, SingleAddressWallet } from '../../src';
import { WalletStores, createInMemoryWalletStores } from '../../src/persistence';
import {
  currentEpoch,
  mockNetworkInfoProvider,
  networkInfo,
  queryTransactionsResult,
  queryTransactionsResult2
} from '../mocks';
import { firstValueFrom } from 'rxjs';
import { waitForWalletStateSettle } from '../util';
import flatten from 'lodash/flatten';

const name = 'Test Wallet';
const address = mocks.utxo[0][0].address!;
const rewardAccount = mocks.rewardAccount;

interface Providers {
  walletProvider: WalletProvider;
  rewardsProvider: RewardsProvider;
  utxoProvider: UtxoProvider;
  chainHistoryProvider: ChainHistoryProvider;
}

const createWallet = async (stores: WalletStores, providers: Providers) => {
  const { rewardsProvider, utxoProvider, walletProvider, chainHistoryProvider } = providers;
  const txSubmitProvider = mocks.mockTxSubmitProvider();
  const assetProvider = mocks.mockAssetProvider();
  const stakePoolProvider = createStubStakePoolProvider();
  const networkInfoProvider = mockNetworkInfoProvider();
  const groupedAddress: KeyManagement.GroupedAddress = {
    accountIndex: 0,
    address,
    index: 0,
    networkId: Cardano.NetworkId.testnet,
    rewardAccount,
    type: KeyManagement.AddressType.External
  };
  const keyAgent = await mocks.testAsyncKeyAgent([groupedAddress]);
  keyAgent.deriveAddress = jest.fn().mockResolvedValue(groupedAddress);
  return new SingleAddressWallet(
    { name },
    {
      assetProvider,
      chainHistoryProvider,
      keyAgent,
      networkInfoProvider,
      rewardsProvider,
      stakePoolProvider,
      stores,
      txSubmitProvider,
      utxoProvider,
      walletProvider
    }
  );
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
  const balanceAvailable = await firstValueFrom(wallet.balance.available$);
  const balanceTotal = await firstValueFrom(wallet.balance.total$);
  expect(balanceAvailable?.coins).toEqual(
    Cardano.util.coalesceValueQuantities(mocks.utxo.map((utxo) => utxo[1].value)).coins
  );
  expect(balanceTotal?.rewards).toBe(mocks.rewardAccountBalance);
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
  expect(rewardAccounts[0].rewardBalance.total).toBe(mocks.rewardAccountBalance);
  // addresses$
  const addresses = await firstValueFrom(wallet.addresses$);
  expect(addresses[0].address).toEqual(address);
  expect(addresses[0].rewardAccount).toEqual(rewardAccount);
  // assets$
  expect(await firstValueFrom(wallet.assets$)).toEqual(new Map([[AssetId.TSLA, mocks.asset]]));
  // networkInfo$
  expect(await firstValueFrom(wallet.networkInfo$)).toEqual(networkInfo);
  // inputAddressResolver
  expect(typeof wallet.util).toBe('object');
};

const assertWalletProperties2 = async (wallet: ObservableWallet) => {
  expect(await firstValueFrom(wallet.utxo.available$)).toEqual(mocks.utxo2);
  expect(await firstValueFrom(wallet.utxo.total$)).toEqual(mocks.utxo2);
  expect((await firstValueFrom(wallet.balance.available$))?.coins).toEqual(
    Cardano.util.coalesceValueQuantities(mocks.utxo2.map((utxo) => utxo[1].value)).coins
  );
  expect((await firstValueFrom(wallet.balance.total$))?.rewards).toBe(mocks.rewardAccountBalance2);
  expect((await firstValueFrom(wallet.transactions.history$))?.length).toEqual(queryTransactionsResult2.length);
  const walletTip = await firstValueFrom(wallet.tip$);
  expect(walletTip).toEqual(mocks.ledgerTip2);
  const walletNetworkInfo = await firstValueFrom(wallet.networkInfo$);
  expect(walletNetworkInfo.network.timeSettings).toEqual(testnetTimeSettings);
  const walletCurrentEpoch = await firstValueFrom(wallet.currentEpoch$);
  expect(walletCurrentEpoch.epochNo).toEqual(currentEpoch.number);
  const walletProtocolParameters = await firstValueFrom(wallet.protocolParameters$);
  expect(walletProtocolParameters).toEqual(mocks.protocolParameters2);
  const walletGenesisParameters = await firstValueFrom(wallet.genesisParameters$);
  expect(walletGenesisParameters).toEqual(mocks.genesisParameters2);
  // delegation
  const rewardsHistory = await firstValueFrom(wallet.delegation.rewardsHistory$)!;
  const expectedRewards = flatten([...mocks.rewardsHistory2.values()]);
  expect(rewardsHistory.all).toEqual(expectedRewards);
  const rewardAccounts = await firstValueFrom(wallet.delegation.rewardAccounts$);
  expect(rewardAccounts).toHaveLength(1);
  expect(rewardAccounts[0].rewardBalance.total).toBe(mocks.rewardAccountBalance2);
};

describe('SingleAddressWallet load', () => {
  it('loads all properties from provider, stores them and restores on subsequent load, fetches new data', async () => {
    const stores = createInMemoryWalletStores();
    const wallet1 = await createWallet(stores, {
      chainHistoryProvider: mocks.mockChainHistoryProvider(),
      rewardsProvider: mocks.mockRewardsProvider(),
      utxoProvider: mocks.mockUtxoProvider(),
      walletProvider: mocks.mockWalletProvider()
    });
    await assertWalletProperties(wallet1, somePartialStakePools[0].id);
    wallet1.shutdown();
    const wallet2 = await createWallet(stores, {
      chainHistoryProvider: mocks.mockChainHistoryProvider2(100),
      rewardsProvider: mocks.mockRewardsProvider2(100),
      utxoProvider: mocks.mockUtxoProvider2(100),
      walletProvider: mocks.mockWalletProvider2(100)
    });
    await assertWalletProperties(wallet2, somePartialStakePools[0].id);
    await waitForWalletStateSettle(wallet2);
    await assertWalletProperties2(wallet2);
    wallet2.shutdown();
  });

  it('syncStatus settles without delegation to any pool', async () => {
    const stores = createInMemoryWalletStores();
    const walletProvider = mocks.mockWalletProvider();
    const rewardsProvider = mocks.mockRewardsProvider();
    const chainHistoryProvider = mocks.mockChainHistoryProvider();
    const utxoProvider = mocks.mockUtxoProvider();
    const txsWithNoCertificates = queryTransactionsResult.filter((tx) => !tx.body.certificates);
    chainHistoryProvider.transactionsByAddresses.mockResolvedValue(txsWithNoCertificates);
    const wallet = await createWallet(stores, { chainHistoryProvider, rewardsProvider, utxoProvider, walletProvider });
    // eslint-disable-next-line unicorn/no-useless-undefined
    await assertWalletProperties(wallet, undefined, []);
    await waitForWalletStateSettle(wallet);
    wallet.shutdown();
  });
});
