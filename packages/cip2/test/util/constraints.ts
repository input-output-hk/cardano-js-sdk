import { SelectionConstraints } from '../../src/types';

export interface MockSelectionConstraints {
  minimumCoinQuantity: bigint;
  minimumCost: bigint;
  maxTokenBundleSize: number;
  selectionLimit: number;
}

export const NO_CONSTRAINTS: MockSelectionConstraints = {
  minimumCoinQuantity: 0n,
  maxTokenBundleSize: Number.POSITIVE_INFINITY,
  minimumCost: 0n,
  selectionLimit: Number.POSITIVE_INFINITY
};

export const toConstraints = (constraints: MockSelectionConstraints): SelectionConstraints => ({
  computeMinimumCoinQuantity: () => constraints.minimumCoinQuantity,
  computeMinimumCost: async () => constraints.minimumCost,
  computeSelectionLimit: async () => constraints.selectionLimit,
  tokenBundleSizeExceedsLimit: (multiasset) => multiasset.len() > constraints.maxTokenBundleSize
});
