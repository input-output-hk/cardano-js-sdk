import {
  contextWithKnownAddresses,
  knownAddress,
  knownAddressKeyPath,
  knownAddressStakeKeyPath,
  rewardAddress,
  txIn
} from '../testData';
import { resolvePaymentKeyPathForTxIn, resolveStakeKeyPath, stakeKeyPathFromGroupedAddress } from '../../src';

const address = contextWithKnownAddresses.knownAddresses[0];

describe('key-paths', () => {
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
