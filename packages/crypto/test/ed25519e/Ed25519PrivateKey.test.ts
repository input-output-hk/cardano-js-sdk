import * as Crypto from '../../src/index.js';
import { HexBlob, InvalidStringError } from '@cardano-sdk/util';
import {
  bip32TestVectorMessageOneLength,
  extendedVectors,
  testVectorMessageZeroLength,
  vectors
} from './Ed25519TestVectors.js';

describe('Ed25519PrivateKey', () => {
  it('can create an instance from a valid normal Ed25519 private key hex representation', () => {
    const privateKey = Crypto.Ed25519PrivateKey.fromNormalHex(
      Crypto.Ed25519PrivateNormalKeyHex(testVectorMessageZeroLength.secretKey)
    );

    expect(privateKey.hex()).toBe(testVectorMessageZeroLength.secretKey);
  });

  it('can create an instance from a valid extended Ed25519 private key hex representation', () => {
    const privateKey = Crypto.Ed25519PrivateKey.fromExtendedHex(
      Crypto.Ed25519PrivateExtendedKeyHex(bip32TestVectorMessageOneLength.ed25519eVector.secretKey)
    );

    expect(privateKey.hex()).toBe(bip32TestVectorMessageOneLength.ed25519eVector.secretKey);
  });

  it('can create an instance from a valid normal Ed25519 private key raw binary representation', () => {
    const bytes = Buffer.from(testVectorMessageZeroLength.secretKey, 'hex');
    const privateKey = Crypto.Ed25519PrivateKey.fromNormalBytes(bytes);

    expect(privateKey.bytes()).toBe(bytes);
  });

  it('can create an instance from a valid extended Ed25519 private key raw binary representation', () => {
    const bytes = Buffer.from(bip32TestVectorMessageOneLength.ed25519eVector.secretKey, 'hex');
    const privateKey = Crypto.Ed25519PrivateKey.fromExtendedBytes(bytes);

    expect(privateKey.bytes()).toBe(bytes);
  });

  it('throws if a Ed25519 private key of invalid size is given.', () => {
    expect(() => Crypto.Ed25519PrivateKey.fromNormalHex(Crypto.Ed25519PrivateNormalKeyHex('1f'))).toThrow(
      InvalidStringError
    );
    expect(() => Crypto.Ed25519PrivateKey.fromExtendedHex(Crypto.Ed25519PrivateExtendedKeyHex('1f'))).toThrow(
      InvalidStringError
    );
    expect(() =>
      Crypto.Ed25519PrivateKey.fromNormalHex(
        Crypto.Ed25519PrivateNormalKeyHex(`${testVectorMessageZeroLength.secretKey}1f2f3f`)
      )
    ).toThrow(InvalidStringError);
    expect(() =>
      Crypto.Ed25519PrivateKey.fromExtendedHex(
        Crypto.Ed25519PrivateExtendedKeyHex(`${testVectorMessageZeroLength.secretKey}1f2f3f`)
      )
    ).toThrow(InvalidStringError);
  });

  it('can compute the public key from a non extended Ed25519 private key.', async () => {
    expect.assertions(vectors.length);

    for (const vector of vectors) {
      const privateKey = Crypto.Ed25519PrivateKey.fromNormalHex(Crypto.Ed25519PrivateNormalKeyHex(vector.secretKey));
      const publicKey = await privateKey.toPublic();

      expect(publicKey.hex()).toBe(vector.publicKey);
    }
  });

  it('can compute the public key from an extended Ed25519 private key.', async () => {
    expect.assertions(extendedVectors.length);

    for (const vector of extendedVectors) {
      const privateKey = Crypto.Ed25519PrivateKey.fromExtendedHex(
        Crypto.Ed25519PrivateExtendedKeyHex(vector.ed25519eVector.secretKey)
      );
      const publicKey = await privateKey.toPublic();

      expect(publicKey.hex()).toBe(vector.ed25519eVector.publicKey);
    }
  });

  it('can compute the correct signature of a message with a non extended Ed25519 private key.', async () => {
    expect.assertions(vectors.length * 2);

    for (const vector of vectors) {
      const privateKey = Crypto.Ed25519PrivateKey.fromNormalHex(Crypto.Ed25519PrivateNormalKeyHex(vector.secretKey));
      const publicKey = Crypto.Ed25519PublicKey.fromHex(Crypto.Ed25519PublicKeyHex(vector.publicKey));
      const message = HexBlob(vector.message);
      const signature = await privateKey.sign(HexBlob(vector.message));

      const isSignatureValid = await publicKey.verify(signature, message);
      expect(signature.hex()).toBe(vector.signature);
      expect(isSignatureValid).toBeTruthy();
    }
  });

  it('can compute the correct signature of a message with an extended Ed25519 private key.', async () => {
    expect.assertions(extendedVectors.length * 2);

    for (const extendedVector of extendedVectors) {
      const vector = extendedVector.ed25519eVector;
      const privateKey = Crypto.Ed25519PrivateKey.fromExtendedHex(
        Crypto.Ed25519PrivateExtendedKeyHex(vector.secretKey)
      );
      const publicKey = Crypto.Ed25519PublicKey.fromHex(Crypto.Ed25519PublicKeyHex(vector.publicKey));
      const message = HexBlob(vector.message);
      const signature = await privateKey.sign(HexBlob(vector.message));

      const isSignatureValid = await publicKey.verify(signature, message);
      expect(signature.hex()).toBe(vector.signature);
      expect(isSignatureValid).toBeTruthy();
    }
  });
});
