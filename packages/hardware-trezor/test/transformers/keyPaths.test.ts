import {
  CONTEXT_WITH_KNOWN_ADDRESSES,
  knownAddress,
  knownAddressKeyPath,
  knownAddressStakingKeyPath,
  txIn
} from '../testData';
import { CardanoKeyConst } from '@cardano-sdk/key-management';
import {
  bip32PathToStrPath,
  paymentKeyPathFromGroupedAddress,
  resolvePaymentKeyPathForTxIn,
  stakingKeyPathFromGroupedAddress
} from '../../src';

const address = CONTEXT_WITH_KNOWN_ADDRESSES.knownAddresses[0];

describe('key-paths', () => {
  describe('paymentKeyPathFromGroupedAddress', () => {
    it('returns a hardened BIP32 payment key path', () => {
      expect(paymentKeyPathFromGroupedAddress(address)).toEqual(knownAddressKeyPath);
    });
  });
  describe('stakingKeyPathFromGroupedAddress', () => {
    it('returns null when given an undefined stakeKeyDerivationPath', async () => {
      const knownAddressClone = { ...knownAddress };
      delete knownAddressClone.stakeKeyDerivationPath;
      expect(stakingKeyPathFromGroupedAddress(knownAddressClone)).toEqual(null);
    });
    it('returns a hardened BIP32 payment key path', () => {
      expect(stakingKeyPathFromGroupedAddress(address)).toEqual(knownAddressStakingKeyPath);
    });
  });
  describe('bip32PathToStrPath', () => {
    it('can stringify payment key path', () => {
      expect(bip32PathToStrPath(knownAddressKeyPath)).toEqual(
        `m/${CardanoKeyConst.PURPOSE}'/${CardanoKeyConst.COIN_TYPE}'/${knownAddress.accountIndex}'/${knownAddress.type}/${knownAddress.index}`
      );
    });
    it('can stringify staking key path', () => {
      expect(bip32PathToStrPath(knownAddressStakingKeyPath)).toEqual(
        `m/${CardanoKeyConst.PURPOSE}'/${CardanoKeyConst.COIN_TYPE}'/${knownAddress.accountIndex}'/${knownAddress.stakeKeyDerivationPath?.role}/${knownAddress.stakeKeyDerivationPath?.index}`
      );
    });
  });
  describe('resolveKeyPath', () => {
    it('returns the BIP32Path for a known address', async () => {
      expect(await resolvePaymentKeyPathForTxIn(txIn, CONTEXT_WITH_KNOWN_ADDRESSES)).toEqual(knownAddressKeyPath);
    });
  });
});
