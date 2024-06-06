import { senderOrigin } from '../src/index.js';

describe('util', () => {
  describe('senderOrigin', () => {
    it('returns null when origin url is not present', () => {
      expect(senderOrigin()).toBe(null);
      expect(senderOrigin({ id: 'id' })).toBe(null);
    });
    it('returns origin url it is present', () => {
      expect(senderOrigin({ url: 'http://origin' })).toBe('http://origin');
    });
  });
});
