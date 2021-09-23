import { computeMinUtxoValue } from '../../src/Cardano/util';

describe('Cardano', () => {
  describe('util', () => {
    it('computeMinUtxoValue', () => expect(typeof computeMinUtxoValue(100n)).toBe('bigint'));
  });
});
