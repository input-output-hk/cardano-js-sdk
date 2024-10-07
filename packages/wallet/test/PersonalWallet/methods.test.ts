/* eslint-disable unicorn/consistent-destructuring, sonarjs/no-duplicate-string, @typescript-eslint/no-floating-promises, promise/no-nesting */
import * as Crypto from '@cardano-sdk/crypto';
import { AddressDiscovery, BaseWallet, TxInFlight, createPersonalWallet, createSharedWallet } from '../../src';
import { AddressType, Bip32Account, GroupedAddress, Witnesser, util } from '@cardano-sdk/key-management';
import { AssetId, createStubStakePoolProvider, mockProviders as mocks } from '@cardano-sdk/util-dev';
import { BehaviorSubject, Subscription, firstValueFrom, skip } from 'rxjs';
import {
  Cardano,
  ChainHistoryProvider,
  HandleProvider,
  ProviderError,
  ProviderFailure,
  RewardsProvider,
  Serialization,
  StakePoolProvider,
  TxSubmissionError,
  TxSubmissionErrorCode,
  ValueNotConservedData
} from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';
import { InitializeTxProps } from '@cardano-sdk/tx-construction';
import { babbageTx } from '../../../core/test/Serialization/testData';
import { buildDRepIDFromDRepKey, toOutgoingTx, waitForWalletStateSettle } from '../util';
import { getPassphrase, stakeKeyDerivationPath, testAsyncKeyAgent } from '../../../key-management/test/mocks';
import { dummyLogger as logger } from 'ts-log';

const { mockChainHistoryProvider, mockRewardsProvider, utxo } = mocks;

// We can't consistently re-serialize this specific tx due to witness.datums list format
const serializedForeignTx =
  '84a60081825820260aed6e7a24044b1254a87a509468a649f522a4e54e830ac10f27ea7b5ec61f01018383581d70b429738bd6cc58b5c7932d001aa2bd05cfea47020a556c8c753d44361a004c4b40582007845f8f3841996e3d8157954e2f5e2fb90465f27112fc5fe9056d916fae245b82583900b1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c68042f1946335c498d2e7556c5c647c4649c6a69d2b645cd1428a339ba1a0463676982583900b1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c68042f1946335c498d2e7556c5c647c4649c6a69d2b645cd1428a339ba821a00177a6ea2581c648823ffdad1610b4162f4dbc87bd47f6f9cf45d772ddef661eff198a5447742544319271044774554481a0031f9194577444f47451a0056898d4577555344431a000fc589467753484942411a000103c2581c659ab0b5658687c2e74cd10dba8244015b713bf503b90557769d77a7a14a57696e675269646572731a02269552021a0002e665031a02414F03081a02414EFA0b58204107eada931c72a600a6e3305bd22c7aeb9ada7c3f6823b155f4db85de36a69aa20081825820e686ade5bc97372f271fd2abc06cfd96c24b3d9170f9459de1d8e3dd8fd385575840653324a9dddad004f05a8ac99fa2d1811af5f00543591407fb5206cfe9ac91bb1412404323fa517e0e189684cd3592e7f74862e3f16afbc262519abec958180c0481d8799fd8799fd8799fd8799f581cb1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c68ffd8799fd8799fd8799f581c042f1946335c498d2e7556c5c647c4649c6a69d2b645cd1428a339baffffffff581cb1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c681b000001863784a12ed8799fd8799f4040ffd8799f581c648823ffdad1610b4162f4dbc87bd47f6f9cf45d772ddef661eff1984577444f4745ffffffd8799fd87980190c8efffff5f6';

const geniusYieldTx = Serialization.Transaction.fromCbor(
  Serialization.TxCBOR(
    '84aa0081825820c816519a759e300acc16d1e2812500392c85ae6d5af886dd154c9084a610a120010182a30058391044376a5f63342097a4f20401088c62da272639e60644a9ec1d70f4441d3554e12c8aed91818a0600a57bea9d50e509beda567387d124731501821a3bf7de20a1581c53827a77e4ed3d5c211706708c0aa9b9a3be19db901b1cbf7fa515b8a1582021e6a58421ea7762aeeedf1e217c9488592cd0b94cc655ab633506d9f95ed5f301028200582093d1a590f45777813b41443657b05572ed9fbecd885ce731955aab2d238b7da4a20058390099f8985db8b9076f61ecec59eca67e30224dc20afb40491aecc6aa971d3554e12c8aed91818a0600a57bea9d50e509beda567387d1247315011b0000000217c0f5a9021a000432ca07582037c0555635ab7e45ec39bd8feb873080d036c9a67c4cdd0c85e1c5291b0482f209a1581c53827a77e4ed3d5c211706708c0aa9b9a3be19db901b1cbf7fa515b8a1582021e6a58421ea7762aeeedf1e217c9488592cd0b94cc655ab633506d9f95ed5f3010b5820916cc9dc5a9e6e7710d5ab64f0b5624235dd43067e30835b1e3ac6ee995c9d280d81825820c816519a759e300acc16d1e2812500392c85ae6d5af886dd154c9084a610a1200010a20058390099f8985db8b9076f61ecec59eca67e30224dc20afb40491aecc6aa971d3554e12c8aed91818a0600a57bea9d50e509beda567387d1247315011a0045ff11111a00064c2f128282582016647d6365020555d905d6e0edcf08b90a567886f875b40b3d7cec1c704826240082582016647d6365020555d905d6e0edcf08b90a567886f875b40b3d7cec1c7048262401a20481d8799f581c99f8985db8b9076f61ecec59eca67e30224dc20afb40491aecc6aa97d8799fd8799f581c99f8985db8b9076f61ecec59eca67e30224dc20afb40491aecc6aa97ffd8799fd8799fd8799f581c1d3554e12c8aed91818a0600a57bea9d50e509beda567387d1247315ffffffffd8799f4040ff1a3b9aca001a3b9aca00d8799f581cc6e65ba7878b2f8ea0ad39287d3e2fd256dc5c4160fc19bdf4c4d87e457447454e53ffd8799f0101ff582021e6a58421ea7762aeeedf1e217c9488592cd0b94cc655ab633506d9f95ed5f3d87a80d87a80001a000f42401a000f4240d8799f1a000f42401a002dc6c000ff00ff0581840100d8799fd8799fd8799f5820c816519a759e300acc16d1e2812500392c85ae6d5af886dd154c9084a610a120ff01ffff821a000b16161a10bcda52f5d90103a100a11902a2a1636d736781781947656e6975735969656c643a204f7264657220706c61636564'
  )
);

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

describe('BaseWallet methods', () => {
  const address = mocks.utxo[0][0].address!;
  const groupedAddress: GroupedAddress = {
    accountIndex: 0,
    address,
    index: 0,
    networkId: Cardano.NetworkId.Testnet,
    rewardAccount: mocks.rewardAccount,
    stakeKeyDerivationPath,
    type: AddressType.External
  };

  const groupedAddress2: GroupedAddress = { ...groupedAddress, address: '1' as Cardano.PaymentAddress, index: 1 };
  const groupedAddress3: GroupedAddress = { ...groupedAddress, address: '2' as Cardano.PaymentAddress, index: 2 };
  let txSubmitProvider: mocks.TxSubmitProviderStub;
  let networkInfoProvider: mocks.NetworkInfoProviderStub;
  let assetProvider: mocks.MockAssetProvider;
  let stakePoolProvider: StakePoolProvider;
  let rewardsProvider: RewardsProvider;
  let chainHistoryProvider: ChainHistoryProvider;
  let handleProvider: HandleProvider;
  let wallet: BaseWallet;
  let utxoProvider: mocks.UtxoProviderStub;
  let witnesser: Witnesser;
  let bip32Account: Bip32Account;
  let addressDiscovery: jest.Mocked<AddressDiscovery>;

  beforeEach(async () => {
    txSubmitProvider = mocks.mockTxSubmitProvider();
    networkInfoProvider = mocks.mockNetworkInfoProvider();
    utxoProvider = mocks.mockUtxoProvider();
    assetProvider = mocks.mockAssetProvider();
    stakePoolProvider = createStubStakePoolProvider();
    rewardsProvider = mockRewardsProvider();
    chainHistoryProvider = mockChainHistoryProvider();
    handleProvider = mocks.mockHandleProvider();
    addressDiscovery = { discover: jest.fn().mockImplementation(async () => [groupedAddress]) };

    const asyncKeyAgent = await testAsyncKeyAgent();
    bip32Account = await Bip32Account.fromAsyncKeyAgent(asyncKeyAgent);
    bip32Account.deriveAddress = jest.fn().mockResolvedValue(groupedAddress);
    witnesser = util.createBip32Ed25519Witnesser(asyncKeyAgent);
    wallet = createPersonalWallet(
      { name: 'Test Wallet' },
      {
        addressDiscovery,
        assetProvider,
        bip32Account,
        chainHistoryProvider,
        handleProvider,
        logger,
        networkInfoProvider,
        rewardsProvider,
        stakePoolProvider,
        txSubmitProvider,
        utxoProvider,
        witnesser
      }
    );

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
      expect(inputSelection.change.length).toBeGreaterThan(0);
      expect(getPassphrase).not.toBeCalled();
    });

    describe('finalizeTx', () => {
      let witnessSpy: jest.SpyInstance;

      beforeEach(() => {
        witnessSpy = jest.spyOn(witnesser, 'witness');
      });

      afterEach(() => {
        witnessSpy.mockClear();
        witnessSpy.mockReset();
        witnessSpy.mockRestore();
      });

      it('resolves with TransactionWitnessSet', async () => {
        const txInternals = await wallet.initializeTx(props);
        const unhydratedTxBody = Serialization.TransactionBody.fromCore(txInternals.body).toCore();
        const tx = await wallet.finalizeTx({ tx: txInternals });

        expect(tx.body).toEqual(unhydratedTxBody);
        expect(tx.id).toBe(txInternals.hash);
        expect(tx.witness.signatures.size).toBe(2); // spending key and stake key for withdrawal
      });

      it('passes through sender to witnesser', async () => {
        const sender = { url: 'https://lace.io' };
        const txInternals = await wallet.initializeTx(props);

        // Reset witness calls from wallet.initializeTx
        witnessSpy.mockClear();

        await wallet.finalizeTx({ signingContext: { sender }, tx: txInternals });
        expect(witnessSpy).toHaveBeenCalledTimes(1);
        expect(witnessSpy).toBeCalledWith(expect.anything(), expect.objectContaining({ sender }), void 0);
      });

      it('uses the original CBOR to create the serializable transaction if given', async () => {
        const sender = { url: 'https://lace.io' };
        const txInternals = await wallet.initializeTx(props);

        // Reset witness calls from wallet.initializeTx
        witnessSpy.mockClear();

        await wallet.finalizeTx({
          auxiliaryData: geniusYieldTx.auxiliaryData()?.toCore(),
          bodyCbor: geniusYieldTx.body().toCbor(),
          signingContext: { sender },
          tx: txInternals,
          witness: geniusYieldTx.witnessSet()?.toCore()
        });

        expect(witnessSpy).toHaveBeenCalledTimes(1);
        const tx: Serialization.Transaction = witnessSpy.mock.calls[0][0];
        expect(tx.body().toCbor()).toEqual(geniusYieldTx.body().toCbor());
        // The transaction CBOR will not match due to reencoding witnessSet and auxiliaryData
        // expect(tx.toCbor()).toEqual(geniusYieldTx.toCbor());
      });

      it('uses the complete transaction CBOR, ignoring auxiliaryData, witness and isValid', async () => {
        const sender = { url: 'https://lace.io' };
        await wallet.finalizeTx({
          auxiliaryData: 'ignored auxiliary data' as Cardano.AuxiliaryData,
          signingContext: { sender },
          tx: geniusYieldTx.toCbor(),
          witness: 'ignored witness set' as Partial<Cardano.Witness>
        });

        expect(witnessSpy).toHaveBeenCalledTimes(1);
        const tx: Serialization.Transaction = witnessSpy.mock.calls[0][0];
        expect(tx.toCbor()).toEqual(geniusYieldTx.toCbor());
      });
    });

    describe('submitTx', () => {
      const valueNotConservedError = new ProviderError(
        ProviderFailure.BadRequest,
        new TxSubmissionError<ValueNotConservedData>(
          TxSubmissionErrorCode.ValueNotConserved,
          { consumed: { coins: 2n }, produced: { coins: 0n } },
          'Value not conserved'
        )
      );

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

      describe('is idempotent', () => {
        let tx: Cardano.Tx;
        let txInFlightEmissions: Array<TxInFlight[]>;
        let txInFlightSubscription: Subscription;

        beforeEach(async () => {
          tx = await wallet.finalizeTx({ tx: await wallet.initializeTx(props) });
          txInFlightEmissions = [];
          txInFlightSubscription = wallet.transactions.outgoing.inFlight$.subscribe((inFlight) =>
            txInFlightEmissions.push(inFlight)
          );
        });

        test('when re-submitting before initial submission resolves or rejects', async () => {
          await Promise.all([wallet.submitTx(tx), wallet.submitTx(tx)]);
          txInFlightSubscription.unsubscribe();

          expect(txSubmitProvider.submitTx).toBeCalledTimes(1);
          // [], [submitting], [submitted]
          expect(txInFlightEmissions).toHaveLength(3);
        });

        test('when re-submitting after initial submission resolves', async () => {
          await wallet.submitTx(tx);
          await wallet.submitTx(tx);
          txInFlightSubscription.unsubscribe();

          expect(txSubmitProvider.submitTx).toBeCalledTimes(1);
          // [], [submitting], [submitted]
          expect(txInFlightEmissions).toHaveLength(3);
        });
      });

      it('resolves on success when submitting tx as a serialized hex blob, encoded as CBOR', async () => {
        const cbor = Serialization.TxCBOR(serializedForeignTx);

        const txSubmitting = firstValueFrom(wallet.transactions.outgoing.submitting$);
        const txPending = firstValueFrom(wallet.transactions.outgoing.pending$);
        const txInFlight = firstValueFrom(wallet.transactions.outgoing.inFlight$.pipe(skip(1)));

        await wallet.submitTx(cbor);

        expect(txSubmitProvider.submitTx).toBeCalledTimes(1);
        expect(txSubmitProvider.submitTx).toBeCalledWith({ signedTransaction: serializedForeignTx });

        const { body, id } = Serialization.TxCBOR.deserialize(cbor);
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
        txSubmitProvider.submitTx
          .mockRejectedValueOnce(valueNotConservedError)
          .mockRejectedValueOnce(valueNotConservedError);
        const tx = await wallet.finalizeTx({ tx: await wallet.initializeTx(props) });
        const outgoingTx = toOutgoingTx(tx);

        // rejects when option is not provided
        await expect(wallet.submitTx(tx)).rejects.toThrow();

        // resolves when option is provided
        const txPending = firstValueFrom(wallet.transactions.outgoing.pending$);
        await expect(wallet.submitTx(tx, { mightBeAlreadySubmitted: true })).resolves.not.toThrow();
        expect(await txPending).toEqual(outgoingTx);
      });

      it('does not re-serialize the transaction to compute transaction id', async () => {
        // This transaction produces a different ID when round-tripping serialisation
        const cbor = Serialization.TxCBOR(
          '84a70081825820c8a0ccb785ef56a82c42faeef8b63f4c12ba0f487334de5f245974a2831b2c3601018382583900598a69f8d6d148890f0855f5e3e88f3e179e49f2deb114e654d8dfe068a5cec902cb3469645dc123b9719baac643e862e26ceda60d3b2f9b821a001226b8a1581cf0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9aa150000de1407473745f6d69675f3032313801a300581d709b85d225e2b8e71f123eecb10fae74a047021980768244202e2eecde01821a00397a9ca1581cf0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9aa150000643b07473745f6d69675f3032313801028201d818590268d8799faa446e616d654d247473745f6d69675f3032313845696d6167655838697066733a2f2f7a623272685a4150634d456938314e59753948327277525831313151526179484e43394770677075574479316e78433766496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d6265720046726172697479456261736963466c656e6774680c4a63686172616374657273576c6574746572732c6e756d626572732c7370656369616c516e756d657269635f6d6f64696669657273404776657273696f6e0101af4e7374616e646172645f696d6167655838697066733a2f2f7a623272685a4150634d456938314e59753948327277525831313151526179484e43394770677075574479316e78433766537374616e646172645f696d6167655f686173685820256e0dcb4e511b801e4e3198fc103e0a2368e8cfafb4759f0b40079a11bd21764a696d6167655f686173685820256e0dcb4e511b801e4e3198fc103e0a2368e8cfafb4759f0b40079a11bd217646706f7274616c404864657369676e65724047736f6369616c73404676656e646f72404764656661756c7400536c6173745f7570646174655f61646472657373583900598a69f8d6d148890f0855f5e3e88f3e179e49f2deb114e654d8dfe068a5cec902cb3469645dc123b9719baac643e862e26ceda60d3b2f9b4c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e14b7376675f76657273696f6e46312e31342e314c6167726565645f7465726d7340546d6967726174655f7369675f72657175697265640045747269616c00446e73667700ff82583900598a69f8d6d148890f0855f5e3e88f3e179e49f2deb114e654d8dfe068a5cec902cb3469645dc123b9719baac643e862e26ceda60d3b2f9b1b00000002537fa73a021a000393210758208f0c3ee1cd379bf1870ea0e875356289d3dfe05055791bf1e964a3453e27b88609a1581cf0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9aa350000643b07473745f6d69675f303231380150000de1407473745f6d69675f30323138014c7473745f6d69675f30323138200d81825820c8a0ccb785ef56a82c42faeef8b63f4c12ba0f487334de5f245974a2831b2c36000e81581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1a20082825820b62a7193927f47ef703ba99a06add1ee2d4d94853a16dcd68ad0f5d9baa1853058404ab953d5ba13075945c3f0231273402e6a23f42a8ce30de105d3f87b7b6385b04280d419936c90c4711974989c8c7fd4e487fa2d601fc208eae2d2dbeb5e2f0a825820ebbec8effec947663b6b8c59c4dddd4ffbdae8ebf7791d3929437013debd64b758406cf148be50c3510f1c1f18241dd5edeee6dc4b89e3de77e95e24baf37223bb6ee88d0efd80eb4010939fddd7f133a2aabec0aba2aac45b8d92372108609e9f0a01818200581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1f5a11902d1a178386630666634386262623762626539643539613430663163653930653965396430666635303032656334386632333262343963613066623961a178203030306465313430373437333734356636643639363735663330333233313338aa78046e616d65780d247473745f6d69675f303231387805696d6167657838697066733a2f2f7a623272685a4150634d456938314e59753948327277525831313151526179484e43394770677075574479316e7843376678096d6564696154797065780a696d6167652f6a70656778026f670078096f675f6e756d6265720078067261726974797805626173696378066c656e6774680c780a6368617261637465727378176c6574746572732c6e756d626572732c7370656369616c78116e756d657269635f6d6f646966696572737800780776657273696f6e01'
        );
        const id = await wallet.submitTx(cbor);
        expect(id).toEqual('fdfa77aad6d9c404168d1a9ca4171b5fd6ee96cde1964824c15b61ca26c15657');
      });

      it('attempts to resubmit the tx that is already in flight', async () => {
        const tx = await wallet.finalizeTx({ tx: await wallet.initializeTx(props) });

        await wallet.submitTx(tx);
        expect(await firstValueFrom(wallet.transactions.outgoing.inFlight$)).toHaveLength(1);

        // resubmit the same tx while it's 'in flight'
        txSubmitProvider.submitTx.mockRejectedValueOnce(valueNotConservedError);
        await wallet.submitTx(tx, { mightBeAlreadySubmitted: true });

        expect(await firstValueFrom(wallet.transactions.outgoing.inFlight$)).toHaveLength(1);
        expect(txSubmitProvider.submitTx).toBeCalledTimes(2);
      });

      it('resolves on success when submitting a tx when sending coins to a handle', async () => {
        const txBuilder = wallet.createTxBuilder();
        const txOutput = await txBuilder.buildOutput().handle('alice').coin(1_000_000n).build();

        const txOut = await txBuilder.addOutput(txOutput).build().sign();
        const submitTxArgsMock = {
          context: { handleResolutions: [mocks.resolvedHandle] },
          signedTransaction: txOut.cbor
        };
        const txPending = firstValueFrom(wallet.transactions.outgoing.pending$);
        await wallet.submitTx(txOut);

        const txPendingResult = await txPending;

        expect(txPendingResult.body.outputs[0].address).toEqual(mocks.resolvedHandle.cardanoAddress);
        expect(txSubmitProvider.submitTx).toHaveBeenCalledWith(submitTxArgsMock);
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
        txBuilderProviders: { genesisParameters, protocolParameters, rewardAccounts, tip, utxoAvailable }
      } = wallet.getTxBuilderDependencies();

      await expect(promiseTimeout(genesisParameters())).rejects.toEqual('TIMEOUT');
      await expect(promiseTimeout(protocolParameters())).rejects.toEqual('TIMEOUT');
      await expect(promiseTimeout(rewardAccounts())).rejects.toEqual('TIMEOUT');
      await expect(promiseTimeout(tip())).rejects.toEqual('TIMEOUT');
      await expect(promiseTimeout(utxoAvailable())).rejects.toEqual('TIMEOUT');

      isSettledMock$.next(true);

      await expect(promiseTimeout(genesisParameters())).resolves.toEqual(mocks.genesisParameters);
      await expect(promiseTimeout(protocolParameters())).resolves.toEqual(mocks.protocolParameters);
      await expect(promiseTimeout(rewardAccounts())).resolves.toEqual([
        expect.objectContaining({ address: mocks.rewardAccount })
      ]);
      await expect(promiseTimeout(tip())).resolves.toEqual(mocks.ledgerTip);
      await expect(promiseTimeout(utxoAvailable())).resolves.toEqual(mocks.utxo);
    });
  });

  describe('signData', () => {
    it('calls cip30signData', async () => {
      const response = await wallet.signData({ payload: HexBlob('abc123'), signWith: address });
      expect(response).toHaveProperty('signature');
    });

    it('signs with bech32 DRepID', async () => {
      const response = await wallet.signData({
        payload: HexBlob('abc123'),
        signWith: Cardano.DRepID('drep1vpzcgfrlgdh4fft0p0ju70czkxxkuknw0jjztl3x7aqgm9q3hqyaz')
      });
      expect(response).toHaveProperty('signature');
    });

    it('passes through context to witnesser', async () => {
      const sender = { url: 'https://lace.io' };
      const signDataSpy = jest.spyOn(witnesser, 'signData');
      const payload = HexBlob('abc123');
      await wallet.signData({ payload, sender, signWith: address });
      expect(signDataSpy).toBeCalledWith({
        knownAddresses: [groupedAddress],
        payload,
        sender,
        signWith: address
      });
    });

    test('rejects if bech32 DRepID is not a type 6 address', async () => {
      const dRepKey = await wallet.governance.getPubDRepKey();
      for (const type in Cardano.AddressType) {
        if (!Number.isNaN(Number(type)) && Number(type) !== Cardano.AddressType.EnterpriseKey) {
          const drepid = buildDRepIDFromDRepKey(dRepKey!, 0, type as unknown as Cardano.AddressType);
          await expect(wallet.signData({ payload: HexBlob('abc123'), signWith: drepid })).rejects.toThrow();
        }
      }
    });
  });

  it('getPubDRepKey', async () => {
    const response = await wallet.governance.getPubDRepKey();
    expect(typeof response).toBe('string');
  });

  it('will retry deriving pubDrepKey if one does not exist', async () => {
    wallet.shutdown();
    bip32Account.derivePublicKey = jest
      .fn()
      .mockRejectedValueOnce('error')
      .mockResolvedValue({ hex: () => 'string' });
    wallet = createPersonalWallet(
      { name: 'Test Wallet' },
      {
        assetProvider,
        bip32Account,
        chainHistoryProvider,
        handleProvider,
        logger,
        networkInfoProvider,
        rewardsProvider,
        stakePoolProvider,
        txSubmitProvider,
        utxoProvider,
        witnesser
      }
    );
    await waitForWalletStateSettle(wallet);

    const response = await wallet.governance.getPubDRepKey();
    expect(response).toBe('string');
    expect(bip32Account.derivePublicKey).toHaveBeenCalledTimes(3);
  });

  describe('discoverAddresses', () => {
    it('discovers new addreses and emits them from addresses$', async () => {
      const newAddresses: GroupedAddress[] = [
        groupedAddress,
        {
          ...groupedAddress,
          address: Cardano.PaymentAddress(
            'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
          ),
          index: groupedAddress.index + 1
        }
      ];
      addressDiscovery.discover.mockResolvedValueOnce(newAddresses);
      await expect(wallet.discoverAddresses()).resolves.toEqual(newAddresses);
      await expect(firstValueFrom(wallet.addresses$)).resolves.toEqual(newAddresses);
    });
  });

  describe('addSignatures', () => {
    it('adds the signatures and preserves all previous witnesses', async () => {
      const mockWitnesser = {
        signData: jest.fn(),
        witness: jest.fn().mockResolvedValue({
          cbor: Serialization.Transaction.fromCore(babbageTx).toCbor(),
          context: {
            handleResolutions: []
          },
          tx: {
            ...babbageTx,
            witness: {
              ...babbageTx.witness,
              signatures: new Map([
                ...babbageTx.witness.signatures.entries(),
                [
                  '0000000000000000000000000000000000000000000000000000000000000000',
                  '0000000000000000000000000000000000000000000000000000000000000000'
                ]
              ])
            }
          }
        })
      };

      wallet.shutdown();
      wallet = createPersonalWallet(
        { name: 'Test Wallet' },
        {
          addressDiscovery,
          assetProvider,
          bip32Account,
          chainHistoryProvider,
          handleProvider,
          logger,
          networkInfoProvider,
          rewardsProvider,
          stakePoolProvider,
          txSubmitProvider,
          utxoProvider,
          witnesser: mockWitnesser
        }
      );

      await waitForWalletStateSettle(wallet);

      const serializedTx = Serialization.Transaction.fromCore(babbageTx).toCbor();
      const tx = await wallet.addSignatures({ tx: serializedTx });
      const updatedTx = Serialization.Transaction.fromCbor(tx).toCore();

      expect(babbageTx.witness.bootstrap).toEqual(updatedTx.witness.bootstrap);
      expect(babbageTx.witness.datums).toEqual(updatedTx.witness.datums);
      expect(babbageTx.witness.redeemers).toEqual(updatedTx.witness.redeemers);
      expect(babbageTx.witness.scripts).toEqual(updatedTx.witness.scripts);

      for (const [key, value] of Object.entries(babbageTx.witness.signatures)) {
        expect(value).toEqual(updatedTx.witness.signatures.get(key as Crypto.Ed25519PublicKeyHex));
      }

      expect(updatedTx.witness.signatures.size).toEqual(babbageTx.witness.signatures.size + 1);
      expect(
        updatedTx.witness.signatures.get(
          '0000000000000000000000000000000000000000000000000000000000000000' as Crypto.Ed25519PublicKeyHex
        )
      ).toEqual('0000000000000000000000000000000000000000000000000000000000000000');

      // signed$ emits transaction and all its witnesses
      const signedTxs = await firstValueFrom(wallet.transactions.outgoing.signed$);

      expect(signedTxs[0].tx).toEqual(updatedTx);
    });
  });

  // eslint-disable-next-line sonarjs/cognitive-complexity
  describe('getNextUnusedAddress', () => {
    const script: Cardano.NativeScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireAllOf,
      scripts: [
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Crypto.Ed25519KeyHashHex('b275b08c999097247f7c17e77007c7010cd19f20cc086ad99d398538'),
          kind: Cardano.NativeScriptKind.RequireSignature
        }
      ]
    };

    // Computed from script above
    const scriptAddress = {
      accountIndex: 0,
      address:
        'addr_test1xrrujjsfy60k96pm8ymadcxhx82p54z3aswlwxa8r9pggy78e99qjf5lvt5rkwfh6msdwvw5rf29rmqa7ud6wx2zssfs0l4tsq' as Cardano.PaymentAddress,
      index: 0,
      networkId: Cardano.NetworkId.Testnet,
      rewardAccount: 'stake_test17rrujjsfy60k96pm8ymadcxhx82p54z3aswlwxa8r9pggycfg4jxy' as Cardano.RewardAccount,
      type: AddressType.External
    };

    beforeEach(() => {
      wallet.shutdown();

      bip32Account.deriveAddress = jest.fn((args) => {
        if (args.index === 0) {
          return Promise.resolve(groupedAddress);
        }

        if (args.index === 1) {
          return Promise.resolve(groupedAddress2);
        }

        return Promise.resolve(groupedAddress3);
      });
    });

    it('returns the latest known empty address if any', async () => {
      chainHistoryProvider = {
        blocksByHashes: jest.fn().mockResolvedValue([{ epoch: Cardano.EpochNo(3) }]),
        healthCheck: jest.fn().mockResolvedValue({ ok: true }),
        transactionsByAddresses: jest.fn().mockResolvedValue({
          pageResults: [],
          totalResultCount: 0
        }),
        transactionsByHashes: jest.fn().mockResolvedValue([])
      };

      wallet = createPersonalWallet(
        { name: 'Test Wallet' },
        {
          addressDiscovery,
          assetProvider,
          bip32Account,
          chainHistoryProvider,
          handleProvider,
          logger,
          networkInfoProvider,
          rewardsProvider,
          stakePoolProvider,
          txSubmitProvider,
          utxoProvider,
          witnesser
        }
      );

      await waitForWalletStateSettle(wallet);

      // Only one address being tracked.
      await expect(firstValueFrom(wallet.addresses$)).resolves.toEqual([groupedAddress]);
      await expect(wallet.getNextUnusedAddress()).resolves.toEqual([groupedAddress]);
    });

    it('returns a fresh empty address if all known addresses are used', async () => {
      chainHistoryProvider = {
        blocksByHashes: jest.fn().mockResolvedValue([{ epoch: Cardano.EpochNo(3) }]),
        healthCheck: jest.fn().mockResolvedValue({ ok: true }),
        transactionsByAddresses: jest.fn((args) => {
          if (args.addresses[0] === '1') {
            return Promise.resolve({
              pageResults: [],
              totalResultCount: 0
            });
          }

          return Promise.resolve({
            pageResults: mocks.queryTransactionsResult.pageResults,
            totalResultCount: mocks.queryTransactionsResult.totalResultCount
          });
        }),
        transactionsByHashes: jest.fn().mockResolvedValue([])
      };

      wallet = createPersonalWallet(
        { name: 'Test Wallet' },
        {
          addressDiscovery,
          assetProvider,
          bip32Account,
          chainHistoryProvider,
          handleProvider,
          logger,
          networkInfoProvider,
          rewardsProvider,
          stakePoolProvider,
          txSubmitProvider,
          utxoProvider,
          witnesser
        }
      );

      await waitForWalletStateSettle(wallet);

      // Only one address being tracked.
      await expect(firstValueFrom(wallet.addresses$)).resolves.toEqual([groupedAddress]);
      await expect(wallet.getNextUnusedAddress()).resolves.toEqual([groupedAddress2]);

      // New empty address is now being tracked.
      await expect(firstValueFrom(wallet.addresses$)).resolves.toEqual([groupedAddress, groupedAddress2]);

      // No new addresses are generated until the new empty address is used up.
      await expect(wallet.getNextUnusedAddress()).resolves.toEqual([groupedAddress2]);
    });

    it('returns a fresh empty address if all known addresses are used, and the new created address was also used', async () => {
      chainHistoryProvider = {
        blocksByHashes: jest.fn().mockResolvedValue([{ epoch: Cardano.EpochNo(3) }]),
        healthCheck: jest.fn().mockResolvedValue({ ok: true }),
        transactionsByAddresses: jest.fn((args) => {
          if (args.addresses[0] === '2') {
            return Promise.resolve({
              pageResults: [],
              totalResultCount: 0
            });
          }

          return Promise.resolve({
            pageResults: mocks.queryTransactionsResult.pageResults,
            totalResultCount: mocks.queryTransactionsResult.totalResultCount
          });
        }),
        transactionsByHashes: jest.fn().mockResolvedValue([])
      };

      wallet = createPersonalWallet(
        { name: 'Test Wallet' },
        {
          addressDiscovery,
          assetProvider,
          bip32Account,
          chainHistoryProvider,
          handleProvider,
          logger,
          networkInfoProvider,
          rewardsProvider,
          stakePoolProvider,
          txSubmitProvider,
          utxoProvider,
          witnesser
        }
      );

      await waitForWalletStateSettle(wallet);

      // Only one address being tracked.
      await expect(firstValueFrom(wallet.addresses$)).resolves.toEqual([groupedAddress]);
      await expect(wallet.getNextUnusedAddress()).resolves.toEqual([groupedAddress3]);

      // Discovered used address, plus new empty address is now being tracked.
      await expect(firstValueFrom(wallet.addresses$)).resolves.toEqual([
        groupedAddress,
        groupedAddress2,
        groupedAddress3
      ]);

      // No new addresses are generated until the new empty address is used up.
      await expect(wallet.getNextUnusedAddress()).resolves.toEqual([groupedAddress3]);
    });

    it('returns script address if unused', async () => {
      chainHistoryProvider = {
        blocksByHashes: jest.fn().mockResolvedValue([{ epoch: Cardano.EpochNo(3) }]),
        healthCheck: jest.fn().mockResolvedValue({ ok: true }),
        transactionsByAddresses: jest.fn().mockResolvedValue({
          pageResults: [],
          totalResultCount: 0
        }),
        transactionsByHashes: jest.fn().mockResolvedValue([])
      };

      wallet = createSharedWallet(
        { name: 'Test Wallet' },
        {
          assetProvider,
          chainHistoryProvider,
          handleProvider,
          logger,
          networkInfoProvider,
          paymentScript: script,
          rewardsProvider,
          stakePoolProvider,
          stakingScript: script,
          txSubmitProvider,
          utxoProvider,
          witnesser
        }
      );

      await waitForWalletStateSettle(wallet);

      await expect(wallet.getNextUnusedAddress()).resolves.toEqual([scriptAddress]);
      // Only one address being tracked.
      await expect(firstValueFrom(wallet.addresses$)).resolves.toEqual([scriptAddress]);
    });

    it('returns an empty array if script address is already used', async () => {
      chainHistoryProvider = {
        blocksByHashes: jest.fn().mockResolvedValue([{ epoch: Cardano.EpochNo(3) }]),
        healthCheck: jest.fn().mockResolvedValue({ ok: true }),
        transactionsByAddresses: jest.fn().mockResolvedValue({
          pageResults: [],
          totalResultCount: 1
        }),
        transactionsByHashes: jest.fn().mockResolvedValue([])
      };

      wallet = createSharedWallet(
        { name: 'Test Wallet' },
        {
          assetProvider,
          chainHistoryProvider,
          handleProvider,
          logger,
          networkInfoProvider,
          paymentScript: script,
          rewardsProvider,
          stakePoolProvider,
          stakingScript: script,
          txSubmitProvider,
          utxoProvider,
          witnesser
        }
      );

      await waitForWalletStateSettle(wallet);

      await expect(wallet.getNextUnusedAddress()).resolves.toEqual([]);
      // Only one address being tracked.
      await expect(firstValueFrom(wallet.addresses$)).resolves.toEqual([scriptAddress]);
    });
  });
});
