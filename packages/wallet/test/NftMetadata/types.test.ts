import * as NftMetadata from '../../src/NftMetadata';
import { InvalidStringError } from '@cardano-sdk/core';

describe('NftMetadata/types', () => {
  describe('Uri', () => {
    it('accepts a string starting with protocol://', () => {
      expect(() => NftMetadata.Uri('http://some.url')).not.toThrow();
      expect(() => NftMetadata.Uri('ipfs://abc123')).not.toThrow();
    });
    it('throws for string without protocol:// prefix', () => {
      expect(() => NftMetadata.Uri('abc123')).toThrowError(InvalidStringError);
    });
  });

  describe('ImageMediaType', () => {
    it('accepts a string starting with image/', () => {
      expect(() => NftMetadata.ImageMediaType('image/svg+xml')).not.toThrow();
    });
    it('throws for non-image media type', () => {
      expect(() => NftMetadata.ImageMediaType('video/webm')).toThrowError(InvalidStringError);
    });
  });

  describe('MediaType', () => {
    it('accepts any media type in format "type/subtype"', () => {
      expect(() => NftMetadata.MediaType('image/svg+xml')).not.toThrow();
      expect(() => NftMetadata.MediaType('video/mp4')).not.toThrow();
      expect(() => NftMetadata.MediaType('audio/x-wav')).not.toThrow();
    });
    it('throws for incorrectly formatted media type', () => {
      expect(() => NftMetadata.MediaType('videomp4')).toThrowError(InvalidStringError);
    });
  });
});
