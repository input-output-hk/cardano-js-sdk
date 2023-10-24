import {
  contextWithKnownAddresses,
  knownAddressKeyPath,
  knownAddressStakeKeyPath,
  rewardAddress,
  txIn
} from '../testData';
import { resolvePaymentKeyPathForTxIn, resolveStakeKeyPath } from '../../src';

describe('key-paths', () => {
  describe('resolvePaymentKeyPathForTxIn', () => {
    it('returns the payment key path for a known address', async () => {
      expect(await resolvePaymentKeyPathForTxIn(txIn, contextWithKnownAddresses)).toEqual(knownAddressKeyPath);
    });
  });
  describe('resolveStakeKeyPath', () => {
    it('returns the stake key path for a known address', async () => {
      expect(resolveStakeKeyPath(rewardAddress, contextWithKnownAddresses)).toEqual(knownAddressStakeKeyPath);
    });
  });
});
