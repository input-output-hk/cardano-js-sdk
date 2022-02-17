/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable no-loop-func */
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable unicorn/consistent-function-scoping */
import { AssetId } from '@cardano-sdk/util-dev';
import { CSL, InvalidProtocolParametersError } from '@cardano-sdk/core';
import { DefaultSelectionConstraintsProps, defaultSelectionConstraints } from '../src/selectionConstraints';
import { ProtocolParametersForInputSelection, SelectionSkeleton } from '../src/types';

jest.mock('@emurgo/cardano-serialization-lib-nodejs', () => {
  const actualCsl = jest.requireActual('@emurgo/cardano-serialization-lib-nodejs');
  return {
    ...actualCsl,
    Value: {
      new: jest.fn()
    },
    min_fee: jest.fn()
  };
});
const cslActual = jest.requireActual('@emurgo/cardano-serialization-lib-nodejs');
const cslMock = jest.requireMock('@emurgo/cardano-serialization-lib-nodejs');

describe('defaultSelectionConstraints', () => {
  const protocolParameters = {
    coinsPerUtxoWord: 34_482,
    maxTxSize: 16_384,
    maxValueSize: 5000,
    minFeeCoefficient: 44,
    minFeeConstant: 155_381
  } as ProtocolParametersForInputSelection;

  it('Invalid parameters', () => {
    for (const param of ['minFeeCoefficient', 'minFeeConstant', 'coinsPerUtxoWord', 'maxTxSize', 'maxValueSize']) {
      expect(() =>
        defaultSelectionConstraints({
          protocolParameters: { ...protocolParameters, [param]: null }
        } as DefaultSelectionConstraintsProps)
      ).toThrowError(InvalidProtocolParametersError);
    }
  });

  it('computeMinimumCost', async () => {
    const fee = 200_000n;
    // Need this to not have to build Tx
    cslMock.min_fee.mockReturnValueOnce(cslMock.BigNum.from_str(fee.toString()));
    const buildTx = jest.fn();
    const selectionSkeleton = {} as SelectionSkeleton;
    const constraints = defaultSelectionConstraints({
      buildTx,
      protocolParameters
    });
    const result = await constraints.computeMinimumCost(selectionSkeleton);
    expect(result).toEqual(fee + 10_000n);
    expect(buildTx).toBeCalledTimes(1);
    expect(buildTx).toBeCalledWith(selectionSkeleton);
  });

  it('computeMinimumCoinQuantity', () => {
    cslMock.Value.new.mockImplementation(cslActual.Value.new);
    const assets = new Map([
      [AssetId.TSLA, 5000n],
      [AssetId.PXL, 3000n]
    ]);
    const constraints = defaultSelectionConstraints({
      protocolParameters
    } as DefaultSelectionConstraintsProps);
    const minCoinWithAssets = constraints.computeMinimumCoinQuantity(assets);
    const minCoinWithoutAssets = constraints.computeMinimumCoinQuantity();
    expect(typeof minCoinWithAssets).toBe('bigint');
    expect(typeof minCoinWithoutAssets).toBe('bigint');
    expect(minCoinWithAssets).toBeGreaterThan(minCoinWithoutAssets);
  });

  describe('computeSelectionLimit', () => {
    const buildTxOfLength = (length: number) => async () => ({ to_bytes: () => ({ length }) } as CSL.Transaction);

    it("doesn't exceed max tx size", async () => {
      const constraints = defaultSelectionConstraints({
        buildTx: buildTxOfLength(protocolParameters.maxTxSize!),
        protocolParameters
      });
      expect(await constraints.computeSelectionLimit({ inputs: new Set([1, 2]) as any } as SelectionSkeleton)).toEqual(
        2
      );
    });

    it('exceeds max tx size', async () => {
      const constraints = defaultSelectionConstraints({
        buildTx: buildTxOfLength(protocolParameters.maxTxSize! + 1),
        protocolParameters
      });
      expect(await constraints.computeSelectionLimit({ inputs: new Set([1, 2]) as any } as SelectionSkeleton)).toEqual(
        3
      );
    });
  });

  describe('tokenBundleSizeExceedsLimit', () => {
    const stubCslValueLength = (length: number) => {
      cslMock.Value.new.mockReturnValue({
        set_multiasset: jest.fn(),
        to_bytes: () => ({ length })
      });
    };

    it('empty bundle', () => {
      const constraints = defaultSelectionConstraints({
        buildTx: jest.fn(),
        protocolParameters
      });
      expect(constraints.tokenBundleSizeExceedsLimit()).toBe(false);
    });

    it("doesn't exceed max value size", () => {
      stubCslValueLength(protocolParameters.maxValueSize!);
      const constraints = defaultSelectionConstraints({
        protocolParameters
      } as DefaultSelectionConstraintsProps);
      expect(constraints.tokenBundleSizeExceedsLimit(new Map())).toBe(false);
    });

    it('exceeds max value size', () => {
      stubCslValueLength(protocolParameters.maxValueSize! + 1);
      const constraints = defaultSelectionConstraints({
        protocolParameters
      } as DefaultSelectionConstraintsProps);
      expect(constraints.tokenBundleSizeExceedsLimit(new Map())).toBe(true);
    });
  });
});
