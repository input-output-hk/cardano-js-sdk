import * as CML from '@dcspark/cardano-multiplatform-lib-nodejs';
import * as Crypto from '../../src';

import { HexBlob } from '@cardano-sdk/util';
import {
  InvalidSignature,
  bip32TestVectorMessageShaOfAbcUnhardened,
  extendedVectors,
  testVectorMessageZeroLength,
  vectors
} from '../Ed25519TestVectors';

/**
 * Test the given Bip32Ed25519 concrete implementation.
 *
 * @param name The name of the implementation.
 * @param bip32Ed25519Factory The factory function to create the Bip32Ed25519 instance.
 */
const testBip32Ed25519 = (name: string, bip32Ed25519Factory: () => Promise<Crypto.Bip32Ed25519>) => {
  let bip32Ed25519: Crypto.Bip32Ed25519;

  beforeAll(async () => {
    bip32Ed25519 = await bip32Ed25519Factory();
  });

  // eslint-disable-next-line sonarjs/cognitive-complexity
  describe(name, () => {
    it('can create the correct BIP-32 key given the right bip39 entropy and password.', async () => {
      expect.assertions(extendedVectors.length);

      for (const vector of extendedVectors) {
        const bip32Key = bip32Ed25519.fromBip39Entropy(Buffer.from(vector.bip39Entropy, 'hex'), vector.password);
        expect(bip32Key).toBe(vector.rootKey);
      }
    });

    it('can derive the correct child BIP-32 private key given a derivation path.', async () => {
      expect.assertions(extendedVectors.length);

      for (const vector of extendedVectors) {
        const rootKey = Crypto.Bip32PrivateKeyHex(vector.rootKey);
        const childKey = bip32Ed25519.derivePrivateKey(rootKey, vector.derivationPath);

        expect(childKey).toBe(vector.childPrivateKey);
      }
    });

    it('can derive the correct child BIP-32 public key given a derivation path.', async () => {
      const rootKey = Crypto.Bip32PublicKeyHex(bip32TestVectorMessageShaOfAbcUnhardened.publicKey);
      const childKey = bip32Ed25519.derivePublicKey(rootKey, bip32TestVectorMessageShaOfAbcUnhardened.derivationPath);

      expect(childKey).toBe(bip32TestVectorMessageShaOfAbcUnhardened.childPublicKey);
    });

    it('can compute the matching BIP-32 public key.', async () => {
      expect.assertions(extendedVectors.length);

      for (const vector of extendedVectors) {
        const rootKey = Crypto.Bip32PrivateKeyHex(vector.rootKey);
        const publicKey = bip32Ed25519.getBip32PublicKey(rootKey);

        expect(publicKey).toBe(vector.publicKey);
      }
    });

    it('can compute the public key from a non extended Ed25519 private key.', async () => {
      expect.assertions(vectors.length);

      for (const vector of vectors) {
        const privateKey = Crypto.Ed25519PrivateNormalKeyHex(vector.secretKey);
        const publicKey = bip32Ed25519.getPublicKey(privateKey);

        expect(publicKey).toBe(vector.publicKey);
      }
    });

    it('can compute the public key from an extended Ed25519 private key.', async () => {
      expect.assertions(extendedVectors.length);

      for (const vector of extendedVectors) {
        const privateKey = Crypto.Ed25519PrivateExtendedKeyHex(vector.ed25519eVector.secretKey);
        const publicKey = bip32Ed25519.getPublicKey(privateKey);

        expect(publicKey).toBe(vector.ed25519eVector.publicKey);
      }
    });

    it('can compute the correct ED25519e raw private key.', async () => {
      expect.assertions(extendedVectors.length);

      for (const vector of extendedVectors) {
        const rootKey = Crypto.Bip32PrivateKeyHex(vector.rootKey);
        const rawKey = bip32Ed25519.getRawPrivateKey(rootKey);

        expect(rawKey).toBe(vector.ed25519eVector.secretKey);
      }
    });

    it('can compute the correct ED25519e raw public key.', async () => {
      expect.assertions(extendedVectors.length);

      for (const vector of extendedVectors) {
        const rootKey = Crypto.Bip32PublicKeyHex(vector.publicKey);
        const rawKey = bip32Ed25519.getRawPublicKey(rootKey);

        expect(rawKey).toBe(vector.ed25519eVector.publicKey);
      }
    });

    it('can compute the correct signature of a message with a non extended Ed25519 private key.', async () => {
      expect.assertions(vectors.length * 2);

      for (const vector of vectors) {
        const privateKey = Crypto.Ed25519PrivateNormalKeyHex(vector.secretKey);
        const publicKey = Crypto.Ed25519PublicKeyHex(vector.publicKey);
        const signature = bip32Ed25519.sign(privateKey, HexBlob(vector.message));

        const isSignatureValid = bip32Ed25519.verify(signature, HexBlob(vector.message), publicKey);
        expect(signature).toBe(vector.signature);
        expect(isSignatureValid).toBeTruthy();
      }
    });

    it('can compute the correct signature of a message with an extended Ed25519 private key.', async () => {
      expect.assertions(extendedVectors.length * 2);

      for (const extendedVector of extendedVectors) {
        const vector = extendedVector.ed25519eVector;
        const privateKey = Crypto.Ed25519PrivateExtendedKeyHex(vector.secretKey);
        const publicKey = Crypto.Ed25519PublicKeyHex(vector.publicKey);
        const signature = bip32Ed25519.sign(privateKey, HexBlob(vector.message));

        const isSignatureValid = bip32Ed25519.verify(signature, HexBlob(vector.message), publicKey);
        expect(signature).toBe(vector.signature);
        expect(isSignatureValid).toBeTruthy();
      }
    });

    it('can compute the right Blake2b hash of an Ed25519 public key', async () => {
      expect.assertions(vectors.length);

      for (const vector of vectors) {
        const publicKey = Crypto.Ed25519PublicKeyHex(vector.publicKey);
        const hash = bip32Ed25519.getPubKeyHash(publicKey);

        expect(hash).toBe(vector.publicKeyHash);
      }
    });

    it('can verify a Ed25519 digital signature given the right public key and original message', async () => {
      expect.assertions(vectors.length);

      for (const vector of vectors) {
        const publicKey = Crypto.Ed25519PublicKeyHex(vector.publicKey);
        const signature = Crypto.Ed25519SignatureHex(vector.signature);

        const isValid = bip32Ed25519.verify(signature, HexBlob(vector.message), publicKey);

        expect(isValid).toBeTruthy();
      }
    });

    it('can not verify a Ed25519 digital invalid signature given a public key and a message', async () => {
      const publicKey = Crypto.Ed25519PublicKeyHex(testVectorMessageZeroLength.publicKey);
      const signature = Crypto.Ed25519SignatureHex(InvalidSignature);

      const isValid = bip32Ed25519.verify(signature, HexBlob(testVectorMessageZeroLength.message), publicKey);

      expect(isValid).toBeFalsy();
    });
  });
};

testBip32Ed25519('CmlBip32Ed25519', () => Promise.resolve(new Crypto.CmlBip32Ed25519(CML)));
testBip32Ed25519('SodiumBip32Ed25519', () => Crypto.SodiumBip32Ed25519.create());
