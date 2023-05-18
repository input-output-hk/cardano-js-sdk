/* eslint-disable func-style */
/* eslint-disable jsdoc/require-jsdoc */
import * as Crypto from '@cardano-sdk/crypto';
import { AssetId, somePartialStakePools } from '@cardano-sdk/util-dev';
import { Cardano } from '@cardano-sdk/core';

import { of } from 'rxjs';

import * as mocks from '../../../core/test/mocks';
import {
  GenericTxBuilder,
  OutputValidation,
  OutputValidationMinimumCoinError,
  OutputValidationMissingRequiredError,
  OutputValidationTokenBundleSizeError,
  OutputValidator,
  RewardAccountMissingError,
  TxBodyValidationError,
  TxOutValidationError,
  TxOutputBuilder,
  TxOutputFailure
} from '../..';
import { KeyRole, SignTransactionOptions, TransactionSigner } from '@cardano-sdk/key-management';
import { SingleAddressWallet } from '../../../wallet/src';
import { createWallet } from '../../../wallet/test/integration/util';

function assertObjectRefsAreDifferent(obj1: unknown, obj2: unknown): void {
  expect(obj1).not.toBe(obj2);
}

describe('GenericTxBuilder', () => {
  let observableWallet: SingleAddressWallet;
  let txBuilder: GenericTxBuilder;
  let output: Cardano.TxOut;
  let output2: Cardano.TxOut;

  beforeEach(async () => {
    ({ wallet: observableWallet } = await createWallet());
    output = mocks.utxo[0][1];
    output2 = mocks.utxo[1][1];
    txBuilder = observableWallet.createTxBuilder();
  });

  afterEach(() => observableWallet.shutdown());

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
      const tx = await txBuilder.addOutput(mocks.utxo[0][1]).metadata(metadata).build();

      // ValidTxBody contains metadata
      expect(tx.auxiliaryData?.blob).toEqual(metadata);

      const signedTx = await tx.sign();
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
      signers = [{ sign: (_) => Promise.resolve({ pubKey, signature }) }];
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

    it('can set extraSigners, sign and read it back', async () => {
      const tx = await txBuilder.addOutput(mocks.utxo[0][1]).extraSigners(signers).build();

      // ValidTxBody contains extraSigners
      expect(tx.extraSigners).toEqual(signers);

      const signedTx = await tx.sign();
      expect(signedTx.witness.signatures.get(pubKey)).toEqual(signature);
    });
  });

  describe('signingOptions', () => {
    let signingOptions: SignTransactionOptions;

    beforeEach(() => {
      signingOptions = { additionalKeyPaths: [{ index: 0, role: KeyRole.Internal }] };
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

    beforeEach(() => {
      assetId = Cardano.AssetId('1ec85dcee27f2d90ec1f9a1e4ce74a667dc9be8b184463223f9c960150584c');
      assetQuantity = 100n;
      assets = new Map([[assetId, assetQuantity]]);
      address = Cardano.PaymentAddress('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg');
      datumHash = Crypto.Hash32ByteBase16('3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d');
      output1Coin = 10_000_000n;
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

    it.only('can search for an ADA handle when given an output', async () => {
      output1Coin = 1234n;
      address = Cardano.PaymentAddress(
        'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
      );

      const outputValue = await txBuilder.buildOutput().handle('$AdaHandle').coin(output1Coin).build();

      expect(outputValue.address).toBe('addr....');
      expect(outputValue.handle).toBe('$somehandle');
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

    it('can set datum', () => {
      outputBuilder.datum(datumHash);
      expect(outputBuilder.toTxOut().datumHash).toEqual(datumHash);
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

  describe('delegate', () => {
    let poolId: Cardano.PoolId;

    beforeEach(() => {
      poolId = somePartialStakePools[0].id;
    });

    it('certificates are added to tx.body on build', async () => {
      const address = Cardano.PaymentAddress('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg');
      txBuilder.delegate(poolId);
      const txOut = await txBuilder.buildOutput().address(address).coin(10_000_000n).build();
      const txBuilt = await txBuilder.addOutput(txOut).build();
      expect(txBuilt.body.certificates?.length).toBe(2);
    });

    it('adds both stake key and delegation certificates when stake key was not registered', async () => {
      const txDelegate = await txBuilder.delegate(poolId).build();
      const [stakeKeyCert, delegationCert] = txDelegate.body.certificates!;
      expect(stakeKeyCert.__typename).toBe(Cardano.CertificateType.StakeKeyRegistration);

      if (delegationCert.__typename === Cardano.CertificateType.StakeDelegation) {
        expect(delegationCert.poolId).toBe(poolId);
      }

      expect.assertions(2);
    });

    it('delegate again removes previous certificates', async () => {
      await txBuilder.delegate(poolId).build();
      const poolIdOther = somePartialStakePools[1].id;
      const secondDelegation = await txBuilder.delegate(poolIdOther).build();
      expect(secondDelegation.body.certificates?.length).toBe(2);
      const delegationCert = secondDelegation.body.certificates![1] as Cardano.StakeDelegationCertificate;
      expect(delegationCert.poolId).toBe(poolIdOther);
    });

    it('throws RewardAccountMissingError error if no reward accounts were found', async () => {
      observableWallet.delegation.rewardAccounts$ = of([]);
      const txBuilder2 = observableWallet.createTxBuilder();

      try {
        await txBuilder2.delegate(poolId).build();
      } catch (error) {
        const buildErrors = error as TxBodyValidationError[];
        expect(buildErrors?.length).toBe(1);
        expect(buildErrors[0] instanceof RewardAccountMissingError).toBeTruthy();
      }
      expect.assertions(2);
    });

    it('adds only delegation certificate with correct poolId when stake key was already registered', async () => {
      observableWallet.delegation.rewardAccounts$ = of([
        {
          address: Cardano.RewardAccount('stake_test1uqu7qkgf00zwqupzqfzdq87dahwntcznklhp3x30t3ukz6gswungn'),
          delegatee: {
            currentEpoch: undefined,
            nextEpoch: undefined,
            nextNextEpoch: undefined
          },
          keyStatus: Cardano.StakeKeyStatus.Registered,
          rewardBalance: 33_333n
        }
      ]);
      const txBuilder2 = observableWallet.createTxBuilder();
      const txDelegate = await txBuilder2.delegate(poolId).build();
      expect(txDelegate.body.certificates?.length).toBe(1);
      const [delegationCert] = txDelegate.body.certificates!;
      if (delegationCert.__typename === Cardano.CertificateType.StakeDelegation) {
        expect(delegationCert.poolId).toBe(poolId);
      }

      expect.assertions(2);
    });

    it('adds multiple certificates when handling multiple reward accounts', async () => {
      observableWallet.delegation.rewardAccounts$ = of([
        {
          address: Cardano.RewardAccount('stake_test1uqu7qkgf00zwqupzqfzdq87dahwntcznklhp3x30t3ukz6gswungn'),
          delegatee: {
            currentEpoch: undefined,
            nextEpoch: undefined,
            nextNextEpoch: undefined
          },
          keyStatus: Cardano.StakeKeyStatus.Unregistered,
          rewardBalance: 33_333n
        },
        {
          address: Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr'),
          delegatee: {
            currentEpoch: undefined,
            nextEpoch: undefined,
            nextNextEpoch: undefined
          },
          keyStatus: Cardano.StakeKeyStatus.Unregistered,
          rewardBalance: 44_444n
        }
      ]);
      const txBuilder2 = observableWallet.createTxBuilder();
      const txDelegate = await txBuilder2.delegate(poolId).build();
      expect(txDelegate.body.certificates?.length).toBe(4);
    });

    it('undefined poolId adds stake key deregister certificate if already registered', async () => {
      observableWallet.delegation.rewardAccounts$ = of([
        {
          address: Cardano.RewardAccount('stake_test1uqu7qkgf00zwqupzqfzdq87dahwntcznklhp3x30t3ukz6gswungn'),
          delegatee: {
            currentEpoch: undefined,
            nextEpoch: undefined,
            nextNextEpoch: undefined
          },
          keyStatus: Cardano.StakeKeyStatus.Registered,
          rewardBalance: 33_333n
        }
      ]);
      const txBuilder2 = observableWallet.createTxBuilder();
      const txDeregister = await txBuilder2.delegate().build();
      expect(txDeregister.body.certificates?.length).toBe(1);
      const [deregisterCert] = txDeregister.body.certificates!;
      expect(deregisterCert.__typename).toBe(Cardano.CertificateType.StakeKeyDeregistration);
    });

    it('undefined poolId does NOT add certificate if not registered', async () => {
      const txDeregister = await txBuilder.delegate().build();
      expect(txDeregister.body.certificates?.length).toBeFalsy();
    });
  });

  describe('error handling', () => {
    it('can validate multiple outputs before building', async () => {
      const coinMissingValidation: OutputValidation = {
        coinMissing: 1n,
        minimumCoin: 2n,
        tokenBundleSizeExceedsLimit: false
      };

      const bundleSizeValidation: OutputValidation = {
        coinMissing: 0n,
        minimumCoin: 2n,
        tokenBundleSizeExceedsLimit: true
      };

      const mockValidator: OutputValidator = {
        validateOutput: jest
          .fn()
          .mockResolvedValueOnce(coinMissingValidation)
          .mockResolvedValueOnce(bundleSizeValidation),
        validateOutputs: jest.fn(),
        validateValue: jest.fn(),
        validateValues: jest.fn()
      };
      const singleAddrWallet = observableWallet as SingleAddressWallet;
      const builder = new GenericTxBuilder(singleAddrWallet.getTxBuilderDependencies(), mockValidator);
      builder.addOutput(output);
      try {
        await builder.addOutput(output2).build();
      } catch (error) {
        const buildErrors = error as TxBodyValidationError[];
        expect(buildErrors?.length).toBeTruthy();

        const [error1, error2] = buildErrors;

        expect(error1 instanceof OutputValidationMinimumCoinError).toBeTruthy();
        if (error1 instanceof OutputValidationMinimumCoinError) {
          expect(error1.message).toEqual(TxOutputFailure.MinimumCoin);
          expect(error1.outputValidation).toEqual(coinMissingValidation);
          expect(error1.txOut).toEqual(output);
        }

        expect(error2 instanceof OutputValidationTokenBundleSizeError).toBeTruthy();
        if (error2 instanceof OutputValidationTokenBundleSizeError) {
          expect(error2.message).toEqual(TxOutputFailure.TokenBundleSizeExceedsLimit);
          expect(error2.outputValidation).toEqual(bundleSizeValidation);
          expect(error2.txOut).toEqual(output2);
        }
      }
      expect.assertions(9);
    });
  });

  it('can be used to build and sign a tx', async () => {
    const builder = observableWallet.createTxBuilder();
    const txO = builder.addOutput(mocks.utxo[0][1]);
    const tx = await txO.build();
    expect(tx.inputSelection).toBeTruthy();
    const signedTx = await tx.sign();
    expect(signedTx.id).toEqual(tx.hash);
  });

  it('can build transactions that are not modified by subsequent builder changes', async () => {
    const builtTxSnapshot1 = await txBuilder.addOutput(mocks.utxo[0][1]).build();
    await txBuilder.addOutput(mocks.utxo[1][1]).build();

    // First built output was not affected by second build() call
    const outputWithoutChange = builtTxSnapshot1.body.outputs[0];
    expect(outputWithoutChange).toEqual(mocks.utxo[0][1]);
  });
});
