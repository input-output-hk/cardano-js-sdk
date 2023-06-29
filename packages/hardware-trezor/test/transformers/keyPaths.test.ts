import {
  contextWithKnownAddresses,
  knownAddressKeyPath,
  knownAddressStakeKeyPath,
  rewardAddress,
  txIn
} from '../testData';
import {
  paymentKeyPathFromGroupedAddress,
  resolvePaymentKeyPathForTxIn,
  resolveStakeKeyPath,
  stakeKeyPathFromGroupedAddress
} from '../../src';

const address = contextWithKnownAddresses.knownAddresses[0];

describe('key-paths', () => {
  describe('paymentKeyPathFromGroupedAddress', () => {
    it('returns a hardened BIP32 payment key path', () => {
      expect(paymentKeyPathFromGroupedAddress(address)).toEqual(knownAddressKeyPath);
    });
  });
  describe('stakeKeyPathFromGroupedAddress', () => {
    it('returns a hardened BIP32 stake key path', () => {
      expect(stakeKeyPathFromGroupedAddress(address)).toEqual(knownAddressStakeKeyPath);
    });
  });
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
