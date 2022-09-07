/* eslint-disable func-style */
/* eslint-disable jsdoc/require-jsdoc */
import { AssetId, somePartialStakePools } from '@cardano-sdk/util-dev';
import { Cardano } from '@cardano-sdk/core';
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
  let wallet: ObservableWallet;
  let txBuilder: TxBuilder;
  let output: Cardano.TxOut;
  let output2: Cardano.TxOut;

  beforeEach(async () => {
    ({ wallet } = await createWallet());
    output = mocks.utxo[0][1];
    output2 = mocks.utxo[1][1];
    txBuilder = buildTx(wallet);
  });

  afterEach(() => wallet.shutdown());

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
    const pubKey = Cardano.Ed25519PublicKey('6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39');
    const signature = Cardano.Ed25519Signature(
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
      expect(signedTx.tx.witness.signatures).toEqual(new Map([[pubKey, signature]]));
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
      const origFinalizeTx = wallet.finalizeTx;
      wallet.finalizeTx = jest.fn(origFinalizeTx);

      const tx = await txBuilder.addOutput(mocks.utxo[0][1]).setSigningOptions(signingOptions).build();
      assertTxIsValid(tx);

      // ValidTxBody contains signingOptions
      expect(tx.signingOptions).toEqual(signingOptions);

      await (await tx.sign()).submit();
      expect(wallet.finalizeTx).toHaveBeenLastCalledWith(expect.objectContaining({ signingOptions }));
    });
  });

  describe('buildOutput', () => {
    let outputBuilder: OutputBuilder;
    let assetId: Cardano.AssetId;
    let assetQuantity: bigint;
    let assets: Cardano.TokenMap;
    let address: Cardano.Address;
    let datum: Cardano.Hash32ByteBase16;
    let output1Coin: bigint;
    let output2Base: Cardano.TxOut;

    beforeEach(() => {
      assetId = Cardano.AssetId('1ec85dcee27f2d90ec1f9a1e4ce74a667dc9be8b184463223f9c960150584c');
      assetQuantity = 100n;
      assets = new Map([[assetId, assetQuantity]]);
      address = Cardano.Address('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg');
      datum = Cardano.Hash32ByteBase16('3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d');
      output1Coin = 10_000_000n;
      output2Base = mocks.utxo[0][1];

      outputBuilder = txBuilder.buildOutput();
    });

    it('can create OutputBuilder without initial output', () => {
      expect(outputBuilder.partialOutput).toBeTruthy();
    });

    it('can create OutputBuilder starting from an existing output', () => {
      const outputBuilderFromExisting = txBuilder.buildOutput(output);
      expect(outputBuilderFromExisting.partialOutput).toEqual(output);
    });

    it('can set partialOutput value overwriting preexisting value', () => {
      const outValue = { assets, coins: output1Coin };
      outputBuilder.value(outValue);
      expect(outputBuilder.partialOutput.value).toEqual(outValue);

      // Setting outValueOther will remove previously configured assets
      const outValueOther = { coins: output1Coin + 100n };
      outputBuilder.value(outValueOther);
      expect(outputBuilder.partialOutput.value).toEqual(outValueOther);
    });

    it('can set coin value', () => {
      outputBuilder.coin(output1Coin);
      expect(outputBuilder.partialOutput.value).toEqual({ coins: output1Coin });
    });

    it('can set partialOutput assets', () => {
      outputBuilder.assets(assets);
      expect(outputBuilder.partialOutput.value).toEqual({ assets });
    });

    it('can add assets one by one', () => {
      outputBuilder.asset(AssetId.PXL, 5n).asset(AssetId.TSLA, 10n);
      expect(outputBuilder.partialOutput.value?.assets?.size).toBe(2);
      expect(outputBuilder.partialOutput.value?.assets?.get(AssetId.PXL)).toBe(5n);
      expect(outputBuilder.partialOutput.value?.assets?.get(AssetId.TSLA)).toBe(10n);
    });

    it('can update asset quantity by assetId', () => {
      outputBuilder.asset(AssetId.PXL, 5n).asset(AssetId.TSLA, 10n);
      outputBuilder.asset(AssetId.PXL, 11n);
      expect(outputBuilder.partialOutput.value?.assets?.get(AssetId.PXL)).toBe(11n);
    });

    it('can remove asset by using quantity 0', () => {
      outputBuilder.assets(assets);
      expect(outputBuilder.partialOutput.value?.assets?.size).toBe(1);
      outputBuilder.asset(assetId, 0n);
      expect(outputBuilder.partialOutput.value?.assets?.size).toBe(0);
    });

    it('can set address', () => {
      outputBuilder.address(address);
      expect(outputBuilder.partialOutput.address).toEqual(address);
    });

    it('can set datum', () => {
      outputBuilder.datum(datum);
      expect(outputBuilder.partialOutput.datum).toEqual(datum);
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

      const builtOutputFromOther = await txBuilder.buildOutput(output2Base).assets(assets).datum(datum).build();
      assertTxOutIsValid(builtOutputFromOther);
      expect(builtOutputFromOther.txOut).toEqual<Cardano.TxOut>({
        datum,
        ...output2Base,
        value: { ...output2Base.value, assets }
      });
    });

    describe('can validate', () => {
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
  });

  describe('delegate', () => {
    let poolId: Cardano.PoolId;

    beforeEach(() => {
      poolId = somePartialStakePools[0].id;
    });

    it('certificates are added to tx.body on build', async () => {
      const address = Cardano.Address('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg');
      txBuilder.delegate(poolId);
      const maybeValidTxOut = await txBuilder.buildOutput().address(address).coin(10_000_000n).build();
      assertTxOutIsValid(maybeValidTxOut);
      const txBuilt = await txBuilder.addOutput(maybeValidTxOut.txOut).build();

      assertTxIsValid(txBuilt);
      expect(txBuilt.body.certificates?.length).toBe(2);
    });

    it('adds both stake key and delegation certificates when reward account was not registered', async () => {
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
      wallet.delegation.rewardAccounts$ = of([]);
      const txBuilt = await txBuilder.delegate(poolId).build();
      if (!txBuilt.isValid) {
        expect(txBuilt.errors?.length).toBe(1);
        expect(txBuilt.errors[0] instanceof IncompatibleWalletError).toBeTruthy();
      }
      expect.assertions(2);
    });

    it('adds only delegation certificate with correct poolId when reward account was already registered', async () => {
      wallet.delegation.rewardAccounts$ = of([
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
      wallet.delegation.rewardAccounts$ = of([
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
  });

  it('can be used to build, sign and submit a tx', async () => {
    const tx = await buildTx(wallet).addOutput(mocks.utxo[0][1]).build();
    if (tx.isValid) {
      const signedTx = await tx.sign();
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
      validateOutput: jest.fn(),
      validateOutputs: jest.fn(() =>
        Promise.resolve(
          new Map([
            [output, coinMissingValidation],
            [output2, bundleSizeValidation]
          ])
        )
      ),
      validateValue: jest.fn(),
      validateValues: jest.fn()
    };
    const tx = await buildTx(wallet, mockValidator).addOutput(output).addOutput(output2).build();

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
});
