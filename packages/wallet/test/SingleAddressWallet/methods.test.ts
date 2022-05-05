/* eslint-disable max-len */
import * as mocks from '../mocks';
import { AssetId, createStubStakePoolSearchProvider } from '@cardano-sdk/util-dev';
import { Cardano } from '@cardano-sdk/core';
import { KeyManagement, SingleAddressWallet } from '../../src';
import { firstValueFrom, skip } from 'rxjs';
import { mockNetworkInfoProvider, utxo } from '../mocks';
import { waitForWalletStateSettle } from '../util';

jest.mock('../../src/KeyManagement/cip8/cip30signData');
const { cip30signData } = jest.requireMock('../../src/KeyManagement/cip8/cip30signData');

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

describe('SingleAddressWallet methods', () => {
  const address = mocks.utxo[0][0].address!;
  let txSubmitProvider: mocks.TxSubmitProviderStub;
  let walletProvider: mocks.WalletProviderStub;
  let wallet: SingleAddressWallet;
  let utxoProvider: mocks.UtxoProviderStub;

  beforeEach(async () => {
    const keyAgent = await mocks.testKeyAgent();
    txSubmitProvider = mocks.mockTxSubmitProvider();
    walletProvider = mocks.mockWalletProvider();
    utxoProvider = mocks.mockUtxoProvider();
    const assetProvider = mocks.mockAssetProvider();
    const stakePoolSearchProvider = createStubStakePoolSearchProvider();
    const networkInfoProvider = mockNetworkInfoProvider();
    const groupedAddress: KeyManagement.GroupedAddress = {
      accountIndex: 0,
      address,
      index: 0,
      networkId: Cardano.NetworkId.testnet,
      rewardAccount: mocks.rewardAccount,
      type: KeyManagement.AddressType.External
    };
    keyAgent.deriveAddress = jest.fn().mockResolvedValue(groupedAddress);
    wallet = new SingleAddressWallet(
      { name: 'Test Wallet' },
      {
        assetProvider,
        keyAgent,
        networkInfoProvider,
        stakePoolSearchProvider,
        txSubmitProvider,
        utxoProvider,
        walletProvider
      }
    );
    keyAgent.knownAddresses.push(groupedAddress);
    await waitForWalletStateSettle(wallet);
  });

  afterEach(() => {
    wallet.shutdown();
  });

  describe('util', () => {
    describe('validateOutput', () => {
      it('without assets', async () => {
        const validation = await wallet.util.validateOutput(outputs[0]);
        expect(validation.coinMissing).toBe(0n);
        expect(validation.minimumCoin).toBeGreaterThan(0n);
        expect(validation.tokenBundleSizeExceedsLimit).toBe(false);
      });

      it('with assets', async () => {
        const validation = await wallet.util.validateOutput(outputs[1]);
        expect(validation.coinMissing).toBe(validation.minimumCoin - outputs[1].value.coins);
        expect(validation.minimumCoin).toBeGreaterThan(0n);
        expect(validation.tokenBundleSizeExceedsLimit).toBe(false);
      });

      it('token bundle size exceeds limit', async () => {
        const generateAssetId = () =>
          Cardano.AssetId(
            [...Array.from({ length: 56 })].map(() => Math.floor(Math.random() * 16).toString(16)).join('')
          );
        const output: Cardano.TxOut = {
          address: outputs[1].address,
          value: {
            assets: new Map<Cardano.AssetId, bigint>(Array.from({ length: 100 }).map(() => [generateAssetId(), 1234n])),
            coins: 0n
          }
        };
        const validation = await wallet.util.validateOutput(output);
        expect(validation.coinMissing).toBeGreaterThan(0n);
        expect(validation.tokenBundleSizeExceedsLimit).toBe(true);
      });
    });

    describe('validateOutputs', () => {
      it('returns minimum coin quantity per output', async () => {
        const outputValidations = await wallet.util.validateOutputs(outputs);
        expect(outputValidations.size).toBe(2);
        const outputWithoutAssetsMinimumCoin = outputValidations.get(outputs[0])!;
        const outputWithAssetsMinimumCoin = outputValidations.get(outputs[1])!;
        expect(outputWithoutAssetsMinimumCoin.minimumCoin).toBeGreaterThan(0n);
        expect(outputWithAssetsMinimumCoin.minimumCoin).toBeGreaterThan(outputWithoutAssetsMinimumCoin.minimumCoin);
        expect(outputWithoutAssetsMinimumCoin.coinMissing).toBe(0n);
        expect(outputWithAssetsMinimumCoin.coinMissing).toBe(
          outputWithAssetsMinimumCoin.minimumCoin - outputs[1].value.coins
        );
      });
    });

    describe('resolveInputAddress', () => {
      it('returns input address for wallet-owned utxo', async () => {
        const utxoSet = await firstValueFrom(wallet.utxo.available$);
        expect(typeof wallet.util.resolveInputAddress(utxoSet[0][0])).toBe('string');
      });

      it('returns null for non-wallet-owned utxo', async () => {
        expect(
          wallet.util.resolveInputAddress({
            index: 9,
            txId: Cardano.TransactionId('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad')
          })
        ).toBe(null);
      });
    });
  });

  describe('creating transactions', () => {
    const props = {
      inputs: new Set<Cardano.TxIn>([utxo[1][0]]),
      outputs: new Set<Cardano.TxOut>(outputs)
    };

    it('initializeTx', async () => {
      mocks.getPassword.mockClear();
      const { body, hash, inputSelection } = await wallet.initializeTx(props);
      expect(body.outputs).toHaveLength(props.outputs.size + 1 /* change output */);
      expect(typeof hash).toBe('string');
      expect(inputSelection.outputs.size).toBe(props.outputs.size);
      expect(inputSelection.inputs.size).toBeGreaterThan(0);
      expect(inputSelection.fee).toBeGreaterThan(0n);
      expect(inputSelection.change.size).toBeGreaterThan(0);
      expect(mocks.getPassword).not.toBeCalled();
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
