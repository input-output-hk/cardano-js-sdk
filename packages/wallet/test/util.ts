import { SelectionConstraints } from '@cardano-sdk/cip2';

export const NO_CONSTRAINTS: SelectionConstraints = {
  computeMinimumCoinQuantity: () => 1_000_000n,
  computeMinimumCost: async () => 170_000n,
  computeSelectionLimit: async () => 5,
  tokenBundleSizeExceedsLimit: () => false
};
