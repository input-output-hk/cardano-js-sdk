/* eslint-disable max-len */
import * as mocks from '../mocks';
import { AddressType, GroupedAddress } from '@cardano-sdk/key-management';
import { AssetId, createStubStakePoolProvider } from '@cardano-sdk/util-dev';
import { Cardano, CardanoNodeErrors, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { InitializeTxProps, SingleAddressWallet, setupWallet } from '../../src';
import { firstValueFrom, skip } from 'rxjs';
import { getPassword, testAsyncKeyAgent } from '../../../key-management/test/mocks';
import { dummyLogger as logger } from 'ts-log';
import { mockChainHistoryProvider, mockRewardsProvider, utxo } from '../mocks';
import { waitForWalletStateSettle } from '../util';

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
  let networkInfoProvider: mocks.NetworkInfoProviderStub;
  let wallet: SingleAddressWallet;
  let utxoProvider: mocks.UtxoProviderStub;

  beforeEach(async () => {
    txSubmitProvider = mocks.mockTxSubmitProvider();
    networkInfoProvider = mocks.mockNetworkInfoProvider();
    utxoProvider = mocks.mockUtxoProvider();
    const assetProvider = mocks.mockAssetProvider();
    const stakePoolProvider = createStubStakePoolProvider();
    const rewardsProvider = mockRewardsProvider();
    const chainHistoryProvider = mockChainHistoryProvider();
    const groupedAddress: GroupedAddress = {
      accountIndex: 0,
      address,
      index: 0,
      networkId: Cardano.NetworkId.testnet,
      rewardAccount: mocks.rewardAccount,
      type: AddressType.External
    };
    ({ wallet } = await setupWallet({
      createKeyAgent: async (dependencies) => {
        const asyncKeyAgent = await testAsyncKeyAgent([groupedAddress], dependencies);
        asyncKeyAgent.deriveAddress = jest.fn().mockResolvedValue(groupedAddress);
        return asyncKeyAgent;
      },
      createWallet: async (keyAgent) =>
        new SingleAddressWallet(
          { name: 'Test Wallet' },
          {
            assetProvider,
            chainHistoryProvider,
            keyAgent,
            logger,
            networkInfoProvider,
            rewardsProvider,
            stakePoolProvider,
            txSubmitProvider,
            utxoProvider
          }
        )
    }));
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
        const resolveInputAddressResult = await wallet.util.resolveInputAddress(utxoSet[0][0]);
        expect(typeof resolveInputAddressResult).toBe('string');
      });

      it('returns null for non-wallet-owned utxo', async () => {
        expect(
          await wallet.util.resolveInputAddress({
            index: 9,
            txId: Cardano.TransactionId('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad')
          })
        ).toBe(null);
      });
    });
  });

  describe('creating transactions', () => {
    const props = {
      collaterals: new Set([utxo[2][0]]),
      inputs: new Set<Cardano.TxIn>([utxo[1][0]]),
      mint: new Map([
        [AssetId.PXL, 5n],
        [AssetId.TSLA, 20n]
      ]),
      outputs: new Set<Cardano.TxOut>(outputs),
      requiredExtraSignatures: [Cardano.Ed25519KeyHash('6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed5')],
      scriptIntegrityHash: Cardano.util.Hash32ByteBase16(
        '3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d'
      )
    } as InitializeTxProps;

    it('initializeTx', async () => {
      getPassword.mockClear();
      const { body, hash, inputSelection } = await wallet.initializeTx(props);
      expect(body.outputs).toHaveLength(props.outputs!.size + 1 /* change output */);
      expect(body.collaterals).toEqual([utxo[2][0]]);
      expect(body.mint).toEqual(props.mint);
      expect(body.requiredExtraSignatures).toEqual(props.requiredExtraSignatures);
      expect(body.scriptIntegrityHash).toEqual(props.scriptIntegrityHash);
      expect(typeof hash).toBe('string');
      expect(inputSelection.outputs.size).toBe(props.outputs!.size);
      expect(inputSelection.inputs.size).toBeGreaterThan(0);
      expect(inputSelection.fee).toBeGreaterThan(0n);
      expect(inputSelection.change.size).toBeGreaterThan(0);
      expect(getPassword).not.toBeCalled();
    });

    it('finalizeTx', async () => {
      const txInternals = await wallet.initializeTx(props);
      const tx = await wallet.finalizeTx({ tx: txInternals });
      expect(tx.body).toBe(txInternals.body);
      expect(tx.id).toBe(txInternals.hash);
      expect(tx.witness.signatures.size).toBe(2); // spending key and stake key for withdrawal
    });

    describe('submitTx', () => {
      it('resolves on success', async () => {
        const tx = await wallet.finalizeTx({ tx: await wallet.initializeTx(props) });
        const txSubmitting = firstValueFrom(wallet.transactions.outgoing.submitting$);
        const txPending = firstValueFrom(wallet.transactions.outgoing.pending$);
        const txInFlight = firstValueFrom(wallet.transactions.outgoing.inFlight$.pipe(skip(1)));
        await wallet.submitTx(tx);
        expect(txSubmitProvider.submitTx).toBeCalledTimes(1);
        expect(await txSubmitting).toBe(tx);
        expect(await txPending).toBe(tx);
        expect(await txInFlight).toEqual([{ tx }]);
      });

      it('mightBeAlreadySubmitted option interprets ValueNotConservedError as success', async () => {
        txSubmitProvider.submitTx.mockRejectedValueOnce(
          new ProviderError(
            ProviderFailure.BadRequest,
            new CardanoNodeErrors.TxSubmissionErrors.ValueNotConservedError({
              valueNotConserved: { consumed: 2, produced: 1 }
            })
          )
        );
        const tx = await wallet.finalizeTx({ tx: await wallet.initializeTx(props) });

        // rejects when option is not provided
        await expect(wallet.submitTx(tx)).rejects.toThrow();

        // resolves when option is provided
        const txPending = firstValueFrom(wallet.transactions.outgoing.pending$);
        await expect(wallet.submitTx(tx, { mightBeAlreadySubmitted: true })).resolves.not.toThrow();
        expect(await txPending).toBe(tx);
      });
    });
  });

  it('sync() calls wallet provider functions until shutdown()', () => {
    expect(networkInfoProvider.ledgerTip).toHaveBeenCalledTimes(1);
    wallet.sync();
    expect(networkInfoProvider.ledgerTip).toHaveBeenCalledTimes(2);
    wallet.shutdown();
    wallet.sync();
    expect(networkInfoProvider.ledgerTip).toHaveBeenCalledTimes(2);
  });

  it('signData calls cip30signData', async () => {
    const response = await wallet.signData({ payload: Cardano.util.HexBlob('abc123'), signWith: address });
    expect(response).toHaveProperty('signature');
  });
});
