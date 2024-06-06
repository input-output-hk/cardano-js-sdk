/* eslint-disable sonarjs/no-duplicate-string */
import { Base64Blob, HexBlob, InvalidStringError, castHexBlob, typedBech32, typedHex } from '../src/index.js';

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

  describe('HexBlob.toTypedBech32', () => {
    it('throw when given an invalid hex', () => {
      expect(() => HexBlob.toTypedBech32('', HexBlob('ffsa'))).toThrow();
    });

    it('returns the correct bech32 string when given a valid prefix and valid payload', () => {
      const bech32 = HexBlob.toTypedBech32('pool', HexBlob('594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e0'));
      expect(bech32).toEqual('pool1t9xlrjyk76c96jltaspgwcnulq6pdkmhnge8xgza8ku7qvpsy9r');
    });
  });

  describe('typedHex', () => {
    it('does not throw when asserting an empty string', () => {
      expect(() => typedHex('')).not.toThrow();
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
    it('allows an empty string', () => {
      expect(() => HexBlob('')).not.toThrow();
    });

    it('does not throw when asserting a valid hex string', () => {
      expect(() => HexBlob('ABCDEF')).not.toThrowError();
      expect(() => HexBlob('1234567890abcdef')).not.toThrowError();
    });

    it('throws when string has an non base16 character', () => {
      expect(() => HexBlob(' 1234567890abcdef')).toThrowError(InvalidStringError);
      expect(() => HexBlob('1234567890abcdefg')).toThrowError(InvalidStringError);
    });

    it('fromBytes converts byte array into HexBlob', () => {
      expect(HexBlob.fromBytes(new Uint8Array([112]))).toEqual('70');
    });

    it('fromBase64 converts a base64 encoded string into HexBlob', () => {
      const base64String = 'o+KixEeK/nzXNPpZPOM/BoQSVWVtwx06z/SIhM6UeNVjFN1rqHKN5BdBOnmKtuh/aF+5F/gwCzl3KPCGMcFuOQ==';
      const expectedHexString =
        'a3e2a2c4478afe7cd734fa593ce33f06841255656dc31d3acff48884ce9478d56314dd6ba8728de417413a798ab6e87f685fb917f8300b397728f08631c16e39';
      const hexString = HexBlob.fromBase64(base64String);
      expect(hexString).toEqual(expectedHexString);
      expect(hexString).toHaveLength(128);
    });
  });

  describe('Base64Blob', () => {
    it('allows an empty string', () => {
      expect(() => Base64Blob('')).not.toThrow();
    });

    it('does not throw when asserting a valid base64 encoded string', () => {
      expect(() => Base64Blob('cA==')).not.toThrowError();
    });

    it('throws when string doesnt match the base64 pattern defined in IETF RFC4648', () => {
      expect(() => HexBlob('cA=')).toThrowError(InvalidStringError);
      expect(() => HexBlob('!cA==')).toThrowError(InvalidStringError);
    });

    it('fromBytes converts byte array into Base64Blob', () => {
      expect(Base64Blob.fromBytes(new Uint8Array([112]))).toEqual('cA==');
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
});
