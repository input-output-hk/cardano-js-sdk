import { Cardano } from '@cardano-sdk/core';

import { createOutputValidator } from '../../src/index.js';
import type { OutputValidator } from '../../src/index.js';

describe('createOutputValidator', () => {
  let validator: OutputValidator;

  beforeAll(() => {
    validator = createOutputValidator({
      protocolParameters: async () => ({
        coinsPerUtxoByte: 4310,
        maxValueSize: 90
      })
    });
  });

  it('validateValue validates minimum coin quantity', async () => {
    expect((await validator.validateValue({ coins: 2_000_000n })).coinMissing).toBe(0n);
    expect((await validator.validateValue({ coins: 500_000n })).coinMissing).toBeGreaterThan(0n);
  });

  it('validateValue validates bundle size', async () => {
    expect(
      (
        await validator.validateValue({
          assets: new Map([
            [Cardano.AssetId('b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 1n]
          ]),
          coins: 2_000_000n
        })
      ).tokenBundleSizeExceedsLimit
    ).toBe(false);
    expect(
      (
        await validator.validateValue({
          assets: new Map([
            [Cardano.AssetId('b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 1n],
            [Cardano.AssetId('c01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 2n]
          ]),
          coins: 2_000_000n
        })
      ).tokenBundleSizeExceedsLimit
    ).toBe(true);
  });

  it('validateValue validates negative asset quantity', async () => {
    expect(
      (
        await validator.validateValue({
          assets: new Map([
            [Cardano.AssetId('b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 1n]
          ]),
          coins: 2_000_000n
        })
      ).negativeAssetQty
    ).toBe(false);
    expect(
      (
        await validator.validateValue({
          assets: new Map([
            [Cardano.AssetId('b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 1n],
            [Cardano.AssetId('c01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), -2n]
          ]),
          coins: 2_000_000n
        })
      ).negativeAssetQty
    ).toBe(true);
    expect(
      (
        await validator.validateValue({
          assets: new Map([
            [Cardano.AssetId('b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 1n],
            [Cardano.AssetId('c01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 0n]
          ]),
          coins: 2_000_000n
        })
      ).negativeAssetQty
    ).toBe(true);
  });
});
