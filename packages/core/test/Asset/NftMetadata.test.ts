import { ImageMediaType, MediaType, Uri } from '../../src/Asset';
import { InvalidStringError } from '../../src/errors';

describe('NftMetadata/types', () => {
  describe('Uri', () => {
    it('accepts a string starting with protocol://', () => {
      expect(() => Uri('http://some.url')).not.toThrow();
      expect(() => Uri('ipfs://abc123')).not.toThrow();
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
