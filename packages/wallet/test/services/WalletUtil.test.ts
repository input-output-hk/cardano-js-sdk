/* eslint-disable max-len */
import { Cardano } from '@cardano-sdk/core';
import {
  OutputValidator,
  ProtocolParametersRequiredByOutputValidator,
  WalletUtilContext,
  createInputResolver,
  createLazyWalletUtil,
  createOutputValidator
} from '../../src';
import { of } from 'rxjs';

describe('WalletUtil', () => {
  describe('createOutputValidator', () => {
    let validator: OutputValidator;

    beforeAll(() => {
      validator = createOutputValidator({
        protocolParameters$: of<ProtocolParametersRequiredByOutputValidator>({
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
  });

  describe('createInputResolver', () => {
    it('resolveInputAddress resolves inputs from provided utxo set', async () => {
      const utxo: Cardano.Utxo[] = [
        [
          {
            address: Cardano.Address(
              'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
            ),
            index: 0,
            txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
          },
          {
            address: Cardano.Address('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg'),
            value: { coins: 50_000_000n }
          }
        ]
      ];
      const resolver = createInputResolver({ utxo: { available$: of(utxo) } });
      expect(
        await resolver.resolveInputAddress({
          index: 0,
          txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
        })
      ).toBe('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg');
      expect(
        await resolver.resolveInputAddress({
          index: 0,
          txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d4')
        })
      ).toBeNull();
    });
  });

  describe('createLazyWalletUtil', () => {
    it('awaits for "initialize" to be called before resolving call to any util', async () => {
      const util = createLazyWalletUtil();
      const resultPromise = util.validateValue({ coins: 2_000_000n });
      util.initialize({
        protocolParameters$: of<ProtocolParametersRequiredByOutputValidator>({
          coinsPerUtxoByte: 4310,
          maxValueSize: 90
        })
      } as WalletUtilContext);
      const result = await resultPromise;
      expect(result.coinMissing).toBe(0n);
    });
  });
});
