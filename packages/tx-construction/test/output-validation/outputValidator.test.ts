import { Cardano } from '@cardano-sdk/core';

import { OutputValidator, createOutputValidator } from '../../src';

describe('createOutputValidator', () => {
  const address = Cardano.PaymentAddress(
    'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9'
  );
  let validator: OutputValidator;

  beforeAll(() => {
    validator = createOutputValidator({
      protocolParameters: async () => ({
        coinsPerUtxoByte: 4310,
        maxValueSize: 90
      })
    });
  });

  describe('validateOutput', () => {
    it('validates minimum coin quantity', async () => {
      expect((await validator.validateOutput({ address, value: { coins: 2_000_000n } })).coinMissing).toBe(0n);
      expect((await validator.validateOutput({ address, value: { coins: 500_000n } })).coinMissing).toBeGreaterThan(0n);
    });

    it('validates bundle size', async () => {
      expect(
        (
          await validator.validateOutput({
            address,
            value: {
              assets: new Map([
                [Cardano.AssetId('b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 1n]
              ]),
              coins: 2_000_000n
            }
          })
        ).tokenBundleSizeExceedsLimit
      ).toBe(false);
      expect(
        (
          await validator.validateOutput({
            address,
            value: {
              assets: new Map([
                [Cardano.AssetId('b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 1n],
                [Cardano.AssetId('c01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 2n]
              ]),
              coins: 2_000_000n
            }
          })
        ).tokenBundleSizeExceedsLimit
      ).toBe(true);
    });

    it('validates negative asset quantity', async () => {
      expect(
        (
          await validator.validateOutput({
            address,
            value: {
              assets: new Map([
                [Cardano.AssetId('b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 1n]
              ]),
              coins: 2_000_000n
            }
          })
        ).negativeAssetQty
      ).toBe(false);
      expect(
        (
          await validator.validateOutput({
            address,
            value: {
              assets: new Map([
                [Cardano.AssetId('b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 1n],
                [Cardano.AssetId('c01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), -2n]
              ]),
              coins: 2_000_000n
            }
          })
        ).negativeAssetQty
      ).toBe(true);
      expect(
        (
          await validator.validateOutput({
            address,
            value: {
              assets: new Map([
                [Cardano.AssetId('b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 1n],
                [Cardano.AssetId('c01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 0n]
              ]),
              coins: 2_000_000n
            }
          })
        ).negativeAssetQty
      ).toBe(true);
    });

    it('uses output address size as minimum coin computation parameter', async () => {
      const value: Cardano.Value = { coins: 123n };
      const { minimumCoin: byronAddressMinimumCoin } = await validator.validateOutput({
        address: Cardano.PaymentAddress(
          'DdzFFzCqrht4PWfBGtmrQz4x1GkZHYLVGbK7aaBkjWxujxzz3L5GxCgPiTsks5RjUr3yX9KvwKjNJBt7ZzPCmS3fUQrGeRvo9Y1YBQKQ'
        ),
        value
      });
      const { minimumCoin: shelleyAddressMinimumCoin } = await validator.validateOutput({
        address: Cardano.PaymentAddress(
          'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9'
        ),
        value
      });
      expect(byronAddressMinimumCoin).toBeGreaterThan(shelleyAddressMinimumCoin);
    });
  });
});
