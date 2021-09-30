/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable unicorn/consistent-function-scoping */
import {
  CardanoSerializationLib,
  CSL,
  loadCardanoSerializationLib,
  ProtocolParametersRequiredByWallet
} from '@cardano-sdk/core';
import { PXL_Asset, TSLA_Asset } from './util';
import { defaultSelectionConstraints, DefaultSelectionConstraintsProps } from '../src/selectionConstraints';
import { SelectionSkeleton } from '../src/types';
import { ogmiosValueToCslValue } from '../src/util';

describe('defaultSelectionConstraints', () => {
  let csl: CardanoSerializationLib;
  const protocolParameters = {
    minFeeCoefficient: 44,
    minFeeConstant: 155_381,
    coinsPerUtxoWord: 34_482,
    maxTxSize: 16_384,
    maxValueSize: 5000
  } as ProtocolParametersRequiredByWallet;

  beforeAll(async () => (csl = await loadCardanoSerializationLib()));

  it('computeMinimumCost', async () => {
    const fee = 200_000n;
    // Need this to not have to build Tx
    const stubCsl = {
      min_fee: jest.fn().mockReturnValueOnce(csl.BigNum.from_str(fee.toString())),
      LinearFee: csl.LinearFee,
      BigNum: csl.BigNum
    } as any as CardanoSerializationLib;
    const buildTx = jest.fn();
    const selectionSkeleton = {} as SelectionSkeleton;
    const constraints = defaultSelectionConstraints({
      csl: stubCsl,
      protocolParameters,
      buildTx
    });
    const result = await constraints.computeMinimumCost(selectionSkeleton);
    expect(result).toEqual(fee);
    expect(buildTx).toBeCalledTimes(1);
    expect(buildTx).toBeCalledWith(selectionSkeleton);
  });

  it('computeMinimumCoinQuantity', () => {
    const withAssets = ogmiosValueToCslValue(
      {
        coins: 10_000n,
        assets: {
          [TSLA_Asset]: 5000n,
          [PXL_Asset]: 3000n
        }
      },
      csl
    ).multiasset();
    const constraints = defaultSelectionConstraints({
      csl,
      protocolParameters
    } as DefaultSelectionConstraintsProps);
    const minCoinWithAssets = constraints.computeMinimumCoinQuantity(withAssets);
    const minCoinWithoutAssets = constraints.computeMinimumCoinQuantity();
    expect(typeof minCoinWithAssets).toBe('bigint');
    expect(typeof minCoinWithoutAssets).toBe('bigint');
    expect(minCoinWithAssets).toBeGreaterThan(minCoinWithoutAssets);
  });

  describe('computeSelectionLimit', () => {
    const buildTxOfLength = (length: number) => async () => ({ to_bytes: () => ({ length }) } as CSL.Transaction);

    it("doesn't exceed max tx size", async () => {
      const constraints = defaultSelectionConstraints({
        csl,
        protocolParameters,
        buildTx: buildTxOfLength(protocolParameters.maxTxSize)
      });
      expect(await constraints.computeSelectionLimit({ inputs: [1, 2] as any } as SelectionSkeleton)).toEqual(2);
    });

    it('exceeds max tx size', async () => {
      const constraints = defaultSelectionConstraints({
        csl,
        protocolParameters,
        buildTx: buildTxOfLength(protocolParameters.maxTxSize + 1)
      });
      expect(await constraints.computeSelectionLimit({ inputs: [1, 2] as any } as SelectionSkeleton)).toEqual(3);
    });
  });

  describe('tokenBundleSizeExceedsLimit', () => {
    const stubCslWithValueLength = (length: number) =>
      ({
        Value: {
          new: () => ({
            set_multiasset: jest.fn(),
            to_bytes: () => ({ length })
          })
        },
        BigNum: csl.BigNum
      } as any as CardanoSerializationLib);

    it('empty bundle', () => {
      const constraints = defaultSelectionConstraints({
        csl,
        protocolParameters,
        buildTx: jest.fn()
      });
      expect(constraints.tokenBundleSizeExceedsLimit()).toBe(false);
    });

    it("doesn't exceed max value size", () => {
      const constraints = defaultSelectionConstraints({
        csl: stubCslWithValueLength(protocolParameters.maxValueSize),
        protocolParameters
      } as DefaultSelectionConstraintsProps);
      expect(constraints.tokenBundleSizeExceedsLimit({} as any)).toBe(false);
    });

    it('exceeds max value size', () => {
      const constraints = defaultSelectionConstraints({
        csl: stubCslWithValueLength(protocolParameters.maxValueSize + 1),
        protocolParameters
      } as DefaultSelectionConstraintsProps);
      expect(constraints.tokenBundleSizeExceedsLimit({} as any)).toBe(true);
    });
  });
});
