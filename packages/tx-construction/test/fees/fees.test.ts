import { Cardano } from '@cardano-sdk/core';
import { MinFeeCoefficient, MinFeeConstant, minAdaRequired, minFee } from '../../src/index.js';
import {
  babbageTx,
  babbageTxWithoutScript,
  noMultiasset,
  noMultiassetMinAda,
  onePolicyOne0CharAsset,
  onePolicyOne0CharAssetDatumHash,
  onePolicyOne0CharAssetDatumHashMinAda,
  onePolicyOne0CharAssetMinAda,
  onePolicyOne1CharAsset,
  onePolicyOne1CharAssetMinAda,
  onePolicyThree1CharAsset,
  onePolicyThree1CharAssetMinAda,
  threePolicyThree32CharAssetDatumHash,
  threePolicyThree32CharAssetDatumHashMinAda,
  twoPoliciesOne0CharAsset,
  twoPoliciesOne0CharAssetMinAda,
  twoPoliciesOne1CharAsset,
  twoPoliciesOne1CharAssetMinAda,
  twoPolicyOne0CharAssetDatum,
  twoPolicyOne0CharAssetDatumAndScriptReference,
  twoPolicyOne0CharAssetDatumAndScriptReferenceMinAda,
  twoPolicyOne0CharAssetDatumHash,
  twoPolicyOne0CharAssetDatumHashMinAda,
  twoPolicyOne0CharAssetDatumMinAda
} from '../testData.js';
import { generateRandomHexString } from '@cardano-sdk/util-dev';

const COST_PER_UTXO_BYTE = BigInt(4310);

describe('fees', () => {
  describe('minAdaRequired', () => {
    it('calculate the correct min ada for an utxo with no multiasset', () => {
      const minAda = minAdaRequired(noMultiasset, COST_PER_UTXO_BYTE);
      expect(minAda).toBe(noMultiassetMinAda);
    });

    it('calculate the correct min ada for an utxo with one policy with one 0 char name asset', () => {
      const minAda = minAdaRequired(onePolicyOne0CharAsset, COST_PER_UTXO_BYTE);
      expect(minAda).toBe(onePolicyOne0CharAssetMinAda);
    });

    it('calculate the correct min ada for an utxo with one policy with one 1 char name asset', () => {
      const minAda = minAdaRequired(onePolicyOne1CharAsset, COST_PER_UTXO_BYTE);
      expect(minAda).toBe(onePolicyOne1CharAssetMinAda);
    });

    it('calculate the correct min ada for an utxo with one policy with three 1 char name assets', () => {
      const minAda = minAdaRequired(onePolicyThree1CharAsset, COST_PER_UTXO_BYTE);
      expect(minAda).toBe(onePolicyThree1CharAssetMinAda);
    });

    it('calculate the correct min ada for an utxo with two policies with one 0 char name assets', () => {
      const minAda = minAdaRequired(twoPoliciesOne0CharAsset, COST_PER_UTXO_BYTE);
      expect(minAda).toBe(twoPoliciesOne0CharAssetMinAda);
    });

    it('calculate the correct min ada for an utxo with two policies with one 1 char name assets', () => {
      const minAda = minAdaRequired(twoPoliciesOne1CharAsset, COST_PER_UTXO_BYTE);
      expect(minAda).toBe(twoPoliciesOne1CharAssetMinAda);
    });

    it('calculate the correct min ada for an utxo with one policy with one 0 char name assets and datum hash', () => {
      const minAda = minAdaRequired(onePolicyOne0CharAssetDatumHash, COST_PER_UTXO_BYTE);
      expect(minAda).toBe(onePolicyOne0CharAssetDatumHashMinAda);
    });

    it(
      'calculate the correct min ada for an utxo with three policies with three' +
        ' 32 char name assets and datum hash',
      () => {
        const minAda = minAdaRequired(threePolicyThree32CharAssetDatumHash, COST_PER_UTXO_BYTE);
        expect(minAda).toBe(threePolicyThree32CharAssetDatumHashMinAda);
      }
    );

    it('calculate the correct min ada for an utxo with two policies with one 0 char name assets and datum hash', () => {
      const minAda = minAdaRequired(twoPolicyOne0CharAssetDatumHash, COST_PER_UTXO_BYTE);
      expect(minAda).toBe(twoPolicyOne0CharAssetDatumHashMinAda);
    });

    it('calculate the correct min ada for an utxo with two policies with one 0 char name assets and datum', () => {
      const minAda = minAdaRequired(twoPolicyOne0CharAssetDatum, COST_PER_UTXO_BYTE);
      expect(minAda).toBe(twoPolicyOne0CharAssetDatumMinAda);
    });

    it(
      'calculate the correct min ada for an utxo with two policies with one 0 char name assets,' +
        'datum and script reference',
      () => {
        const minAda = minAdaRequired(twoPolicyOne0CharAssetDatumAndScriptReference, COST_PER_UTXO_BYTE);
        expect(minAda).toBe(twoPolicyOne0CharAssetDatumAndScriptReferenceMinAda);
      }
    );

    it('calculate the correct min ada for an utxo with 1000 policies with one billion 0 char name asset', () => {
      const output = onePolicyOne0CharAsset;
      const assets = new Map([[Cardano.AssetId('ab8370c97ae17eb69a8c97f733888f7485b60fd820c69211c8bbeb56'), 1n]]);

      for (let i = 0; i < 1000; ++i) {
        const policy = generateRandomHexString(56);
        assets.set(Cardano.AssetId(policy), 1_000_000_000n);
      }

      output.value.assets = assets;
      const minAda = minAdaRequired(output, COST_PER_UTXO_BYTE);
      expect(minAda).toBe(160_599_220n);
    });
  });

  describe('minFee', () => {
    it('calculate the correct min fee for transaction without scripts', () => {
      const prices = { memory: 0.0577, steps: 0.000_007_21 };
      const fee = minFee(babbageTxWithoutScript, prices, MinFeeConstant(155_381), MinFeeCoefficient(44));
      expect(fee).toBe(176_193n);
    });

    it('calculate the correct min fee for transaction with scripts', () => {
      const prices = { memory: 0.0577, steps: 0.000_007_21 };
      const fee = minFee(babbageTx, prices, MinFeeConstant(155_381), MinFeeCoefficient(44));
      expect(fee).toBe(218_763n);
    });
  });
});
