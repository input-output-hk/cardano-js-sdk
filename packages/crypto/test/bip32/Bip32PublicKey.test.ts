import * as Crypto from '../../src/index.js';
import { InvalidStringError } from '@cardano-sdk/util';
import {
  bip32TestVectorMessageOneLength,
  bip32TestVectorMessageShaOfAbcUnhardened,
  extendedVectors
} from '../ed25519e/Ed25519TestVectors.js';

describe('Bip32PublicKey', () => {
  it('can create an instance from a valid normal BIP-32 public key hex representation', async () => {
    const publicKey = Crypto.Bip32PublicKey.fromHex(
      Crypto.Bip32PublicKeyHex(bip32TestVectorMessageOneLength.publicKey)
    );
    expect(publicKey.hex()).toBe(bip32TestVectorMessageOneLength.publicKey);
  });

  it('can create an instance from a valid normal BIP-32 public key raw binary representation', () => {
    const bytes = Buffer.from(bip32TestVectorMessageOneLength.publicKey, 'hex');
    const publicKey = Crypto.Bip32PublicKey.fromBytes(bytes);

    expect(publicKey.bytes()).toBe(bytes);
  });

  it('throws if a BIP-32 public key of invalid size is given.', () => {
    expect(() => Crypto.Bip32PublicKey.fromHex(Crypto.Bip32PublicKeyHex('1f'))).toThrow(InvalidStringError);
    expect(() =>
      Crypto.Bip32PublicKey.fromHex(Crypto.Bip32PublicKeyHex(`${bip32TestVectorMessageOneLength.publicKey}1f2f3f`))
    ).toThrow(InvalidStringError);
  });

  it('can derive the correct child BIP-32 public key given a derivation path.', async () => {
    const rootKey = await Crypto.Bip32PublicKey.fromHex(
      Crypto.Bip32PublicKeyHex(bip32TestVectorMessageShaOfAbcUnhardened.publicKey)
    );
    const childKey = await rootKey.derive(bip32TestVectorMessageShaOfAbcUnhardened.derivationPath);

    expect(childKey.hex()).toBe(bip32TestVectorMessageShaOfAbcUnhardened.childPublicKey);
  });

  it('can compute the correct ED25519e raw public key.', async () => {
    expect.assertions(extendedVectors.length);

    for (const vector of extendedVectors) {
      const rootKey = await Crypto.Bip32PublicKey.fromHex(Crypto.Bip32PublicKeyHex(vector.publicKey));
      const rawKey = await rootKey.toRawKey();

      expect(rawKey.hex()).toBe(vector.ed25519eVector.publicKey);
    }
  });

  it('can compute Blake2b hash of a bip32 public key', async () => {
    const publicKey = Crypto.Bip32PublicKey.fromHex(Crypto.Bip32PublicKeyHex(extendedVectors[0].publicKey));
    const hash = await publicKey.hash();
    expect(typeof hash).toBe('string');
  });
});
