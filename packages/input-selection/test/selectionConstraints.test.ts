/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable no-loop-func */
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable unicorn/consistent-function-scoping */
import { AssetId } from '@cardano-sdk/util-dev';
import { CML, Cardano, InvalidProtocolParametersError } from '@cardano-sdk/core';
import { DefaultSelectionConstraintsProps, defaultSelectionConstraints } from '../src/selectionConstraints';
import { ProtocolParametersForInputSelection, SelectionSkeleton } from '../src/types';

jest.mock('@dcspark/cardano-multiplatform-lib-nodejs', () => {
  const actualCml = jest.requireActual('@dcspark/cardano-multiplatform-lib-nodejs');
  return {
    ...actualCml,
    Value: {
      new: jest.fn()
    },
    min_fee: jest.fn()
  };
});
const cmlActual = jest.requireActual('@dcspark/cardano-multiplatform-lib-nodejs');
const cmlMock = jest.requireMock('@dcspark/cardano-multiplatform-lib-nodejs');

describe('defaultSelectionConstraints', () => {
  const protocolParameters = {
    coinsPerUtxoByte: 4310,
    maxTxSize: 16_384,
    maxValueSize: 5000,
    minFeeCoefficient: 44,
    minFeeConstant: 155_381
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
    const fee = 200_000n;
    // Need this to not have to build Tx
    cmlMock.min_fee.mockReturnValueOnce(cmlMock.BigNum.from_str(fee.toString()));
    const buildTx = jest.fn();
    const selectionSkeleton = {} as SelectionSkeleton;
    const constraints = defaultSelectionConstraints({
      buildTx,
      protocolParameters
    });
    const result = await constraints.computeMinimumCost(selectionSkeleton);
    expect(result).toEqual(fee);
    expect(buildTx).toBeCalledTimes(1);
    expect(buildTx).toBeCalledWith(selectionSkeleton, expect.anything());
  });

  it('computeMinimumCoinQuantity', () => {
    cmlMock.Value.new.mockImplementation(cmlActual.Value.new);
    const assets = new Map([
      [AssetId.TSLA, 5000n],
      [AssetId.PXL, 3000n]
    ]);
    const constraints = defaultSelectionConstraints({
      protocolParameters
    } as DefaultSelectionConstraintsProps);
    const address = Cardano.Address(
      'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9'
    );
    const minCoinWithAssets = constraints.computeMinimumCoinQuantity({ address, value: { assets, coins: 0n } });
    const minCoinWithoutAssets = constraints.computeMinimumCoinQuantity({ address, value: { coins: 0n } });
    expect(typeof minCoinWithAssets).toBe('bigint');
    expect(typeof minCoinWithoutAssets).toBe('bigint');
    expect(minCoinWithAssets).toBeGreaterThan(minCoinWithoutAssets);
  });

  describe('computeSelectionLimit', () => {
    const buildTxOfLength = (length: number) => async () => ({ to_bytes: () => ({ length }) } as CML.Transaction);

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
        1
      );
    });
  });

  describe('tokenBundleSizeExceedsLimit', () => {
    const stubCmlValueLength = (length: number) => {
      cmlMock.Value.new.mockReturnValue({
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
      stubCmlValueLength(protocolParameters.maxValueSize!);
      const constraints = defaultSelectionConstraints({
        protocolParameters
      } as DefaultSelectionConstraintsProps);
      expect(constraints.tokenBundleSizeExceedsLimit(new Map())).toBe(false);
    });

    it('exceeds max value size', () => {
      stubCmlValueLength(protocolParameters.maxValueSize! + 1);
      const constraints = defaultSelectionConstraints({
        protocolParameters
      } as DefaultSelectionConstraintsProps);
      expect(constraints.tokenBundleSizeExceedsLimit(new Map())).toBe(true);
    });
  });
});
