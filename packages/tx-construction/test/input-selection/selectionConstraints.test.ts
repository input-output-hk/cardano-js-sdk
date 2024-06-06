/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable no-loop-func */
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable unicorn/consistent-function-scoping */
import { AssetId } from '@cardano-sdk/util-dev';
import { Cardano, InvalidProtocolParametersError, Serialization } from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';
import { babbageTx, getBigBabbageTx } from '../testData.js';
import { defaultSelectionConstraints } from '../../src/index.js';
import { mockTxEvaluator } from '../tx-builder/mocks.js';
import type { DefaultSelectionConstraintsProps } from '../../src/index.js';
import type { ProtocolParametersForInputSelection, SelectionSkeleton } from '@cardano-sdk/input-selection';

describe('defaultSelectionConstraints', () => {
  const protocolParameters = {
    coinsPerUtxoByte: 4310,
    maxTxSize: 16_384,
    maxValueSize: 5000,
    minFeeCoefficient: 44,
    minFeeConstant: 155_381,
    prices: { memory: 0.0577, steps: 0.000_007_21 }
  } as ProtocolParametersForInputSelection;

  it('Invalid parameters', () => {
    for (const param of ['minFeeCoefficient', 'minFeeConstant', 'coinsPerUtxoByte', 'maxTxSize', 'maxValueSize']) {
      expect(() =>
        defaultSelectionConstraints({
          protocolParameters: { ...protocolParameters, [param]: null }
        } as DefaultSelectionConstraintsProps)
      ).toThrowError(InvalidProtocolParametersError);
    }
  });

  it('computeMinimumCost', async () => {
    const fee = 218_137n;
    const buildTx = jest.fn(async () => babbageTx);
    const selectionSkeleton = { inputs: [] } as unknown as SelectionSkeleton;
    const constraints = defaultSelectionConstraints({
      buildTx,
      protocolParameters,
      redeemersByType: {
        certificate: [
          {
            data: Serialization.PlutusData.fromCbor(HexBlob('d86682008102')).toCore(),
            executionUnits: {
              memory: 0,
              steps: 0
            },
            index: 1,
            purpose: Cardano.RedeemerPurpose.certificate
          }
        ],
        mint: [
          {
            data: Serialization.PlutusData.fromCbor(HexBlob('d86682008101')).toCore(),
            executionUnits: {
              memory: 0,
              steps: 0
            },
            index: 0,
            purpose: Cardano.RedeemerPurpose.mint
          }
        ]
      },
      txEvaluator: mockTxEvaluator
    });

    const result = await constraints.computeMinimumCost(selectionSkeleton);
    expect(result).toEqual({
      fee,
      redeemers: [
        {
          data: Serialization.PlutusData.fromCbor(HexBlob('d86682008101')).toCore(),
          executionUnits: {
            memory: 100,
            steps: 200
          },
          index: 0,
          purpose: Cardano.RedeemerPurpose.mint
        },
        {
          data: Serialization.PlutusData.fromCbor(HexBlob('d86682008102')).toCore(),
          executionUnits: {
            memory: 100,
            steps: 200
          },
          index: 1,
          purpose: Cardano.RedeemerPurpose.certificate
        }
      ]
    });
    expect(buildTx).toBeCalledTimes(1);
    expect(buildTx).toBeCalledWith(selectionSkeleton);
  });

  it('computeMinimumCoinQuantity', () => {
    const assets = new Map([
      [AssetId.TSLA, 5000n],
      [AssetId.PXL, 3000n]
    ]);
    const constraints = defaultSelectionConstraints({
      protocolParameters
    } as DefaultSelectionConstraintsProps);
    const address = Cardano.PaymentAddress(
      'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9'
    );
    const minCoinWithAssets = constraints.computeMinimumCoinQuantity({ address, value: { assets, coins: 0n } });
    const minCoinWithoutAssets = constraints.computeMinimumCoinQuantity({ address, value: { coins: 0n } });
    expect(typeof minCoinWithAssets).toBe('bigint');
    expect(typeof minCoinWithoutAssets).toBe('bigint');
    expect(minCoinWithAssets).toBeGreaterThan(minCoinWithoutAssets);
  });

  describe('computeSelectionLimit', () => {
    it("doesn't exceed max tx size", async () => {
      const constraints = defaultSelectionConstraints({
        buildTx: async () => babbageTx,
        protocolParameters,
        redeemersByType: {},
        txEvaluator: mockTxEvaluator
      });
      expect(await constraints.computeSelectionLimit({ inputs: new Set([1, 2]) as any } as SelectionSkeleton)).toEqual(
        2
      );
    });

    it('exceeds max tx size', async () => {
      const constraints = defaultSelectionConstraints({
        buildTx: getBigBabbageTx,
        protocolParameters,
        redeemersByType: {},
        txEvaluator: mockTxEvaluator
      });
      expect(await constraints.computeSelectionLimit({ inputs: new Set([1, 2]) as any } as SelectionSkeleton)).toEqual(
        1
      );
    });
  });

  describe('tokenBundleSizeExceedsLimit', () => {
    it('empty bundle', () => {
      const constraints = defaultSelectionConstraints({
        buildTx: jest.fn(),
        protocolParameters,
        redeemersByType: {},
        txEvaluator: mockTxEvaluator
      });
      expect(constraints.tokenBundleSizeExceedsLimit()).toBe(false);
    });

    it("doesn't exceed max value size", () => {
      const constraints = defaultSelectionConstraints({
        protocolParameters: { ...protocolParameters, maxValueSize: 1_000_000_000 }
      } as DefaultSelectionConstraintsProps);
      expect(constraints.tokenBundleSizeExceedsLimit(new Map())).toBe(false);
    });

    it('exceeds max value size', () => {
      const constraints = defaultSelectionConstraints({
        protocolParameters: { ...protocolParameters, maxValueSize: 1 }
      } as DefaultSelectionConstraintsProps);
      expect(constraints.tokenBundleSizeExceedsLimit(new Map())).toBe(true);
    });
  });
});
