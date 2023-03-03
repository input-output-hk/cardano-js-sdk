/* eslint-disable func-style */
/* eslint-disable jsdoc/require-jsdoc */
import * as Crypto from '@cardano-sdk/crypto';
import { AssetId, logger, somePartialStakePools } from '@cardano-sdk/util-dev';
import { Cardano, CardanoNodeErrors } from '@cardano-sdk/core';

import { of } from 'rxjs';

import * as mocks from '../mocks';
import {
  IncompatibleWalletError,
  ObservableWallet,
  OutputBuilder,
  OutputValidation,
  OutputValidationMinimumCoinError,
  OutputValidationMissingRequiredError,
  OutputValidationTokenBundleSizeError,
  OutputValidator,
  StakeKeyStatus,
  TxAlreadySubmittedError,
  TxBuilder,
  TxOutputFailure,
  buildTx
} from '../../src';
import { KeyRole, SignTransactionOptions, TransactionSigner } from '@cardano-sdk/key-management';
import { assertTxIsValid, assertTxOutIsValid } from '../util';
import { createWallet } from './util';

function assertObjectRefsAreDifferent(obj1: unknown, obj2: unknown): void {
  expect(obj1).not.toBe(obj2);
}

describe('buildTx', () => {
  let observableWallet: ObservableWallet;
  let txBuilder: TxBuilder;
  let output: Cardano.TxOut;
  let output2: Cardano.TxOut;

  beforeEach(async () => {
    ({ wallet: observableWallet } = await createWallet());
    output = mocks.utxo[0][1];
    output2 = mocks.utxo[1][1];
    txBuilder = buildTx({ logger, observableWallet });
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

  describe('setMetadata', () => {
    let metadata: Cardano.TxMetadata;

    it('can add metadata without mutating auxiliaryData', () => {
      metadata = new Map([[123n, '1234']]);
      const initialAuxiliaryData = txBuilder.auxiliaryData;
      txBuilder.setMetadata(metadata);
      assertObjectRefsAreDifferent(txBuilder.auxiliaryData, initialAuxiliaryData);
      expect(txBuilder.auxiliaryData?.body.blob).toEqual(metadata);
    });

    it('can unset metadata by using empty map', () => {
      metadata = new Map();
      txBuilder.setMetadata(metadata);
      expect(txBuilder.auxiliaryData?.body.blob?.entries.length).toBe(0);
    });

    it('can add metadata, sign and read it back', async () => {
      const tx = await txBuilder.addOutput(mocks.utxo[0][1]).setMetadata(metadata).build();
      assertTxIsValid(tx);

      // ValidTxBody contains metadata
      expect(tx.auxiliaryData?.body.blob).toEqual(metadata);

      const signedTx = await tx.sign();
      expect(signedTx.tx.auxiliaryData?.body.blob).toEqual(metadata);
    });
  });

  describe('setExtraSigners', () => {
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
      txBuilder.setExtraSigners(signers);
      assertObjectRefsAreDifferent(txBuilder.extraSigners, initialSigners);
      expect(txBuilder.extraSigners).toEqual(signers);
    });

    it('can unset extraSigners by using empty array', () => {
      txBuilder.setExtraSigners(signers);
      txBuilder.setExtraSigners([]);
      expect(txBuilder.extraSigners?.length).toBe(0);
    });

    it('can set extraSigners, sign and read it back', async () => {
      const tx = await txBuilder.addOutput(mocks.utxo[0][1]).setExtraSigners(signers).build();
      assertTxIsValid(tx);

      // ValidTxBody contains extraSigners
      expect(tx.extraSigners).toEqual(signers);

      const signedTx = await tx.sign();
      expect(signedTx.tx.witness.signatures.get(pubKey)).toEqual(signature);
    });
  });

  describe('setSigningOptions', () => {
    let signingOptions: SignTransactionOptions;

    beforeEach(() => {
      signingOptions = { additionalKeyPaths: [{ index: 0, role: KeyRole.Internal }] };
    });

    it('can setSigningOptions without mutating signingOptions', () => {
      const initialSigningOptions = txBuilder.signingOptions;
      txBuilder.setSigningOptions(signingOptions);
      assertObjectRefsAreDifferent(txBuilder.signingOptions, initialSigningOptions);
      expect(txBuilder.signingOptions).toEqual(signingOptions);
    });

    it('can unset signingOptions by using empty object', () => {
      txBuilder.setSigningOptions(signingOptions);
      txBuilder.setSigningOptions({});
      expect(txBuilder.signingOptions?.additionalKeyPaths).toBeFalsy();
    });

    it('uses signingOptions to finalize transaction when submitting', async () => {
      const origFinalizeTx = observableWallet.finalizeTx;
      observableWallet.finalizeTx = jest.fn(origFinalizeTx);

      const tx = await txBuilder.addOutput(mocks.utxo[0][1]).setSigningOptions(signingOptions).build();
      assertTxIsValid(tx);

      // ValidTxBody contains signingOptions
      expect(tx.signingOptions).toEqual(signingOptions);

      await (await tx.sign()).submit();
      expect(observableWallet.finalizeTx).toHaveBeenLastCalledWith(expect.objectContaining({ signingOptions }));
    });
  });

  describe('buildOutput', () => {
    let outputBuilder: OutputBuilder;
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

      outputBuilder = txBuilder.buildOutput().address(address).coin(output1Coin);
    });

    it('can create OutputBuilder without initial output', () => {
      expect(outputBuilder.toTxOut()).toBeTruthy();
    });

    it('can create OutputBuilder starting from an existing output', () => {
      const outputBuilderFromExisting = txBuilder.buildOutput(output);
      expect(outputBuilderFromExisting.toTxOut()).toEqual(output);
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

      assertTxOutIsValid(builtOutput);
      expect(builtOutput.txOut).toEqual<Cardano.TxOut>({ address, value: { assets, coins: output1Coin } });

      const builtOutputFromOther = await txBuilder.buildOutput(output2Base).assets(assets).datum(datumHash).build();
      assertTxOutIsValid(builtOutputFromOther);
      expect(builtOutputFromOther.txOut).toEqual<Cardano.TxOut>({
        datumHash,
        ...output2Base,
        value: { ...output2Base.value, assets }
      });
    });

    describe('can build and validate', () => {
      it('missing coin field', async () => {
        const builtOutput = await txBuilder.buildOutput().address(address).build();
        const [error] = (!builtOutput.isValid && builtOutput.errors) || [];
        expect(
          error instanceof OutputValidationMissingRequiredError &&
            error.message === TxOutputFailure.MissingRequiredFields
        ).toBeTruthy();
      });

      it('missing address field', async () => {
        const builtOutput = await txBuilder.buildOutput().coin(output1Coin).build();
        const [error] = (!builtOutput.isValid && builtOutput.errors) || [];
        expect(
          error instanceof OutputValidationMissingRequiredError &&
            error.message === TxOutputFailure.MissingRequiredFields
        ).toBeTruthy();
      });

      it('legit output with valid with address and coin', async () => {
        const builtOutput = await txBuilder.buildOutput().address(address).coin(output1Coin).build();
        assertTxOutIsValid(builtOutput);
      });
    });

    describe('can validate required output fields', () => {
      it('missing coin field', () => {
        expect(() => txBuilder.buildOutput().address(address).toTxOut()).toThrowError(
          OutputValidationMissingRequiredError
        );
      });

      it('missing address field', () => {
        expect(() => txBuilder.buildOutput().coin(output1Coin).toTxOut()).toThrowError(
          OutputValidationMissingRequiredError
        );
      });

      it('legit output with valid with address and coin', async () => {
        expect(() => txBuilder.buildOutput().address(address).coin(output1Coin).toTxOut()).not.toThrow();
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
      const maybeValidTxOut = await txBuilder.buildOutput().address(address).coin(10_000_000n).build();
      assertTxOutIsValid(maybeValidTxOut);
      const txBuilt = await txBuilder.addOutput(maybeValidTxOut.txOut).build();

      assertTxIsValid(txBuilt);
      expect(txBuilt.body.certificates?.length).toBe(2);
    });

    it('adds both stake key and delegation certificates when stake key was not registered', async () => {
      const txDelegate = await txBuilder.delegate(poolId).build();
      assertTxIsValid(txDelegate);
      const [stakeKeyCert, delegationCert] = txDelegate.body.certificates!;
      expect(stakeKeyCert.__typename).toBe(Cardano.CertificateType.StakeKeyRegistration);

      if (delegationCert.__typename === Cardano.CertificateType.StakeDelegation) {
        expect(delegationCert.poolId).toBe(poolId);
      }

      expect.assertions(3);
    });

    it('delegate again removes previous certificates', async () => {
      await txBuilder.delegate(poolId).build();
      const poolIdOther = somePartialStakePools[1].id;
      const secondDelegation = await txBuilder.delegate(poolIdOther).build();
      assertTxIsValid(secondDelegation);
      expect(secondDelegation.body.certificates?.length).toBe(2);
      const delegationCert = secondDelegation.body.certificates![1] as Cardano.StakeDelegationCertificate;
      expect(delegationCert.poolId).toBe(poolIdOther);
    });

    it('throws IncompatibleWallet error if no reward accounts were found', async () => {
      observableWallet.delegation.rewardAccounts$ = of([]);
      const txBuilt = await txBuilder.delegate(poolId).build();
      if (!txBuilt.isValid) {
        expect(txBuilt.errors?.length).toBe(1);
        expect(txBuilt.errors[0] instanceof IncompatibleWalletError).toBeTruthy();
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
          keyStatus: StakeKeyStatus.Registered,
          rewardBalance: 33_333n
        }
      ]);
      const txDelegate = await txBuilder.delegate(poolId).build();
      assertTxIsValid(txDelegate);
      expect(txDelegate.body.certificates?.length).toBe(1);
      const [delegationCert] = txDelegate.body.certificates!;
      if (delegationCert.__typename === Cardano.CertificateType.StakeDelegation) {
        expect(delegationCert.poolId).toBe(poolId);
      }

      expect.assertions(3);
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
          keyStatus: StakeKeyStatus.Unregistered,
          rewardBalance: 33_333n
        },
        {
          address: Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr'),
          delegatee: {
            currentEpoch: undefined,
            nextEpoch: undefined,
            nextNextEpoch: undefined
          },
          keyStatus: StakeKeyStatus.Unregistered,
          rewardBalance: 44_444n
        }
      ]);

      const txDelegate = await txBuilder.delegate(poolId).build();
      assertTxIsValid(txDelegate);
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
          keyStatus: StakeKeyStatus.Registered,
          rewardBalance: 33_333n
        }
      ]);
      const txDeregister = await txBuilder.delegate().build();
      assertTxIsValid(txDeregister);
      expect(txDeregister.body.certificates?.length).toBe(1);
      const [deregisterCert] = txDeregister.body.certificates!;
      expect(deregisterCert.__typename).toBe(Cardano.CertificateType.StakeKeyDeregistration);
    });

    it('undefined poolId does NOT add certificate if not registered', async () => {
      const txDeregister = await txBuilder.delegate().build();
      assertTxIsValid(txDeregister);
      expect(txDeregister.body.certificates?.length).toBeFalsy();
    });
  });

  describe('after sign and submit', () => {
    beforeEach(async () => {
      const tx = await txBuilder.addOutput(mocks.utxo[0][1]).build();
      assertTxIsValid(tx);
      await (await tx.sign()).submit();
    });

    it('cannot rebuild', async () => {
      expect(txBuilder.isSubmitted()).toBeTruthy();
      const tx = await txBuilder.build();
      expect(tx.isValid).toBeFalsy();
      if (!tx.isValid) {
        expect(tx.errors[0] instanceof TxAlreadySubmittedError).toBeTruthy();
      }
    });

    it('can rebuild when submit is not successful', async () => {
      const txBuilder2 = buildTx({ logger, observableWallet });
      observableWallet.submitTx = jest.fn().mockRejectedValue(null);
      const tx = await txBuilder2.addOutput(mocks.utxo[1][1]).build();
      assertTxIsValid(tx);

      // submit fails
      await expect((await tx.sign()).submit()).rejects.toBe(null);
      expect(txBuilder2.isSubmitted()).toBeFalsy();

      // can rebuild because submit was not successful
      const tx2 = await txBuilder2.build();
      assertTxIsValid(tx2);
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
      const builder = buildTx({ logger, observableWallet, outputValidator: mockValidator }).addOutput(output);
      const tx = await builder.addOutput(builder.buildOutput(output2).toTxOut()).build();

      expect(tx.isValid).toBeFalsy();
      const [error1, error2] = (!tx.isValid && tx.errors) || [];

      expect(error1 instanceof OutputValidationMinimumCoinError).toBeTruthy();
      if (error1 instanceof OutputValidationMinimumCoinError) {
        expect(error1.message === TxOutputFailure.MinimumCoin);
        expect(error1.outputValidation).toEqual(coinMissingValidation);
        expect(error1.txOut).toEqual(output);
      }

      expect(error2 instanceof OutputValidationTokenBundleSizeError).toBeTruthy();
      if (error2 instanceof OutputValidationTokenBundleSizeError) {
        expect(error2.message === TxOutputFailure.TokenBundleSizeExceedsLimit);
        expect(error2.outputValidation).toEqual(bundleSizeValidation);
        expect(error2.txOut).toEqual(output2);
      }
    });

    it('rejects if error is encountered during transaction finalization', async () => {
      const signError = new Error('oh no, signing error');

      const builtTx = await buildTx({ logger, observableWallet }).addOutput(output).build();
      assertTxIsValid(builtTx);

      observableWallet.finalizeTx = jest.fn().mockRejectedValue(signError);

      await expect(builtTx.sign()).rejects.toBe(signError);
    });

    it('rejects if error is encountered during submission', async () => {
      const submitErr = new CardanoNodeErrors.TxSubmissionErrors.AlreadyDelegatingError({
        alreadyDelegating: 'that is just terrible'
      });
      observableWallet.submitTx = jest.fn().mockRejectedValue(submitErr);

      const builtTx = await buildTx({ logger, observableWallet }).addOutput(output).build();
      assertTxIsValid(builtTx);
      const signedTx = await builtTx.sign();
      await expect(signedTx.submit()).rejects.toBe(submitErr);
    });
  });

  it('can be used to build, sign and submit a tx', async () => {
    const tx = await buildTx({ logger, observableWallet }).addOutput(mocks.utxo[0][1]).build();
    if (tx.isValid) {
      expect(tx.inputSelection).toBeTruthy();
      const signedTx = await tx.sign();
      expect(signedTx.tx.id).toEqual(tx.hash);
      await signedTx.submit();
    } else {
      expect(tx.errors.length).toBeGreaterThan(0);
      throw new Error('Invalid tx');
    }
  });

  it('can build transactions that are not modified by subsequent builder changes', async () => {
    const builtTxSnapshot1 = await txBuilder.addOutput(mocks.utxo[0][1]).build();
    assertTxIsValid(builtTxSnapshot1);

    const builtTxSnapshot2 = await txBuilder.addOutput(mocks.utxo[1][1]).build();
    assertTxIsValid(builtTxSnapshot2);

    // First built output was not affected by second build() call
    const outputWithoutChange = builtTxSnapshot1.body.outputs[0];
    expect(outputWithoutChange).toEqual(mocks.utxo[0][1]);
  });
});
