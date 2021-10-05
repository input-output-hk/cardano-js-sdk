/* eslint-disable @typescript-eslint/no-explicit-any */
import { mockConstraintsToConstraints } from '../src/selectionConstraints';

describe('selectionConstraints', () => {
  it('mockConstraintsToConstraints ', async () => {
    const constraints = mockConstraintsToConstraints({
      maxTokenBundleSize: 1,
      minimumCoinQuantity: 10n,
      minimumCost: 20n,
      selectionLimit: 3
    });
    expect(constraints.computeMinimumCoinQuantity()).toBe(10n);
    expect(await constraints.computeMinimumCost({} as any)).toBe(20n);
    expect(await constraints.computeSelectionLimit({} as any)).toBe(3);
    expect(await constraints.tokenBundleSizeExceedsLimit()).toBe(false);
    expect(await constraints.tokenBundleSizeExceedsLimit({ len: () => 2 } as any)).toBe(true);
  });
});
