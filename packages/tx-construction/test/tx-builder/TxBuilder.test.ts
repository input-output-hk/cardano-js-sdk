/* eslint-disable func-style */
/* eslint-disable jsdoc/require-jsdoc */
import * as Crypto from '@cardano-sdk/crypto';
import {
  AddressType,
  AsyncKeyAgent,
  Bip32Account,
  GroupedAddress,
  InMemoryKeyAgent,
  KeyPurpose,
  SignTransactionOptions,
  TransactionSigner,
  util
} from '@cardano-sdk/key-management';
import { AssetId, mockProviders as mocks } from '@cardano-sdk/util-dev';
import { BigIntMath, HexBlob } from '@cardano-sdk/util';
import { Cardano, Handle, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import {
  GenericTxBuilder,
  HandleNotFoundError,
  InvalidConfigurationError,
  InvalidHereafterError,
  OutputBuilderValidator,
  OutputValidation,
  OutputValidationMinimumCoinError,
  OutputValidationMissingRequiredError,
  TxBuilderProviders,
  TxOutValidationError,
  TxOutputBuilder,
  TxOutputFailure
} from '../../src';
import { dummyLogger } from 'ts-log';
import { mockTxEvaluator } from './mocks';

function assertObjectRefsAreDifferent(obj1: unknown, obj2: unknown): void {
  expect(obj1).not.toBe(obj2);
}

const resolvedHandle = {
  cardanoAddress: Cardano.PaymentAddress('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg'),
  handle: 'alice',
  hasDatum: false,
  policyId: Cardano.PolicyId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7'),
  resolvedAt: {
    hash: Cardano.BlockId('7a48b034645f51743550bbaf81f8a14771e58856e031eb63844738ca8ad72298'),
    slot: Cardano.Slot(100)
  }
};
describe.each([
  ['TxBuilderGeneric', false],
  ['TxBuilderGeneric - bip32Account', true]
])('%s', (_, useBip32Account) => {
  let outputValidator: jest.Mocked<OutputBuilderValidator>;
  let txBuilder: GenericTxBuilder;
  let txBuilderWithoutHandleProvider: GenericTxBuilder;
  let txBuilderWithHandleErrors: GenericTxBuilder;
  let txBuilderWithNullHandles: GenericTxBuilder;
  let txBuilderProviders: jest.Mocked<TxBuilderProviders>;
  let output: Cardano.TxOut;
  let output2: Cardano.TxOut;
  let inputResolver: Cardano.InputResolver;
  let knownAddresses: GroupedAddress[];
  let asyncKeyAgent: AsyncKeyAgent;

  beforeEach(async () => {
    output = mocks.utxo[0][1];
    output2 = mocks.utxo[1][1];
    const rewardAccount = mocks.rewardAccount;
    inputResolver = {
      resolveInput: async (txIn) =>
        mocks.utxo.find(
          ([hydratedTxIn]) => txIn.txId === hydratedTxIn.txId && txIn.index === hydratedTxIn.index
        )?.[1] || null
    };
    const keyAgent = await InMemoryKeyAgent.fromBip39MnemonicWords(
      {
        chainId: Cardano.ChainIds.Preprod,
        getPassphrase: async () => Buffer.from('passphrase'),
        mnemonicWords: util.generateMnemonicWords(),
        purpose: KeyPurpose.STANDARD
      },
      { bip32Ed25519: new Crypto.SodiumBip32Ed25519(), logger: dummyLogger }
    );

    knownAddresses = [
      {
        ...(await keyAgent.deriveAddress({ index: 0, type: AddressType.External }, 0)),
        address: mocks.utxo[0][1].address,
        rewardAccount
      }
    ];

    txBuilderProviders = {
      addresses: {
        add: jest.fn().mockImplementation(async (...newAddresses) => knownAddresses.push(...newAddresses)),
        get: jest.fn().mockResolvedValue(knownAddresses)
      },
      genesisParameters: jest.fn().mockResolvedValue(mocks.genesisParameters),
      protocolParameters: jest.fn().mockResolvedValue(mocks.protocolParameters),
      rewardAccounts: jest.fn().mockResolvedValue([
        {
          address: rewardAccount,
          keyStatus: Cardano.StakeCredentialStatus.Unregistered,
          rewardBalance: mocks.rewardAccountBalance
        }
      ]),
      tip: jest.fn().mockResolvedValue(mocks.ledgerTip),
      utxoAvailable: jest.fn().mockResolvedValue(mocks.utxo)
    };
    outputValidator = {
      validateOutput: jest.fn().mockResolvedValue({ coinMissing: 0n } as OutputValidation)
    };

    asyncKeyAgent = util.createAsyncKeyAgent(keyAgent);
    const builderParams = {
      bip32Account: useBip32Account ? await Bip32Account.fromAsyncKeyAgent(asyncKeyAgent) : undefined,
      inputResolver,
      logger: dummyLogger,
      outputValidator,
      txBuilderProviders,
      txEvaluator: mockTxEvaluator,
      witnesser: util.createBip32Ed25519Witnesser(asyncKeyAgent)
    };

    txBuilder = new GenericTxBuilder({
      handleProvider: {
        getPolicyIds: async () => [resolvedHandle.policyId],
        healthCheck: jest.fn(),
        resolveHandles: async () => [resolvedHandle]
      },
      ...builderParams
    });
    txBuilderWithoutHandleProvider = new GenericTxBuilder(builderParams);
    txBuilderWithNullHandles = new GenericTxBuilder({
      handleProvider: {
        getPolicyIds: async () => [],
        healthCheck: jest.fn(),
        resolveHandles: async () => [null]
      },
      ...builderParams
    });
    txBuilderWithHandleErrors = new GenericTxBuilder({
      handleProvider: {
        getPolicyIds: async () => [],
        healthCheck: jest.fn(),
        resolveHandles: async () => {
          const error = new Error('not found');

          throw new ProviderError(
            ProviderFailure.NotFound,
            error,
            `Failed to resolve handles due to: ${error.message}`
          );
        }
      },
      ...builderParams
    });
  });

  describe('addOutput', () => {
    it('can add output without mutating partialTxBody', () => {
      const initialPartialTxBody = txBuilder.partialTxBody;
      txBuilder.addOutput(output);
      expect(txBuilder.partialTxBody.outputs).toEqual([output]);
      // check that original partialTxBody was not mutated
      assertObjectRefsAreDifferent(txBuilder.partialTxBody, initialPartialTxBody);
    });

    it('can add outputs one by one', () => {
      txBuilder.addOutput(output).addOutput(output2);
      expect(txBuilder.partialTxBody.outputs).toEqual([output, output2]);
    });
  });

  describe('removeOutput', () => {
    beforeEach(() => {
      txBuilder.addOutput(output).addOutput(output2);
    });

    it('can remove output without mutating partialTxBody', () => {
      const initialPartialTxBody = txBuilder.partialTxBody;
      txBuilder.removeOutput(output);
      expect(txBuilder.partialTxBody.outputs).toEqual([output2]);
      // check that original partialTxBody was not mutated
      assertObjectRefsAreDifferent(txBuilder.partialTxBody, initialPartialTxBody);
    });

    it('can remove outputs one by one', () => {
      txBuilder.removeOutput(output).removeOutput(output2);
      expect(txBuilder.partialTxBody.outputs?.length).toBe(0);
    });

    it('can ignore calls to remove outputs already removed', () => {
      // remove same output twice
      txBuilder.removeOutput(output2).removeOutput(output2);
      expect(txBuilder.partialTxBody.outputs).toEqual([output]);
    });
  });

  describe('metadata', () => {
    let metadata: Cardano.TxMetadata;

    it('can add metadata without mutating auxiliaryData', () => {
      metadata = new Map([[123n, '1234']]);
      const initialAuxiliaryData = txBuilder.partialAuxiliaryData;
      txBuilder.metadata(metadata);
      assertObjectRefsAreDifferent(txBuilder.partialAuxiliaryData, initialAuxiliaryData);
      expect(txBuilder.partialAuxiliaryData?.blob).toEqual(metadata);
    });

    it('can unset metadata by using empty map', () => {
      metadata = new Map();
      txBuilder.metadata(metadata);
      expect(txBuilder.partialAuxiliaryData?.blob?.entries.length).toBe(0);
    });

    it('can add metadata, sign and read it back', async () => {
      const tx = txBuilder.addOutput(mocks.utxo[0][1]).metadata(metadata).build();

      // UnsignedTx contains metadata
      expect((await tx.inspect()).auxiliaryData?.blob).toEqual(metadata);

      const { tx: signedTx } = await tx.sign();
      expect(signedTx.auxiliaryData?.blob).toEqual(metadata);
    });
  });

  describe('extraSigners', () => {
    let signers: TransactionSigner[];
    const pubKey = Crypto.Ed25519PublicKeyHex('6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39');
    const signature = Crypto.Ed25519SignatureHex(
      // eslint-disable-next-line max-len
      '709f937c4ce152c81f8406c03279ff5a8556a12a8657e40a578eaaa6223d2e6a2fece39733429e3ec73a6c798561b5c2d47d82224d656b1d964cfe8b5fdffe09'
    );

    beforeEach(() => {
      signers = [{ sign: () => Promise.resolve({ pubKey, signature }) }];
    });

    it('can setExtraSigners without mutating extraSigners', () => {
      const initialSigners = txBuilder.extraSigners;
      txBuilder.extraSigners(signers);
      assertObjectRefsAreDifferent(txBuilder.partialExtraSigners, initialSigners);
      expect(txBuilder.partialExtraSigners).toEqual(signers);
    });

    it('can unset extraSigners by using empty array', () => {
      txBuilder.extraSigners(signers);
      txBuilder.extraSigners([]);
      expect(txBuilder.partialExtraSigners?.length).toBe(0);
    });

    it('can set extraSigners for signing', async () => {
      const { tx: signedTx } = await txBuilder.addOutput(mocks.utxo[0][1]).extraSigners(signers).build().sign();
      expect(signedTx.witness.signatures.get(pubKey)).toEqual(signature);
    });
  });

  describe('signingOptions', () => {
    let signingOptions: SignTransactionOptions;

    beforeEach(() => {
      signingOptions = { additionalKeyPaths: [{ index: 1, role: 1 }] };
    });

    it('can setSigningOptions without mutating signingOptions', () => {
      const initialSigningOptions = txBuilder.partialSigningOptions;
      txBuilder.signingOptions(signingOptions);
      assertObjectRefsAreDifferent(txBuilder.partialSigningOptions, initialSigningOptions);
      expect(txBuilder.partialSigningOptions).toEqual(signingOptions);
    });

    it('can unset signingOptions by using empty object', () => {
      txBuilder.signingOptions(signingOptions);
      txBuilder.signingOptions({});
      expect(txBuilder.partialSigningOptions?.additionalKeyPaths).toBeFalsy();
    });
  });

  describe('inspect', () => {
    it('resolves with transaction properties that were previously set', async () => {
      const partialTx = await txBuilder.addOutput(output).metadata(new Map()).inspect();
      expect(partialTx.body.outputs).toHaveLength(1);
      expect(partialTx.auxiliaryData).not.toBeUndefined();
    });
  });

  describe('buildOutput', () => {
    let outputBuilder: TxOutputBuilder;
    let assetId: Cardano.AssetId;
    let assetQuantity: bigint;
    let assets: Cardano.TokenMap;
    let address: Cardano.PaymentAddress;
    let datumHash: Crypto.Hash32ByteBase16;
    let output1Coin: bigint;
    let output2Base: Cardano.TxOut;
    let handle: Handle;

    beforeEach(() => {
      assetId = Cardano.AssetId('1ec85dcee27f2d90ec1f9a1e4ce74a667dc9be8b184463223f9c960150584c');
      assetQuantity = 100n;
      assets = new Map([[assetId, assetQuantity]]);
      address = Cardano.PaymentAddress('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg');
      datumHash = Crypto.Hash32ByteBase16('3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d');
      output1Coin = 10_000_000n;
      handle = 'alice';
      output2Base = mocks.utxo[0][1];

      outputBuilder = txBuilder.buildOutput().address(address).coin(output1Coin) as TxOutputBuilder;
    });

    it('can create OutputBuilder without initial output', () => {
      expect(outputBuilder.toTxOut()).toBeTruthy();
    });

    it('can create OutputBuilder starting from an existing output', async () => {
      const outputBuilderFromExisting = txBuilder.buildOutput(output);
      expect(await outputBuilderFromExisting.build()).toEqual(output);
    });

    it('can set output value, overwriting preexisting value', () => {
      const outValue = { assets, coins: output1Coin };
      outputBuilder.value(outValue);
      expect(outputBuilder.toTxOut().value).toEqual(outValue);

      // Setting outValueOther will remove previously configured assets
      const outValueOther = { coins: output1Coin + 100n };
      outputBuilder.value(outValueOther);
      expect(outputBuilder.toTxOut().value).toEqual(outValueOther);
    });

    describe('inspect', () => {
      it('resolves with transaction properties that were previously set', async () => {
        const partialTxOut = await txBuilder.buildOutput().asset(assetId, 123n).inspect();
        expect(partialTxOut.value?.assets).not.toBeUndefined();
        expect(partialTxOut.value?.coins).toBeUndefined();
      });
    });

    it('can set coin value', () => {
      expect(outputBuilder.toTxOut().value).toEqual({ coins: output1Coin });
    });

    it('can set assets', () => {
      outputBuilder.assets(assets);
      expect(outputBuilder.toTxOut().value).toEqual(expect.objectContaining({ assets }));
    });

    it('can add assets one by one', () => {
      outputBuilder.asset(AssetId.PXL, 5n).asset(AssetId.TSLA, 10n);
      const txOut = outputBuilder.toTxOut();
      expect(txOut.value?.assets?.size).toBe(2);
      expect(txOut.value?.assets?.get(AssetId.PXL)).toBe(5n);
      expect(txOut.value?.assets?.get(AssetId.TSLA)).toBe(10n);
    });

    it('can update asset quantity by assetId', () => {
      outputBuilder.asset(AssetId.PXL, 5n).asset(AssetId.TSLA, 10n);
      outputBuilder.asset(AssetId.PXL, 11n);
      expect(outputBuilder.toTxOut().value?.assets?.get(AssetId.PXL)).toBe(11n);
    });

    it('can remove asset by using quantity 0', () => {
      outputBuilder.assets(assets);
      expect(outputBuilder.toTxOut().value?.assets?.size).toBe(1);
      outputBuilder.asset(assetId, 0n);
      expect(outputBuilder.toTxOut().value?.assets?.size).toBe(0);
    });

    it('can set address', () => {
      expect(outputBuilder.toTxOut().address).toEqual(address);
    });

    it('can set datum hash', () => {
      outputBuilder.datum(datumHash);
      expect(outputBuilder.toTxOut().datumHash).toEqual(datumHash);
    });

    it('can set inline datum', () => {
      outputBuilder.datum(1n);
      expect(outputBuilder.toTxOut().datum).toEqual(1n);
    });

    it('can set handle', () => {
      outputBuilder.handle(handle);
      expect(outputBuilder.toTxOut().handle).toEqual(handle);
    });

    it('can set script reference', () => {
      const alwaysSucceedsScript: Cardano.PlutusScript = {
        __type: Cardano.ScriptType.Plutus,
        bytes: HexBlob(
          '59079201000033232323232323232323232323232332232323232323232222232325335333006300800530070043333573466E1CD55CEA80124000466442466002006004646464646464646464646464646666AE68CDC39AAB9D500C480008CCCCCCCCCCCC88888888888848CCCCCCCCCCCC00403403002C02802402001C01801401000C008CD4060064D5D0A80619A80C00C9ABA1500B33501801A35742A014666AA038EB9406CD5D0A804999AA80E3AE501B35742A01066A0300466AE85401CCCD54070091D69ABA150063232323333573466E1CD55CEA801240004664424660020060046464646666AE68CDC39AAB9D5002480008CC8848CC00400C008CD40B9D69ABA15002302F357426AE8940088C98C80C8CD5CE01981901809AAB9E5001137540026AE854008C8C8C8CCCD5CD19B8735573AA004900011991091980080180119A8173AD35742A004605E6AE84D5D1280111931901919AB9C033032030135573CA00226EA8004D5D09ABA2500223263202E33573805E05C05826AAE7940044DD50009ABA1500533501875C6AE854010CCD540700808004D5D0A801999AA80E3AE200135742A00460446AE84D5D1280111931901519AB9C02B02A028135744A00226AE8940044D5D1280089ABA25001135744A00226AE8940044D5D1280089ABA25001135744A00226AE8940044D55CF280089BAA00135742A00460246AE84D5D1280111931900E19AB9C01D01C01A101B13263201B3357389201035054350001B135573CA00226EA80054049404448C88C008DD6000990009AA80A911999AAB9F0012500A233500930043574200460066AE880080548C8C8CCCD5CD19B8735573AA004900011991091980080180118061ABA150023005357426AE8940088C98C8054CD5CE00B00A80989AAB9E5001137540024646464646666AE68CDC39AAB9D5004480008CCCC888848CCCC00401401000C008C8C8C8CCCD5CD19B8735573AA0049000119910919800801801180A9ABA1500233500F014357426AE8940088C98C8068CD5CE00D80D00C09AAB9E5001137540026AE854010CCD54021D728039ABA150033232323333573466E1D4005200423212223002004357426AAE79400C8CCCD5CD19B875002480088C84888C004010DD71ABA135573CA00846666AE68CDC3A801A400042444006464C6403866AE700740700680640604D55CEA80089BAA00135742A00466A016EB8D5D09ABA2500223263201633573802E02C02826AE8940044D5D1280089AAB9E500113754002266AA002EB9D6889119118011BAB00132001355012223233335573E0044A010466A00E66442466002006004600C6AAE754008C014D55CF280118021ABA200301313574200222440042442446600200800624464646666AE68CDC3A800A40004642446004006600A6AE84D55CF280191999AB9A3370EA0049001109100091931900899AB9C01201100F00E135573AA00226EA80048C8C8CCCD5CD19B875001480188C848888C010014C01CD5D09AAB9E500323333573466E1D400920042321222230020053009357426AAE7940108CCCD5CD19B875003480088C848888C004014C01CD5D09AAB9E500523333573466E1D40112000232122223003005375C6AE84D55CF280311931900899AB9C01201100F00E00D00C135573AA00226EA80048C8C8CCCD5CD19B8735573AA004900011991091980080180118029ABA15002375A6AE84D5D1280111931900699AB9C00E00D00B135573CA00226EA80048C8CCCD5CD19B8735573AA002900011BAE357426AAE7940088C98C802CCD5CE00600580489BAA001232323232323333573466E1D4005200C21222222200323333573466E1D4009200A21222222200423333573466E1D400D2008233221222222233001009008375C6AE854014DD69ABA135744A00A46666AE68CDC3A8022400C4664424444444660040120106EB8D5D0A8039BAE357426AE89401C8CCCD5CD19B875005480108CC8848888888CC018024020C030D5D0A8049BAE357426AE8940248CCCD5CD19B875006480088C848888888C01C020C034D5D09AAB9E500B23333573466E1D401D2000232122222223005008300E357426AAE7940308C98C8050CD5CE00A80A00900880800780700680609AAB9D5004135573CA00626AAE7940084D55CF280089BAA0012323232323333573466E1D400520022333222122333001005004003375A6AE854010DD69ABA15003375A6AE84D5D1280191999AB9A3370EA0049000119091180100198041ABA135573CA00C464C6401A66AE7003803402C0284D55CEA80189ABA25001135573CA00226EA80048C8C8CCCD5CD19B875001480088C8488C00400CDD71ABA135573CA00646666AE68CDC3A8012400046424460040066EB8D5D09AAB9E500423263200A33573801601401000E26AAE7540044DD500089119191999AB9A3370EA00290021091100091999AB9A3370EA00490011190911180180218031ABA135573CA00846666AE68CDC3A801A400042444004464C6401666AE7003002C02402001C4D55CEA80089BAA0012323333573466E1D40052002212200223333573466E1D40092000212200123263200733573801000E00A00826AAE74DD5000891999AB9A3370E6AAE74DD5000A40004008464C6400866AE700140100092612001490103505431001123230010012233003300200200122212200201'
        ),
        version: Cardano.PlutusLanguageVersion.V2
      };

      outputBuilder.scriptReference(alwaysSucceedsScript);
      expect(outputBuilder.toTxOut().scriptReference).toEqual(alwaysSucceedsScript);
    });

    it('throws an error if attempting to set handle without a handleProvider', async () => {
      try {
        await txBuilderWithoutHandleProvider.buildOutput().handle(address).build();
      } catch (error) {
        expect(error instanceof InvalidConfigurationError).toBeTruthy();
      }

      expect.assertions(1);
    });

    it('can build a valid output', async () => {
      const builtOutput = await txBuilder
        .buildOutput()
        .address(address)
        .coin(output1Coin)
        .asset(assetId, assetQuantity)
        .build();

      expect(builtOutput).toEqual<Cardano.TxOut>({ address, value: { assets, coins: output1Coin } });

      const builtOutputFromOther = await txBuilder.buildOutput(output2Base).assets(assets).datum(datumHash).build();
      expect(builtOutputFromOther).toEqual<Cardano.TxOut>({
        datumHash,
        ...output2Base,
        value: { ...output2Base.value, assets }
      });
    });

    describe('can build and validate', () => {
      it('missing coin field', async () => {
        try {
          await txBuilder.buildOutput().address(address).build();
        } catch (error) {
          const err = error as TxOutValidationError;
          expect(
            err instanceof OutputValidationMissingRequiredError && err.message === TxOutputFailure.MissingRequiredFields
          ).toBeTruthy();
        }

        expect.assertions(1);
      });

      it('missing address field', async () => {
        try {
          await txBuilder.buildOutput().coin(output1Coin).build();
        } catch (error) {
          const err = error as TxOutValidationError;
          expect(
            err instanceof OutputValidationMissingRequiredError && err.message === TxOutputFailure.MissingRequiredFields
          ).toBeTruthy();
        }
        expect.assertions(1);
      });

      it('legit output with valid with address and coin', async () => {
        await expect(txBuilder.buildOutput().address(address).coin(output1Coin).build()).resolves.toBeTruthy();
      });

      it('resolves handle to address', async () => {
        const txOut = await txBuilder.buildOutput().handle('alice').coin(output1Coin).build();

        expect(txOut.handle).toBe(resolvedHandle.handle);
        expect(txOut.address).toBe(resolvedHandle.cardanoAddress);
      });

      it('rejects with an error when a handle provider fails to resolve', async () => {
        await expect(
          txBuilderWithNullHandles.buildOutput().handle('alice').coin(output1Coin).build()
        ).rejects.toThrowError(HandleNotFoundError);
      });

      it('rejects with an error when handle provider throws an error', async () => {
        await expect(
          txBuilderWithHandleErrors.buildOutput().handle('alice').coin(output1Coin).build()
        ).rejects.toThrowError(ProviderError);
      });
    });

    describe('can validate required output fields', () => {
      it('missing coin field', async () => {
        await expect(txBuilder.buildOutput().address(address).build()).rejects.toThrowError(
          OutputValidationMissingRequiredError
        );
      });

      it('missing address field', async () => {
        await expect(txBuilder.buildOutput().coin(output1Coin).build()).rejects.toThrowError(
          OutputValidationMissingRequiredError
        );
      });

      it('legit output with valid with address and coin', async () => {
        await expect(txBuilder.buildOutput().address(address).coin(output1Coin).build()).resolves.not.toThrow();
      });
    });
  });

  describe('error handling', () => {
    it('validates outputs before building', async () => {
      const coinMissingValidation: OutputValidation = {
        coinMissing: 1n,
        minimumCoin: 2n,
        negativeAssetQty: false,
        tokenBundleSizeExceedsLimit: false
      };

      outputValidator.validateOutput.mockResolvedValueOnce(coinMissingValidation);

      await expect(txBuilder.addOutput(output).addOutput(output2).build().inspect()).rejects.toThrowError(
        OutputValidationMinimumCoinError
      );
    });
  });

  describe('customize callback', () => {
    let dRepPublicKey: Crypto.Ed25519PublicKeyHex;
    let dRepKeyHash: Crypto.Ed25519KeyHashHex;

    beforeEach(async () => {
      dRepPublicKey = Crypto.Ed25519PublicKeyHex('deeb8f82f2af5836ebbc1b450b6dbf0b03c93afe5696f10d49e8a8304ebfac01');
      dRepKeyHash = (await Crypto.Ed25519PublicKey.fromHex(dRepPublicKey).hash()).hex();
    });

    it('can add a custom fields which are accounted for by input selector', async () => {
      const txProps = await txBuilder
        .addOutput(mocks.utxo[0][1])
        .customize(({ txBody }) => {
          const outputs = [...txBody.outputs, { ...mocks.utxo[1][1], value: { coins: 100n } }];
          return {
            ...txBody,
            outputs,
            withdrawals: [...(txBody.withdrawals || []), { quantity: 13n, stakeAddress: mocks.rewardAccount }]
          };
        })
        .build()
        .inspect();

      // Check if the custom fields were included the built transaction
      expect(txProps.body.outputs.filter(({ value: { coins } }) => coins === 100n).length).toBe(1);
      expect(txProps.body.withdrawals?.filter(({ quantity }) => quantity === 13n).length).toBe(1);

      // Check if the transaction is balanced
      const inputTotal =
        BigIntMath.sum([...txProps.inputSelection.inputs].map((i) => i[1].value.coins)) +
        BigIntMath.sum(txProps.body.withdrawals?.map((x) => x.quantity) || []);
      const outputTotal = BigIntMath.sum(txProps.body.outputs.map((o) => o.value.coins));
      expect(inputTotal).toEqual(outputTotal + txProps.body.fee);
    });

    it('can add a custom certificate', async () => {
      const poolId = Cardano.PoolId('pool1y6chk7x7fup4ms9leesdr57r4qy9cwxuee0msan72x976a6u0nc');
      const stakeVoteRegDelegCert: Cardano.StakeVoteRegistrationDelegationCertificate = {
        __typename: Cardano.CertificateType.StakeVoteRegistrationDelegation,
        dRep: {
          hash: Crypto.Hash28ByteBase16(dRepKeyHash),
          type: Cardano.CredentialType.KeyHash
        },
        deposit: 2n,
        poolId,
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(mocks.stakeKeyHash),
          type: Cardano.CredentialType.KeyHash
        }
      };
      const txProps = await txBuilder
        .customize(({ txBody }) => {
          const certificates = [...(txBody.certificates || []), stakeVoteRegDelegCert];
          return { ...txBody, certificates };
        })
        .build()
        .inspect();

      expect(txProps.body.certificates?.length).toEqual(1);
      expect(txProps.body.certificates![0]).toEqual(stakeVoteRegDelegCert);
    });

    it('certificates are accounted for when calculating implicit coin', async () => {
      const stakeRegDelegCert: Cardano.StakeRegistrationDelegationCertificate = {
        __typename: Cardano.CertificateType.StakeRegistrationDelegation,
        deposit: 5n,
        poolId: Cardano.PoolId('pool1y6chk7x7fup4ms9leesdr57r4qy9cwxuee0msan72x976a6u0nc'),
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(mocks.stakeKeyHash),
          type: Cardano.CredentialType.KeyHash
        }
      };

      const txProps = await txBuilder
        .customize(({ txBody }) => {
          const certificates = [...(txBody.certificates || []), stakeRegDelegCert];
          return { ...txBody, certificates };
        })
        .build()
        .inspect();

      expect(txProps.body.certificates?.length).toEqual(1);
      expect(txProps.body.certificates![0]).toEqual(stakeRegDelegCert);

      // Check if the transaction is balanced
      const inputTotal =
        BigIntMath.sum([...txProps.inputSelection.inputs].map((i) => i[1].value.coins)) +
        BigIntMath.sum(txProps.body.withdrawals?.map((x) => x.quantity) || []);
      const outputTotal = BigIntMath.sum(txProps.body.outputs.map((o) => o.value.coins));
      expect(inputTotal).toEqual(outputTotal + txProps.body.fee + stakeRegDelegCert.deposit);
    });

    it('can add a custom voting procedure', async () => {
      const votingProcedure: Cardano.VotingProcedures[0] = {
        voter: {
          __typename: Cardano.VoterType.dRepKeyHash,
          credential: { hash: Crypto.Hash28ByteBase16(dRepKeyHash), type: Cardano.CredentialType.KeyHash }
        },
        votes: [
          {
            actionId: {
              actionIndex: 3,
              id: Cardano.TransactionId('1000000000000000000000000000000000000000000000000000000000000000')
            },
            votingProcedure: {
              anchor: {
                dataHash: Crypto.Hash32ByteBase16('0000000000000000000000000000000000000000000000000000000000000000'),
                url: 'https://www.someurl.io'
              },
              vote: 0
            }
          }
        ]
      };

      const txProps = await txBuilder
        .customize(({ txBody }) => {
          const votingProcedures: Cardano.TxBody['votingProcedures'] = [
            ...(txBody.votingProcedures || []),
            votingProcedure
          ];
          return { ...txBody, votingProcedures };
        })
        .build()
        .inspect();

      expect(txProps.body.votingProcedures?.length).toBe(1);
      expect(txProps.body.votingProcedures![0]).toEqual(votingProcedure);
    });
  });

  it('can be used to build and sign a tx', async () => {
    const tx = txBuilder.addOutput(mocks.utxo[0][1]).build();
    const txProps = await tx.inspect();
    expect(txProps.inputSelection).toBeTruthy();
    const { tx: signedTx } = await tx.sign();
    expect(signedTx.id).toEqual(txProps.hash);
  });

  it('returns a context with used handles along with the signed transaction', async () => {
    const tx = txBuilder
      .addOutput({
        ...mocks.utxo[0][1],
        handleResolution: resolvedHandle
      })
      .build();
    const { handleResolutions } = await tx.inspect();
    expect(handleResolutions).toEqual([resolvedHandle]);
    const { context } = await tx.sign();
    expect(context.handleResolutions).toEqual([resolvedHandle]);
  });

  it('can build transactions that are not modified by subsequent builder changes', async () => {
    const builtTxSnapshot1 = txBuilder.addOutput(mocks.utxo[0][1]).build();
    const propsAfterBuild1 = await builtTxSnapshot1.inspect();
    const numOutputsAfterBuild1 = propsAfterBuild1.body.outputs.length;

    await txBuilder.addOutput(mocks.utxo[1][1]).build().inspect();
    const propsAfterBuild2 = await builtTxSnapshot1.inspect();

    // Number of outputs is not affected by second build() call
    expect(propsAfterBuild2.body.outputs).toHaveLength(numOutputsAfterBuild1);
  });

  describe('validityInterval', () => {
    it('sets validity interval ', async () => {
      const validityInterval: Cardano.ValidityInterval = { invalidHereafter: Cardano.Slot(mocks.ledgerTip.slot + 1) };
      txBuilder.setValidityInterval(validityInterval);
      const tx = await txBuilder.build().inspect();
      expect(tx.body.validityInterval).toEqual(validityInterval);
    });

    it('sets validity interval without mutating partialTxBody', () => {
      const initialPartialTxBody = txBuilder.partialTxBody;
      const validityInterval: Cardano.ValidityInterval = { invalidHereafter: Cardano.Slot(mocks.ledgerTip.slot + 1) };
      txBuilder.setValidityInterval(validityInterval);
      expect(txBuilder.partialTxBody.validityInterval).toEqual(validityInterval);
      assertObjectRefsAreDifferent(txBuilder.partialTxBody, initialPartialTxBody);
    });

    it('throws InvalidHereafterError if invalidHereafter is in the past', async () => {
      const pastValidityInterval: Cardano.ValidityInterval = {
        invalidHereafter: Cardano.Slot(mocks.ledgerTip.slot - 1)
      };
      txBuilder.setValidityInterval(pastValidityInterval);
      await expect(txBuilder.build().inspect()).rejects.toThrowError(InvalidHereafterError);
    });

    it('throws InvalidHereafterError if invalidHereafter is current tip slot', async () => {
      const pastValidityInterval: Cardano.ValidityInterval = {
        invalidHereafter: Cardano.Slot(mocks.ledgerTip.slot)
      };
      txBuilder.setValidityInterval(pastValidityInterval);
      await expect(txBuilder.build().inspect()).rejects.toThrowError(InvalidHereafterError);
    });

    it('overrides validity interval', async () => {
      const validityInterval1: Cardano.ValidityInterval = {
        invalidHereafter: Cardano.Slot(mocks.ledgerTip.slot + 100)
      };
      const validityInterval2: Cardano.ValidityInterval = {
        invalidHereafter: Cardano.Slot(mocks.ledgerTip.slot + 150)
      };
      txBuilder.setValidityInterval(validityInterval1).setValidityInterval(validityInterval2);
      expect(txBuilder.partialTxBody.validityInterval).toEqual(validityInterval2);
    });
  });
});
