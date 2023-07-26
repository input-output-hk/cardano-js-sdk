import { auxiliaryDataHash } from '../testData';
import { mapAuxiliaryData } from '../../src/transformers/auxiliaryData';

describe('auxiliaryData', () => {
  describe('mapAuxiliaryData', () => {
    it('can map a valid auxiliary data hash', async () => {
      const hash = mapAuxiliaryData(auxiliaryDataHash);

      expect(hash).toEqual({
        hash: '2ceb364d93225b4a0f004a0975a13eb50c3cc6348474b4fe9121f8dc72ca0cfa'
      });
    });
  });
});
