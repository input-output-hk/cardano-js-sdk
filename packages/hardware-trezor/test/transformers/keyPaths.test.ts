import { CONTEXT_WITH_KNOWN_ADDRESSES, knownAddressKeyPath, txIn } from '../testData';
import { paymentKeyPathFromGroupedAddress, resolvePaymentKeyPathForTxIn } from '../../src';

const address = CONTEXT_WITH_KNOWN_ADDRESSES.knownAddresses[0];

describe('key-paths', () => {
  describe('paymentKeyPathFromGroupedAddress', () => {
    it('returns a hardened BIP32 payment key path', () => {
      expect(paymentKeyPathFromGroupedAddress(address)).toEqual(knownAddressKeyPath);
    });
  });
  describe('resolveKeyPath', () => {
    it('returns the BIP32Path for a known address', async () => {
      expect(await resolvePaymentKeyPathForTxIn(txIn, CONTEXT_WITH_KNOWN_ADDRESSES)).toEqual(knownAddressKeyPath);
    });
  });
});
