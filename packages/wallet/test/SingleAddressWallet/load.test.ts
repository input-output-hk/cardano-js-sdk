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
  ConnectionStatus,
  ConnectionStatusTracker,
  ObservableWallet,
  PollingConfig,
  SingleAddressWallet,
  setupWallet
} from '../../src';
import { ReplaySubject, firstValueFrom } from 'rxjs';
import { WalletStores, createInMemoryWalletStores } from '../../src/persistence';
import { currentEpoch, networkInfo, queryTransactionsResult, queryTransactionsResult2 } from '../mocks';
import { dummyLogger as logger } from 'ts-log';
import { testAsyncKeyAgent } from '../../../key-management/test/mocks';
import { waitForWalletStateSettle } from '../util';
import delay from 'delay';
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
  const { wallet } = await setupWallet({
    createKeyAgent: async (dependencies) => {
      const groupedAddress: GroupedAddress = {
        accountIndex: 0,
        address,
        index: 0,
        networkId: Cardano.NetworkId.testnet,
        rewardAccount,
        type: AddressType.External
      };
      const asyncKeyAgent = await testAsyncKeyAgent([groupedAddress], dependencies);
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

const assertWalletProperties2 = async (wallet: ObservableWallet) => {
  expect(await firstValueFrom(wallet.utxo.available$)).toEqual(mocks.utxo2);
  expect(await firstValueFrom(wallet.utxo.total$)).toEqual(mocks.utxo2);
  expect((await firstValueFrom(wallet.balance.utxo.available$))?.coins).toEqual(
    coalesceValueQuantities(mocks.utxo2.map((utxo) => utxo[1].value)).coins
  );
  expect(await firstValueFrom(wallet.balance.rewardAccounts.rewards$)).toBe(mocks.rewardAccountBalance2);
  expect((await firstValueFrom(wallet.transactions.history$))?.length).toEqual(queryTransactionsResult2.length);
  const walletTip = await firstValueFrom(wallet.tip$);
  expect(walletTip).toEqual(mocks.ledgerTip2);

  const walletCurrentEpoch = await firstValueFrom(wallet.currentEpoch$);
  expect(walletCurrentEpoch.epochNo).toEqual(currentEpoch.number);
  const walletProtocolParameters = await firstValueFrom(wallet.protocolParameters$);
  expect(walletProtocolParameters).toEqual(mocks.protocolParameters2);
  const walletGenesisParameters = await firstValueFrom(wallet.genesisParameters$);
  expect(walletGenesisParameters).toEqual(mocks.genesisParameters2);

  expect(await firstValueFrom(wallet.eraSummaries$)).toEqual(networkInfo.network.eraSummaries);

  // delegation
  const rewardsHistory = await firstValueFrom(wallet.delegation.rewardsHistory$)!;
  const expectedRewards = flatten([...mocks.rewardsHistory2.values()]);
  expect(rewardsHistory.all).toEqual(expectedRewards);
  const rewardAccounts = await firstValueFrom(wallet.delegation.rewardAccounts$);
  expect(rewardAccounts).toHaveLength(1);
  expect(rewardAccounts[0].rewardBalance).toBe(mocks.rewardAccountBalance2);
};

describe('SingleAddressWallet load', () => {
  it('loads all properties from provider, stores them and restores on subsequent load, fetches new data', async () => {
    const stores = createInMemoryWalletStores();
    const wallet1 = await createWallet(stores, {
      chainHistoryProvider: mocks.mockChainHistoryProvider(),
      networkInfoProvider: mocks.mockNetworkInfoProvider(),
      rewardsProvider: mocks.mockRewardsProvider(),
      utxoProvider: mocks.mockUtxoProvider()
    });
    await assertWalletProperties(wallet1, somePartialStakePools[0].id);
    wallet1.shutdown();
    const wallet2 = await createWallet(stores, {
      chainHistoryProvider: mocks.mockChainHistoryProvider2(100),
      networkInfoProvider: mocks.mockNetworkInfoProvider2(100),
      rewardsProvider: mocks.mockRewardsProvider2(100),
      utxoProvider: mocks.mockUtxoProvider2(100)
    });
    await assertWalletProperties(wallet2, somePartialStakePools[0].id);
    await waitForWalletStateSettle(wallet2);
    await assertWalletProperties2(wallet2);
    wallet2.shutdown();
  });

  it('syncStatus settles without delegation to any pool', async () => {
    const stores = createInMemoryWalletStores();
    const rewardsProvider = mocks.mockRewardsProvider();
    const networkInfoProvider = mocks.mockNetworkInfoProvider();
    const chainHistoryProvider = mocks.mockChainHistoryProvider();
    const utxoProvider = mocks.mockUtxoProvider();
    const txsWithNoCertificates = queryTransactionsResult.filter((tx) => !tx.body.certificates);
    chainHistoryProvider.transactionsByAddresses.mockResolvedValue(txsWithNoCertificates);
    const wallet = await createWallet(stores, {
      chainHistoryProvider,
      networkInfoProvider,
      rewardsProvider,
      utxoProvider
    });
    // eslint-disable-next-line unicorn/no-useless-undefined
    await assertWalletProperties(wallet, undefined, []);
    await waitForWalletStateSettle(wallet);
    wallet.shutdown();
  });

  it('tip value ignored while connection is down', async () => {
    const ONCE_SETTLED_FETCH_AFTER = 5;
    const AUTO_TRIGGER_AFTER = 30;

    const stores = createInMemoryWalletStores();
    const rewardsProvider = mocks.mockRewardsProvider();
    const networkInfoProvider = mocks.mockNetworkInfoProvider();
    // Call to ledgerTip() has to return a different value every time,
    // or else wallet won't fetch any other data from the rest of the providers
    networkInfoProvider.ledgerTip.mockImplementationOnce(
      (() => {
        let numCall = 0;
        return async (): Promise<Cardano.Tip> => {
          const blockNo = ++numCall;
          return {
            blockNo,
            hash: Cardano.BlockId(blockNo.toString(16).padStart(64, '0')),
            slot: blockNo * 100
          };
        };
      })()
    );

    const chainHistoryProvider = mocks.mockChainHistoryProvider();
    const utxoProvider = mocks.mockUtxoProvider();
    utxoProvider.utxoByAddresses = jest
      .fn()
      .mockImplementationOnce(() => mocks.utxo)
      .mockImplementation(
        () =>
          new Promise(() => {
            // Make sure wallet never settles
          })
      );
    const connectionStatusTracker$ = new ReplaySubject<ConnectionStatus>(1);
    const wallet = await createWallet(
      stores,
      {
        chainHistoryProvider,
        connectionStatusTracker$,
        networkInfoProvider,
        rewardsProvider,
        utxoProvider
      },
      { interval: ONCE_SETTLED_FETCH_AFTER, maxInterval: AUTO_TRIGGER_AFTER }
    );

    // Initial fetch when wallet is instantiated
    expect(networkInfoProvider.ledgerTip).toHaveBeenCalledTimes(0);

    // tip$ fetch triggered by ConnectionStatus going up
    connectionStatusTracker$.next(ConnectionStatus.up);
    expect(networkInfoProvider.ledgerTip).toHaveBeenCalledTimes(1);

    // settling from ledgerTip call that was triggered by connectionStatusTracker$.next(ConnectionStatus.up);
    await waitForWalletStateSettle(wallet);
    // max interval should start here
    await delay(ONCE_SETTLED_FETCH_AFTER + 1);
    expect(networkInfoProvider.ledgerTip).toHaveBeenCalledTimes(2);

    // since we changed ledgerTip implementation to never resolve, wallet shouldn't get settled again

    // Auto interval tip$ trigger
    // Don't need to add ONCE_SETTLED_FETCH_AFTER + 1
    // because it's already awaited in a delay above
    await delay(AUTO_TRIGGER_AFTER);
    expect(networkInfoProvider.ledgerTip).toHaveBeenCalledTimes(3);

    // Auto interval tip$ trigger no longer works once offline
    connectionStatusTracker$.next(ConnectionStatus.down);
    await delay(AUTO_TRIGGER_AFTER + ONCE_SETTLED_FETCH_AFTER + 1);
    expect(networkInfoProvider.ledgerTip).toHaveBeenCalledTimes(3);

    wallet.shutdown();
  });
});
