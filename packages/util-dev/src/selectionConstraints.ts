import { CSL } from '@cardano-sdk/core';
import { SelectionConstraints } from '@cardano-sdk/cip2';

export interface MockSelectionConstraints {
  minimumCoinQuantity: bigint;
  minimumCost: bigint;
  maxTokenBundleSize: number;
  selectionLimit: number;
}

export const MOCK_NO_CONSTRAINTS: MockSelectionConstraints = {
  maxTokenBundleSize: Number.POSITIVE_INFINITY,
  minimumCoinQuantity: 0n,
  minimumCost: 0n,
  selectionLimit: Number.POSITIVE_INFINITY
};

export const mockConstraintsToConstraints = (constraints: MockSelectionConstraints): SelectionConstraints => ({
  computeMinimumCoinQuantity: () => constraints.minimumCoinQuantity,
  computeMinimumCost: async () => constraints.minimumCost,
  computeSelectionLimit: async () => constraints.selectionLimit,
  tokenBundleSizeExceedsLimit: (multiasset?: CSL.MultiAsset) =>
    (multiasset?.len() || 0) > constraints.maxTokenBundleSize
});

export const NO_CONSTRAINTS = mockConstraintsToConstraints(MOCK_NO_CONSTRAINTS);
