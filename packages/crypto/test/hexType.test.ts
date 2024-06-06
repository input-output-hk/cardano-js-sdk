import * as Crypto from '../src/index.js';
import { HexBlob, InvalidStringError } from '@cardano-sdk/util';

describe('HexTypes', () => {
  it('Ed25519PublicKeyHex() accepts a valid public key hex string', () => {
    expect(() =>
      Crypto.Ed25519PublicKeyHex('6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39')
    ).not.toThrow();
  });

  it('Ed25519PrivateExtendedKeyHex() accepts a valid private key hex string', () => {
    expect(() =>
      Crypto.Ed25519PrivateExtendedKeyHex(
        '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d396199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39'
      )
    ).not.toThrow();
  });

  it('Ed25519PrivateNormaKeyHex() accepts a valid private key hex string', () => {
    expect(() =>
      Crypto.Ed25519PrivateNormalKeyHex('6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39')
    ).not.toThrow();
  });

  describe('Ed25519KeyHashHex', () => {
    it('accepts a key hash hex string', () => {
      expect(() => Crypto.Ed25519KeyHashHex('6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed5')).not.toThrow();
    });
  });

  it('Bip32PublicKeyHex() accepts a valid public key hex string', () => {
    expect(() =>
      Crypto.Bip32PublicKeyHex(
        '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d396199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39'
      )
    ).not.toThrow();
  });

  it('Bip32PublicKeyHashHex() accepts a valid public key hash hex string', () => {
    expect(() =>
      Crypto.Bip32PublicKeyHashHex('6199186adb51974690d7247d2646097d2c62763b767b528816fb7edc')
    ).not.toThrow();
  });

  it('Bip32PrivateKeyHex() accepts a valid public key hex string', () => {
    expect(() =>
      Crypto.Bip32PrivateKeyHex(
        '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d36199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d3996199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39'
      )
    ).not.toThrow();
  });

  describe('Hash32ByteBase16', () => {
    it('expects a hex string with length of 64', () => {
      expect(() =>
        Crypto.Hash32ByteBase16('3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d')
      ).not.toThrow();
      expect(() =>
        Crypto.Hash32ByteBase16.fromHexBlob(HexBlob('3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d'))
      ).not.toThrow();
    });

    it('throws with non-hex string', () => {
      expect(() =>
        Crypto.Hash32ByteBase16('ge33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d')
      ).toThrowError(InvalidStringError);
      expect(() =>
        Crypto.Hash32ByteBase16.fromHexBlob(HexBlob('ge33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d'))
      ).toThrowError(InvalidStringError);
    });

    it('throws with hex string of different length', () => {
      expect(() =>
        Crypto.Hash32ByteBase16('e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d')
      ).toThrowError(InvalidStringError);
      expect(() =>
        Crypto.Hash32ByteBase16.fromHexBlob(HexBlob('e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d'))
      ).toThrowError(InvalidStringError);
    });
  });

  describe('Hash28ByteBase16', () => {
    it('expects a hex string with length of 64', () => {
      expect(() => Crypto.Hash28ByteBase16('8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d')).not.toThrow();
    });

    it('throws with non-hex string', () => {
      expect(() => Crypto.Hash28ByteBase16('g293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d')).toThrowError(
        InvalidStringError
      );
    });

    it('throws with hex string of different length', () => {
      expect(() => Crypto.Hash28ByteBase16('293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d')).toThrowError(
        InvalidStringError
      );
    });
  });
});
