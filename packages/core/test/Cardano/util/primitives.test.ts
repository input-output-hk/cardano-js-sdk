/* eslint-disable sonarjs/no-duplicate-string */
import {
  Hash28ByteBase16,
  Hash32ByteBase16,
  HexBlob,
  castHexBlob,
  typedBech32,
  typedHex
} from '../../../src/Cardano/util';
import { InvalidStringError } from '../../../src/errors';

describe('Cardano.util/primitives', () => {
  describe('typedBech32', () => {
    it('does not throw when asserting a valid bech32', () => {
      expect(() => typedBech32('pool1ujcu3myfg9wwvdyh2ks653954lamtufy3lefjs73jrr327q53j4', 'pool')).not.toThrow();
      expect(() =>
        typedBech32('pool1ujcu3myfg9wwvdyh2ks653954lamtufy3lefjs73jrr327q53j4', ['pool', 'pool_vk'])
      ).not.toThrow();
      expect(() => typedBech32('pool1ujcu3myfg9wwvdyh2ks653954lamtufy3lefjs73jrr327q53j4', 'pool', 45)).not.toThrow();
      expect(() =>
        typedBech32('pool1ujcu3myfg9wwvdyh2ks653954lamtufy3lefjs73jrr327q53j4', 'pool', [45, 55])
      ).not.toThrow();
    });

    it('throws when decoded words length does not match the last argument', () => {
      expect(() => typedBech32('pool1ujcu3myfg9wwvdyh2ks653954lamtufy3lefjs73jrr327q53j4', 'pool', 55)).toThrowError(
        InvalidStringError
      );
      expect(() =>
        typedBech32('pool1ujcu3myfg9wwvdyh2ks653954lamtufy3lefjs73jrr327q53j4', 'pool', [55, 56])
      ).toThrowError(InvalidStringError);
    });

    it('throws when asserting an invalid bech32 (too short)', () => {
      expect(() => typedBech32('pool1', 'pool')).toThrowError(InvalidStringError);
    });

    it('throws when asserting an empty string', () => {
      expect(() => typedBech32('', '')).toThrowError(InvalidStringError);
    });

    it('throws when decoded prefix does not match the expected prefix', () => {
      expect(() =>
        typedBech32(
          // eslint-disable-next-line max-len
          'addr_test1qrydm8hsalwjmuqj624cwnyrs554zu6a8n8wg64dxk3zarsxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknsq3qxgd',
          'pool'
        )
      ).toThrowError(InvalidStringError);
    });
  });

  describe('typedHex', () => {
    it('throws when asserting an empty string', () => {
      expect(() => typedHex('')).toThrowError(InvalidStringError);
    });

    it('does not throw when asserting a valid hex string', () => {
      expect(() => typedHex('ABCDEF')).not.toThrowError();
      expect(() => typedHex('ABCDEF', 6)).not.toThrowError();
      expect(() => typedHex('1234567890abcdef')).not.toThrowError();
    });

    it('throws when string length does not match the expected length', () => {
      expect(() => typedHex('ABCDEF', 5)).toThrowError(InvalidStringError);
    });

    it('throws when string has an non base16 character', () => {
      expect(() => typedHex(' 1234567890abcdef')).toThrowError(InvalidStringError);
      expect(() => typedHex('1234567890abcdefg')).toThrowError(InvalidStringError);
    });
  });

  describe('HexBlob', () => {
    it('throws when asserting an empty string', () => {
      expect(() => HexBlob('')).toThrowError(InvalidStringError);
    });

    it('does not throw when asserting a valid hex string', () => {
      expect(() => HexBlob('ABCDEF')).not.toThrowError();
      expect(() => HexBlob('1234567890abcdef')).not.toThrowError();
    });

    it('throws when string has an non base16 character', () => {
      expect(() => HexBlob(' 1234567890abcdef')).toThrowError(InvalidStringError);
      expect(() => HexBlob('1234567890abcdefg')).toThrowError(InvalidStringError);
    });
  });

  describe('castHexBlob', () => {
    it('returns the same string', () => {
      expect(castHexBlob(HexBlob('abc123'))).toEqual('abc123');
    });

    it('does not throw when string length matches expectedLength', () => {
      expect(() => castHexBlob(HexBlob('ABCDEF'), 6)).not.toThrowError();
    });

    it('throws when string length does not match expectedLength', () => {
      expect(() => castHexBlob(HexBlob('ABCDEF'), 5)).toThrowError(InvalidStringError);
    });
  });

  describe('Hash32ByteBase16', () => {
    it('expects a hex string with length of 64', () => {
      expect(() => Hash32ByteBase16('3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d')).not.toThrow();
      expect(() =>
        Hash32ByteBase16.fromHexBlob(HexBlob('3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d'))
      ).not.toThrow();
    });

    it('throws with non-hex string', () => {
      expect(() => Hash32ByteBase16('ge33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d')).toThrowError(
        InvalidStringError
      );
      expect(() =>
        Hash32ByteBase16.fromHexBlob(HexBlob('ge33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d'))
      ).toThrowError(InvalidStringError);
    });

    it('throws with hex string of different length', () => {
      expect(() => Hash32ByteBase16('e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d')).toThrowError(
        InvalidStringError
      );
      expect(() =>
        Hash32ByteBase16.fromHexBlob(HexBlob('e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d'))
      ).toThrowError(InvalidStringError);
    });
  });

  describe('Hash28ByteBase16', () => {
    it('expects a hex string with length of 64', () => {
      expect(() => Hash28ByteBase16('8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d')).not.toThrow();
    });

    it('throws with non-hex string', () => {
      expect(() => Hash28ByteBase16('g293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d')).toThrowError(
        InvalidStringError
      );
    });

    it('throws with hex string of different length', () => {
      expect(() => Hash28ByteBase16('293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d')).toThrowError(
        InvalidStringError
      );
    });
  });
});
