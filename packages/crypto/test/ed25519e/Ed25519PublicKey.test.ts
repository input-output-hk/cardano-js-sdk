import * as Crypto from '../../src/index.js';
import { HexBlob, InvalidStringError } from '@cardano-sdk/util';
import { InvalidSignature, testVectorMessageZeroLength, vectors } from './Ed25519TestVectors.js';

describe('Ed25519PublicKey', () => {
  it('can create an instance from a valid Ed25519 public key hex representation', () => {
    const publicKey = Crypto.Ed25519PublicKey.fromHex(
      Crypto.Ed25519PublicKeyHex(testVectorMessageZeroLength.publicKey)
    );

    expect(publicKey.hex()).toBe(testVectorMessageZeroLength.publicKey);
  });

  it('can create an instance from a valid Ed25519 public key raw binary representation', () => {
    const sigBytes = Buffer.from(testVectorMessageZeroLength.publicKey, 'hex');
    const publicKey = Crypto.Ed25519PublicKey.fromBytes(sigBytes);

    expect(publicKey.bytes()).toBe(sigBytes);
  });

  it('throws if a Ed25519 public key of invalid size is given.', () => {
    expect(() => Crypto.Ed25519PublicKey.fromHex(Crypto.Ed25519PublicKeyHex('1f'))).toThrow(InvalidStringError);
    expect(() =>
      Crypto.Ed25519PublicKey.fromHex(Crypto.Ed25519PublicKeyHex(`${testVectorMessageZeroLength.publicKey}1f2f3f`))
    ).toThrow(InvalidStringError);
  });

  it('can compute the right Blake2b hash of an Ed25519 public key', async () => {
    expect.assertions(vectors.length);

    for (const vector of vectors) {
      const publicKey = Crypto.Ed25519PublicKey.fromHex(Crypto.Ed25519PublicKeyHex(vector.publicKey));
      const hash = (await publicKey.hash()).hex();

      expect(hash).toBe(vector.publicKeyHash);
    }
  });

  it('can verify a Ed25519 digital signature given the right public key and original message', async () => {
    expect.assertions(vectors.length);

    for (const vector of vectors) {
      const publicKey = Crypto.Ed25519PublicKey.fromHex(Crypto.Ed25519PublicKeyHex(vector.publicKey));
      const signature = Crypto.Ed25519Signature.fromHex(Crypto.Ed25519SignatureHex(vector.signature));
      const message = HexBlob(vector.message);

      const isValid = await publicKey.verify(signature, message);

      expect(isValid).toBeTruthy();
    }
  });

  it('can not verify a Ed25519 digital invalid signature given a public key and a message', async () => {
    const publicKey = Crypto.Ed25519PublicKey.fromHex(
      Crypto.Ed25519PublicKeyHex(testVectorMessageZeroLength.publicKey)
    );
    const signature = Crypto.Ed25519Signature.fromHex(Crypto.Ed25519SignatureHex(InvalidSignature));
    const message = HexBlob(testVectorMessageZeroLength.message);

    const isValid = await publicKey.verify(signature, message);

    expect(isValid).toBeFalsy();
  });
});
