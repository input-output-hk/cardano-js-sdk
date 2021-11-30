import { Cardano } from '../../../src';

describe('Cardano.util.computeMinUtxoValue', () => {
  it('returns bigint', () => expect(typeof Cardano.util.computeMinUtxoValue(100n)).toBe('bigint'));
});
