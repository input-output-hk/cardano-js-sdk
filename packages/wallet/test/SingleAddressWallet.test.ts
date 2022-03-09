/* eslint-disable max-len */
import * as mocks from './mocks';
import { AssetId, createStubStakePoolSearchProvider, createStubTimeSettingsProvider } from '@cardano-sdk/util-dev';
import { Cardano, testnetTimeSettings } from '@cardano-sdk/core';
import { KeyManagement, SingleAddressWallet } from '../src';
import { firstValueFrom, skip } from 'rxjs';
import { getPassword, testKeyAgent } from './mocks';

jest.mock('../src/KeyManagement/cip8/cip30signData');
const { cip30signData } = jest.requireMock('../src/KeyManagement/cip8/cip30signData');

describe('SingleAddressWallet', () => {
  const name = 'Test Wallet';
  const address = mocks.utxo[0][0].address;
  const rewardAccount = mocks.rewardAccount;
  let keyAgent: KeyManagement.KeyAgent;
  let txSubmitProvider: mocks.TxSubmitProviderStub;
  let walletProvider: mocks.WalletProviderStub;
  let assetProvider: mocks.MockAssetProvider;
  let wallet: SingleAddressWallet;

  beforeEach(async () => {
    keyAgent = await testKeyAgent();
    txSubmitProvider = mocks.mockTxSubmitProvider();
    walletProvider = mocks.mockWalletProvider();
    assetProvider = mocks.mockAssetProvider();
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

  describe('has property', () => {
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

  describe('creating transactions', () => {
    const outputs = [
      {
        address: Cardano.Address(
          'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
        ),
        value: { coins: 11_111_111n }
      },
      {
        address: Cardano.Address(
          'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
        ),
        value: {
          assets: new Map([[AssetId.TSLA, 6n]]),
          coins: 5n
        }
      }
    ];
    const props = {
      outputs: new Set<Cardano.TxOut>(outputs)
    };

    describe('validateTx', () => {
      it('returns minimum coin quantity per output', async () => {
        const { minimumCoinQuantities } = await wallet.validateInitializeTxProps(props);
        expect(minimumCoinQuantities.size).toBe(2);
        const outputWithoutAssetsMinimumCoin = minimumCoinQuantities.get(outputs[0])!;
        const outputWithAssetsMinimumCoin = minimumCoinQuantities.get(outputs[1])!;
        expect(outputWithoutAssetsMinimumCoin.minimumCoin).toBeGreaterThan(0n);
        expect(outputWithAssetsMinimumCoin.minimumCoin).toBeGreaterThan(outputWithoutAssetsMinimumCoin.minimumCoin);
        expect(outputWithoutAssetsMinimumCoin.coinMissing).toBe(0n);
        expect(outputWithAssetsMinimumCoin.coinMissing).toBe(
          outputWithAssetsMinimumCoin.minimumCoin - outputs[1].value.coins
        );
      });
    });

    it('initializeTx', async () => {
      getPassword.mockClear();
      const { body, hash, inputSelection } = await wallet.initializeTx(props);
      expect(body.outputs).toHaveLength(props.outputs.size + 1 /* change output */);
      expect(typeof hash).toBe('string');
      expect(inputSelection.outputs.size).toBe(props.outputs.size);
      expect(inputSelection.inputs.size).toBeGreaterThan(0);
      expect(inputSelection.fee).toBeGreaterThan(0n);
      expect(inputSelection.change.size).toBeGreaterThan(0);
      expect(getPassword).not.toBeCalled();
    });

    it('finalizeTx', async () => {
      const txInternals = await wallet.initializeTx(props);
      const tx = await wallet.finalizeTx(txInternals);
      expect(tx.body).toBe(txInternals.body);
      expect(tx.id).toBe(txInternals.hash);
      expect(tx.witness.signatures.size).toBe(1);
    });

    it('submitTx', async () => {
      const tx = await wallet.finalizeTx(await wallet.initializeTx(props));
      const txSubmitting = firstValueFrom(wallet.transactions.outgoing.submitting$);
      const txPending = firstValueFrom(wallet.transactions.outgoing.pending$);
      const txInFlight = firstValueFrom(wallet.transactions.outgoing.inFlight$.pipe(skip(1)));
      await wallet.submitTx(tx);
      expect(txSubmitProvider.submitTx).toBeCalledTimes(1);
      expect(await txSubmitting).toBe(tx);
      expect(await txPending).toBe(tx);
      expect(await txInFlight).toEqual([tx]);
    });
  });

  it('sync() calls wallet provider functions until shutdown()', () => {
    expect(walletProvider.ledgerTip).toHaveBeenCalledTimes(1);
    wallet.sync();
    expect(walletProvider.ledgerTip).toHaveBeenCalledTimes(2);
    wallet.shutdown();
    wallet.sync();
    expect(walletProvider.ledgerTip).toHaveBeenCalledTimes(2);
  });

  it('signData calls cip30signData', async () => {
    await wallet.signData({ payload: Cardano.util.HexBlob('abc123'), signWith: address });
    expect(cip30signData).toBeCalledTimes(1);
  });
});
