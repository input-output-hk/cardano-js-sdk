import { Cardano } from '../../../src/index.js';

describe('Cardano.util.computeMinUtxoValue', () => {
  it('returns bigint', () => expect(typeof Cardano.util.computeMinUtxoValue(100n)).toBe('bigint'));
});
