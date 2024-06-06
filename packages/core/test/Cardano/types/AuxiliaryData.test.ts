import { computeAuxiliaryDataHash } from '../../../src/Cardano/index.js';
import type { Metadatum } from '../../../src/Cardano/index.js';

describe('Cardano/types/AuxiliaryData', () => {
  describe('computeAuxiliaryDataHash', () => {
    it('can compute the correct auxiliary data hash', () => {
      const auxiliaryData = {
        blob: new Map<bigint, Metadatum>([
          [1n, 1234n],
          [2n, 'str'],
          [3n, [1234n, 'str']],
          [4n, new Uint8Array(Buffer.from('bytes'))],
          [
            5n,
            new Map<Metadatum, Metadatum>([
              ['strkey', 123n],
              [['listkey'], 'strvalue']
            ])
          ],
          [6n, -7n]
        ])
      };

      expect(computeAuxiliaryDataHash(auxiliaryData)).toEqual(
        '2ceb364d93225b4a0f004a0975a13eb50c3cc6348474b4fe9121f8dc72ca0cfa'
      );
    });

    it('returns undefined when given an undefined auxiliary data', () => {
      const auxiliaryData = undefined;

      expect(() => computeAuxiliaryDataHash(auxiliaryData)).not.toThrow();
      expect(computeAuxiliaryDataHash(auxiliaryData)).toEqual(undefined);
    });
  });
});
