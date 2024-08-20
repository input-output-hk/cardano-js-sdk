import { StringUtils } from '../src';

// Test vectors sourced from https://www.javainuse.com/bytesize

describe('StringUtils', () => {
  describe('byteSize', () => {
    it('returns the byte size of the string', () => {
      expect(StringUtils.byteSize('The quick brown fox jumps over the lazy dog')).toEqual(43);
      expect(StringUtils.byteSize('helloWorld!')).toEqual(11);
      expect(StringUtils.byteSize('👋')).toEqual(4);
    });
  });
});
