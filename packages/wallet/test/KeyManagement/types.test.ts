import { KeyManagement } from '../../src';

describe('KeyManagement/types', () => {
  describe('hexBlob', () => {
    it('accepts a hex string', () => {
      expect(() => KeyManagement.HexBlob('1234567890abcdef')).not.toThrow();
    });
    it('throws for invalid hex string', () => {
      expect(() => KeyManagement.HexBlob('1234567890abcdefg')).toThrow();
    });
  });
});
