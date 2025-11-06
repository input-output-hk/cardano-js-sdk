import * as cip19TestVectors from '../../../../util-dev/src/Cip19TestVectors';
import { Cardano } from '../../../src';
import { typedBech32 } from '@cardano-sdk/util';

jest.mock('@cardano-sdk/util', () => {
  const actual = jest.requireActual('@cardano-sdk/util');
  return {
    ...actual,
    typedBech32: jest.fn().mockImplementation((...args) => actual.typedBech32(...args))
  };
});

describe('Cardano/Address/PaymentCredential', () => {
  const validAddrVkh = 'addr_vkh1an33fpxnkj09r8upnlw55a59kcysk8u3jcm00rfu44dk75ut34v';
  const validScript = 'script1cda3khwqv60360rp5m7akt50m6ttapacs8rqhn5w342z7r35m37';

  describe('PaymentCredential()', () => {
    it('accepts a valid addr_vkh bech32 for key hash credential', () => {
      expect(() => Cardano.PaymentCredential(validAddrVkh)).not.toThrow();
    });

    it('accepts a valid script bech32 for script hash credential', () => {
      expect(() => Cardano.PaymentCredential(validScript)).not.toThrow();
    });

    it('is implemented using util.typedBech32 for addr_vkh', () => {
      Cardano.PaymentCredential(validAddrVkh);
      expect(typedBech32).toHaveBeenCalledWith(validAddrVkh, ['addr_vkh'], 45);
    });

    it('throws on invalid bech32 prefix (stake address)', () => {
      expect(() => Cardano.PaymentCredential('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr')).toThrow();
    });
  });

  describe('fromCredential', () => {
    it('converts key hash credential to addr_vkh bech32', () => {
      const paymentCredential = Cardano.PaymentCredential.fromCredential(cip19TestVectors.KEY_PAYMENT_CREDENTIAL);
      expect(paymentCredential).toMatch(/^addr_vkh1/);
      // Verify it can be parsed back
      expect(() => Cardano.PaymentCredential(paymentCredential)).not.toThrow();
    });

    it('converts script hash credential to script bech32', () => {
      const paymentCredential = Cardano.PaymentCredential.fromCredential(cip19TestVectors.SCRIPT_CREDENTIAL);
      expect(paymentCredential).toMatch(/^script1/);
      // Verify it can be parsed back
      expect(() => Cardano.PaymentCredential(paymentCredential)).not.toThrow();
    });

    it('produces valid bech32 with correct length', () => {
      const keyHashCredential = Cardano.PaymentCredential.fromCredential(cip19TestVectors.KEY_PAYMENT_CREDENTIAL);
      const scriptHashCredential = Cardano.PaymentCredential.fromCredential(cip19TestVectors.SCRIPT_CREDENTIAL);

      // Both should be 56+ characters (prefix + separator + encoded data + checksum)
      expect(keyHashCredential.length).toBeGreaterThan(56);
      expect(scriptHashCredential.length).toBeGreaterThan(56);
    });

    it('is consistent - same credential produces same bech32', () => {
      const cred1 = Cardano.PaymentCredential.fromCredential(cip19TestVectors.KEY_PAYMENT_CREDENTIAL);
      const cred2 = Cardano.PaymentCredential.fromCredential(cip19TestVectors.KEY_PAYMENT_CREDENTIAL);
      expect(cred1).toBe(cred2);
    });
  });
});
