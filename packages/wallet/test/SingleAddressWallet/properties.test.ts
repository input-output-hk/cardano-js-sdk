/* eslint-disable max-len */
import * as mocks from '../mocks';
import { AssetId, createStubStakePoolSearchProvider, createStubTimeSettingsProvider } from '@cardano-sdk/util-dev';
import { Cardano, testnetTimeSettings } from '@cardano-sdk/core';
import { KeyManagement, SingleAddressWallet } from '../../src';
import { firstValueFrom } from 'rxjs';

describe('SingleAddressWallet properties', () => {
  const name = 'Test Wallet';
  const address = mocks.utxo[0][0].address;
  const rewardAccount = mocks.rewardAccount;
  let wallet: SingleAddressWallet;

  beforeEach(async () => {
    const keyAgent = await mocks.testKeyAgent();
    const txSubmitProvider = mocks.mockTxSubmitProvider();
    const walletProvider = mocks.mockWalletProvider();
    const assetProvider = mocks.mockAssetProvider();
    const stakePoolSearchProvider = createStubStakePoolSearchProvider();
    const timeSettingsProvider = createStubTimeSettingsProvider(testnetTimeSettings);
    const groupedAddress: KeyManagement.GroupedAddress = {
      accountIndex: 0,
      address,
      index: 0,
      networkId: Cardano.NetworkId.testnet,
      rewardAccount,
      type: KeyManagement.AddressType.External
    };
    keyAgent.deriveAddress = jest.fn().mockResolvedValue(groupedAddress);
    wallet = new SingleAddressWallet(
      { name },
      { assetProvider, keyAgent, stakePoolSearchProvider, timeSettingsProvider, txSubmitProvider, walletProvider }
    );
    keyAgent.knownAddresses.push(groupedAddress);
  });

  afterEach(() => {
    wallet.shutdown();
  });

  it('"name"', async () => {
    expect(wallet.name).toBe(name);
  });
  it('"utxo"', async () => {
    await firstValueFrom(wallet.utxo.available$);
    await firstValueFrom(wallet.utxo.total$);
    expect(wallet.utxo.available$.value).toEqual(mocks.utxo);
    expect(wallet.utxo.total$.value).toEqual(mocks.utxo);
  });
  it('"balance"', async () => {
    await firstValueFrom(wallet.balance.available$);
    await firstValueFrom(wallet.balance.total$);
    expect(wallet.balance.available$.value?.coins).toEqual(
      Cardano.util.coalesceValueQuantities(mocks.utxo.map((utxo) => utxo[1].value)).coins
    );
    expect(wallet.balance.total$.value?.rewards).toBe(mocks.rewards);
  });
  it('"transactions"', async () => {
    await firstValueFrom(wallet.transactions.history.all$);
    expect(wallet.transactions.history.all$.value?.length).toBeGreaterThan(0);
  });
  it('"tip$"', async () => {
    await firstValueFrom(wallet.tip$);
    expect(wallet.tip$.value).toEqual(mocks.ledgerTip);
  });
  it('"networkInfo$"', async () => {
    await firstValueFrom(wallet.networkInfo$);
    expect(wallet.networkInfo$.value?.currentEpoch).toEqual(mocks.currentEpoch);
  });
  it('"protocolParameters$"', async () => {
    await firstValueFrom(wallet.protocolParameters$);
    expect(wallet.protocolParameters$.value).toEqual(mocks.protocolParameters);
  });
  it('"genesisParameters$"', async () => {
    await firstValueFrom(wallet.genesisParameters$);
    expect(wallet.genesisParameters$.value).toEqual(mocks.genesisParameters);
  });
  it('"delegation"', async () => {
    const rewardsHistory = await firstValueFrom(wallet.delegation.rewardsHistory$);
    expect(rewardsHistory.all).toEqual(mocks.rewardsHistory);
    const rewardAccounts = await firstValueFrom(wallet.delegation.rewardAccounts$);
    expect(rewardAccounts).toHaveLength(1);
    expect(rewardAccounts[0].address).toBe(rewardAccount);
    expect(rewardAccounts[0].delegatee).toBeUndefined();
    expect(rewardAccounts[0].rewardBalance.total).toBe(mocks.rewards);
  });
  it('"addresses$"', async () => {
    const addresses = await firstValueFrom(wallet.addresses$);
    expect(addresses[0].address).toEqual(address);
    expect(addresses[0].rewardAccount).toEqual(rewardAccount);
  });
  it('"assets$"', async () => {
    expect(await firstValueFrom(wallet.assets$)).toEqual(new Map([[AssetId.TSLA, mocks.asset]]));
  });
  it('timeSettings$', async () => {
    expect(await firstValueFrom(wallet.timeSettings$)).toEqual(testnetTimeSettings);
  });
  it('syncStatus$', async () => {
    expect(await firstValueFrom(wallet.syncStatus$)).not.toBeUndefined();
  });
});
