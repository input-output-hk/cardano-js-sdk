import { ImageMediaType, MediaType, Uri } from '../../../src/Asset';
import { InvalidStringError } from '@cardano-sdk/util';

describe('NftMetadata/types', () => {
  describe('Uri', () => {
    it('accepts a string starting with protocol://', () => {
      expect(() => Uri('http://some.url')).not.toThrow();
      expect(() => Uri('ipfs://abc123')).not.toThrow();
    });
    it('accepts a common ipfs hash without protocol://', () => {
      expect(Uri('QmcDAmZubQig7tGUgEwbWcgdvz4Aoa2EiRZyFoX3fXTVmr')).toBe(
        'ipfs://QmcDAmZubQig7tGUgEwbWcgdvz4Aoa2EiRZyFoX3fXTVmr'
      );

      // CIDv0
      expect(Uri('QmYjtig7VJQ6XsnUjqqJvj7QaMcCAwtrgNdahSiFofrE7o')).toBe(
        'ipfs://QmYjtig7VJQ6XsnUjqqJvj7QaMcCAwtrgNdahSiFofrE7o'
      );

      // CIDv1 in Base32
      expect(Uri('bafybeib24abrrlurxmgedaekfz2v2eatpzo2l5cbvdoay4hnpenuzojt6a')).toBe(
        'ipfs://bafybeib24abrrlurxmgedaekfz2v2eatpzo2l5cbvdoay4hnpenuzojt6a'
      );

      // CIDv1 in Base58btc
      expect(Uri('zdj7WWeQ43G6JJvLWQWZpyHuAMq6uYWRjkBXFad11vE2LHhQ7')).toBe(
        'ipfs://zdj7WWeQ43G6JJvLWQWZpyHuAMq6uYWRjkBXFad11vE2LHhQ7'
      );
    });
    it('throws for string without protocol:// prefix', () => {
      expect(() => Uri('abc123')).toThrowError(InvalidStringError);
    });
  });

  describe('ImageMediaType', () => {
    it('accepts a string starting with image/', () => {
      expect(() => ImageMediaType('image/svg+xml')).not.toThrow();
    });
    it('throws for non-image media type', () => {
      expect(() => ImageMediaType('video/webm')).toThrowError(InvalidStringError);
    });
  });

  describe('MediaType', () => {
    it('accepts any media type in format "type/subtype"', () => {
      expect(() => MediaType('image/svg+xml')).not.toThrow();
      expect(() => MediaType('video/mp4')).not.toThrow();
      expect(() => MediaType('audio/x-wav')).not.toThrow();
    });
    it('throws for incorrectly formatted media type', () => {
      expect(() => MediaType('videomp4')).toThrowError(InvalidStringError);
    });
  });
});
