import * as Crypto from '../../src';
import { InvalidStringError } from '@cardano-sdk/util';
import { bip32TestVectorMessageOneLength, extendedVectors } from '../ed25519e/Ed25519TestVectors';

describe('Bip32PrivateKey', () => {
  it('can create an instance from a valid normal BIP-32 private key hex representation', async () => {
    const privateKey = Crypto.Bip32PrivateKey.fromHex(
      Crypto.Bip32PrivateKeyHex(bip32TestVectorMessageOneLength.rootKey)
    );
    expect(privateKey.hex()).toBe(bip32TestVectorMessageOneLength.rootKey);
  });

  it('can create an instance from a valid normal BIP-32 private key raw binary representation', () => {
    const bytes = Buffer.from(bip32TestVectorMessageOneLength.rootKey, 'hex');
    const privateKey = Crypto.Bip32PrivateKey.fromBytes(bytes);

    expect(privateKey.bytes()).toBe(bytes);
  });

  it('throws if a BIP-32 private key of invalid size is given.', () => {
    expect(() => Crypto.Bip32PrivateKey.fromHex(Crypto.Bip32PrivateKeyHex('1f'))).toThrow(InvalidStringError);
    expect(() =>
      Crypto.Bip32PrivateKey.fromHex(Crypto.Bip32PrivateKeyHex(`${bip32TestVectorMessageOneLength.rootKey}1f2f3f`))
    ).toThrow(InvalidStringError);
  });

  it('can create the correct BIP-32 key given the right bip39 entropy and password.', async () => {
    expect.assertions(extendedVectors.length);

    for (const vector of extendedVectors) {
      const bip32Key = Crypto.Bip32PrivateKey.fromBip39Entropy(
        Buffer.from(vector.bip39Entropy, 'hex'),
        vector.password
      );

      expect(bip32Key.hex()).toBe(vector.rootKey);
    }
  });

  it('can derive the correct child BIP-32 private key given a derivation path.', async () => {
    expect.assertions(extendedVectors.length);

    for (const vector of extendedVectors) {
      const rootKey = await Crypto.Bip32PrivateKey.fromHex(Crypto.Bip32PrivateKeyHex(vector.rootKey));
      const childKey = await rootKey.derive(vector.derivationPath);

      expect(childKey.hex()).toBe(vector.childPrivateKey);
    }
  });

  it('can compute the matching BIP-32 public key.', async () => {
    expect.assertions(extendedVectors.length);

    for (const vector of extendedVectors) {
      const rootKey = await Crypto.Bip32PrivateKey.fromHex(Crypto.Bip32PrivateKeyHex(vector.rootKey));
      const publicKey = await rootKey.toPublic();

      expect(publicKey.hex()).toBe(vector.publicKey);
    }
  });

  it('can compute the correct ED25519e raw private key.', async () => {
    expect.assertions(extendedVectors.length);

    for (const vector of extendedVectors) {
      const rootKey = await Crypto.Bip32PrivateKey.fromHex(Crypto.Bip32PrivateKeyHex(vector.rootKey));
      const rawKey = await rootKey.toRawKey();

      expect(rawKey.hex()).toBe(vector.ed25519eVector.secretKey);
    }
  });
});
