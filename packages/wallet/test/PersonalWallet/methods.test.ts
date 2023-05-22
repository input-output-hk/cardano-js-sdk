/* eslint-disable unicorn/consistent-destructuring */
import * as Crypto from '@cardano-sdk/crypto';
import { AddressType, GroupedAddress } from '@cardano-sdk/key-management';
import { AssetId, createStubStakePoolProvider, mockProviders as mocks } from '@cardano-sdk/util-dev';
import { BehaviorSubject, firstValueFrom, skip } from 'rxjs';
import { CML, Cardano, CardanoNodeErrors, ProviderError, ProviderFailure, TxCBOR } from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';
import { InitializeTxProps } from '@cardano-sdk/tx-construction';
import { PersonalWallet, setupWallet } from '../../src';
import { getPassphrase, stakeKeyDerivationPath, testAsyncKeyAgent } from '../../../key-management/test/mocks';
import { dummyLogger as logger } from 'ts-log';
import { toOutgoingTx, waitForWalletStateSettle } from '../util';

const { mockChainHistoryProvider, mockRewardsProvider, utxo } = mocks;

// We can't consistently re-serialize this specific tx due to witness.datums list format
const serializedForeignTx =
  '84a60081825820260aed6e7a24044b1254a87a509468a649f522a4e54e830ac10f27ea7b5ec61f01018383581d70b429738bd6cc58b5c7932d001aa2bd05cfea47020a556c8c753d44361a004c4b40582007845f8f3841996e3d8157954e2f5e2fb90465f27112fc5fe9056d916fae245b82583900b1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c68042f1946335c498d2e7556c5c647c4649c6a69d2b645cd1428a339ba1a0463676982583900b1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c68042f1946335c498d2e7556c5c647c4649c6a69d2b645cd1428a339ba821a00177a6ea2581c648823ffdad1610b4162f4dbc87bd47f6f9cf45d772ddef661eff198a5447742544319271044774554481a0031f9194577444f47451a0056898d4577555344431a000fc589467753484942411a000103c2581c659ab0b5658687c2e74cd10dba8244015b713bf503b90557769d77a7a14a57696e675269646572731a02269552021a0002e665031a02414F03081a02414EFA0b58204107eada931c72a600a6e3305bd22c7aeb9ada7c3f6823b155f4db85de36a69aa20081825820e686ade5bc97372f271fd2abc06cfd96c24b3d9170f9459de1d8e3dd8fd385575840653324a9dddad004f05a8ac99fa2d1811af5f00543591407fb5206cfe9ac91bb1412404323fa517e0e189684cd3592e7f74862e3f16afbc262519abec958180c0481d8799fd8799fd8799fd8799f581cb1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c68ffd8799fd8799fd8799f581c042f1946335c498d2e7556c5c647c4649c6a69d2b645cd1428a339baffffffff581cb1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c681b000001863784a12ed8799fd8799f4040ffd8799f581c648823ffdad1610b4162f4dbc87bd47f6f9cf45d772ddef661eff1984577444f4745ffffffd8799fd87980190c8efffff5f6';

const outputs = [
  {
    address: Cardano.PaymentAddress(
      'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
    ),
    value: { coins: 11_111_111n }
  },
  {
    address: Cardano.PaymentAddress(
      'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
    ),
    value: {
      assets: new Map([[AssetId.TSLA, 6n]]),
      coins: 5n
    }
  }
];

/** Waits `timeout` for `p` to resolve, then rejects with 'TIMEOUT' */
const promiseTimeout = (p: Promise<unknown>, timeout = 10): Promise<unknown> => {
  const timeoutReject = new Promise((_resolve, reject) => {
    setTimeout(() => {
      reject('TIMEOUT');
    }, timeout);
  });

  return Promise.race([p, timeoutReject]);
};

describe('PersonalWallet methods', () => {
  const address = mocks.utxo[0][0].address!;
  let txSubmitProvider: mocks.TxSubmitProviderStub;
  let networkInfoProvider: mocks.NetworkInfoProviderStub;
  let wallet: PersonalWallet;
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
      networkId: Cardano.NetworkId.Testnet,
      rewardAccount: mocks.rewardAccount,
      stakeKeyDerivationPath,
      type: AddressType.External
    };
    ({ wallet } = await setupWallet({
      bip32Ed25519: new Crypto.CmlBip32Ed25519(CML),
      createKeyAgent: async (dependencies) => {
        const asyncKeyAgent = await testAsyncKeyAgent([groupedAddress], dependencies);
        asyncKeyAgent.deriveAddress = jest.fn().mockResolvedValue(groupedAddress);
        return asyncKeyAgent;
      },
      createWallet: async (keyAgent) =>
        new PersonalWallet(
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
        ),
      logger
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

    describe('resolveInput', () => {
      it('returns the txOut associated with the input for wallet-owned UTxO', async () => {
        const utxoSet = await firstValueFrom(wallet.utxo.available$);
        const resolveInputAddressResult = await wallet.util.resolveInput(utxoSet[0][0]);
        expect(typeof resolveInputAddressResult!.address).toBe('string');
        expect(typeof resolveInputAddressResult!.value).toBe('object');
      });

      it('returns null for non-wallet-owned utxo', async () => {
        expect(
          await wallet.util.resolveInput({
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
      inputs: new Set<Cardano.HydratedTxIn>([utxo[1][0]]),
      mint: new Map([
        [AssetId.PXL, 5n],
        [AssetId.TSLA, 20n]
      ]),
      outputs: new Set<Cardano.TxOut>(outputs),
      requiredExtraSignatures: [Crypto.Ed25519KeyHashHex('6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed5')],
      scriptIntegrityHash: Crypto.Hash32ByteBase16('3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d')
    } as InitializeTxProps;

    it('initializeTx', async () => {
      getPassphrase.mockClear();
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
      expect(getPassphrase).not.toBeCalled();
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
        const outgoingTx = toOutgoingTx(tx);

        const txSubmitting = firstValueFrom(wallet.transactions.outgoing.submitting$);
        const txPending = firstValueFrom(wallet.transactions.outgoing.pending$);
        const txInFlight = firstValueFrom(wallet.transactions.outgoing.inFlight$.pipe(skip(1)));

        const txId = await wallet.submitTx(tx);

        expect(txId).toBe(tx.id);
        expect(txSubmitProvider.submitTx).toBeCalledTimes(1);
        expect(txSubmitProvider.submitTx).toBeCalledWith({ signedTransaction: outgoingTx.cbor });
        expect(await txSubmitting).toEqual(outgoingTx);
        expect(await txPending).toEqual(outgoingTx);
        expect(await txInFlight).toEqual([outgoingTx]);
      });

      it('resolves on success when submitting tx as a serialized hex blob, encoded as CBOR', async () => {
        const cbor = TxCBOR(serializedForeignTx);

        const txSubmitting = firstValueFrom(wallet.transactions.outgoing.submitting$);
        const txPending = firstValueFrom(wallet.transactions.outgoing.pending$);
        const txInFlight = firstValueFrom(wallet.transactions.outgoing.inFlight$.pipe(skip(1)));

        await wallet.submitTx(cbor);

        expect(txSubmitProvider.submitTx).toBeCalledTimes(1);
        expect(txSubmitProvider.submitTx).toBeCalledWith({ signedTransaction: serializedForeignTx });

        const { body, id } = TxCBOR.deserialize(cbor);
        const outgoingTx = {
          body,
          cbor,
          id
        };
        expect(await txSubmitting).toEqual(outgoingTx);
        expect(await txPending).toEqual(outgoingTx);
        expect(await txInFlight).toEqual([outgoingTx]);
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
        const outgoingTx = toOutgoingTx(tx);

        // rejects when option is not provided
        await expect(wallet.submitTx(tx)).rejects.toThrow();

        // resolves when option is provided
        const txPending = firstValueFrom(wallet.transactions.outgoing.pending$);
        await expect(wallet.submitTx(tx, { mightBeAlreadySubmitted: true })).resolves.not.toThrow();
        expect(await txPending).toEqual(outgoingTx);
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

  describe('getTxBuilderDependencies', () => {
    let isSettledMock$: BehaviorSubject<boolean>;

    beforeEach(() => {
      isSettledMock$ = new BehaviorSubject<boolean>(false);
      wallet.syncStatus.isSettled$ = isSettledMock$;
    });

    it('txBuilder providers wait for the wallet to settle before resolving', async () => {
      const {
        txBuilderProviders: { changeAddress, genesisParameters, protocolParameters, rewardAccounts, tip, utxoAvailable }
      } = wallet.getTxBuilderDependencies();

      await expect(promiseTimeout(changeAddress())).rejects.toEqual('TIMEOUT');
      await expect(promiseTimeout(genesisParameters())).rejects.toEqual('TIMEOUT');
      await expect(promiseTimeout(protocolParameters())).rejects.toEqual('TIMEOUT');
      await expect(promiseTimeout(rewardAccounts())).rejects.toEqual('TIMEOUT');
      await expect(promiseTimeout(tip())).rejects.toEqual('TIMEOUT');
      await expect(promiseTimeout(utxoAvailable())).rejects.toEqual('TIMEOUT');

      isSettledMock$.next(true);

      await expect(promiseTimeout(changeAddress())).resolves.toEqual(address);
      await expect(promiseTimeout(genesisParameters())).resolves.toEqual(mocks.genesisParameters);
      await expect(promiseTimeout(protocolParameters())).resolves.toEqual(mocks.protocolParameters);
      await expect(promiseTimeout(rewardAccounts())).resolves.toEqual([
        expect.objectContaining({ address: mocks.rewardAccount })
      ]);
      await expect(promiseTimeout(tip())).resolves.toEqual(mocks.ledgerTip);
      await expect(promiseTimeout(utxoAvailable())).resolves.toEqual(mocks.utxo);
    });
  });

  it('signData calls cip30signData', async () => {
    const response = await wallet.signData({ payload: HexBlob('abc123'), signWith: address });
    expect(response).toHaveProperty('signature');
  });
});
