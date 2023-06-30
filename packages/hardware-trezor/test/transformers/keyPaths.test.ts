import {
  contextWithKnownAddresses,
  knownAddress,
  knownAddressKeyPath,
  knownAddressStakeKeyPath,
  txIn
} from '../testData';
import {
  paymentKeyPathFromGroupedAddress,
  resolvePaymentKeyPathForTxIn,
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
    it('returns null when given an undefined stakeKeyDerivationPath', async () => {
      const knownAddressClone = { ...knownAddress };
      delete knownAddressClone.stakeKeyDerivationPath;
      expect(stakeKeyPathFromGroupedAddress(knownAddressClone)).toEqual(null);
    });
    it('returns a hardened BIP32 stake key path', () => {
      expect(stakeKeyPathFromGroupedAddress(address)).toEqual(knownAddressStakeKeyPath);
    });
  });
  describe('resolveKeyPath', () => {
    it('returns the BIP32Path for a known address', async () => {
      expect(await resolvePaymentKeyPathForTxIn(txIn, contextWithKnownAddresses)).toEqual(knownAddressKeyPath);
    });
  });
});
