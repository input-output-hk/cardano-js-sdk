/* eslint-disable @typescript-eslint/no-explicit-any */
import { mockConstraintsToConstraints } from '../src/selectionConstraints';

describe('selectionConstraints', () => {
  it('mockConstraintsToConstraints ', async () => {
    const constraints = mockConstraintsToConstraints({
      maxTokenBundleSize: 1,
      minimumCoinQuantity: 10n,
      minimumCostCoefficient: 20n,
      selectionLimit: 3
    });
    expect(constraints.computeMinimumCoinQuantity()).toBe(10n);
    expect(await constraints.computeMinimumCost({ inputs: new Set([[]]) } as any)).toBe(20n);
    expect(await constraints.computeMinimumCost({ inputs: new Set([[], []]) } as any)).toBe(40n);
    expect(await constraints.computeSelectionLimit({} as any)).toBe(3);
    expect(constraints.tokenBundleSizeExceedsLimit()).toBe(false);
    expect(constraints.tokenBundleSizeExceedsLimit({ size: 2 } as any)).toBe(true);
  });
});
