import { Cardano } from '../../../src/index.js';
import { dummyLogger } from 'ts-log';

describe('plutusDataUtils', () => {
  describe('tryConvertPlutusMapToUtf8Record', () => {
    it('converts keys and values when they appear to be bytes of utf8 strings', () => {
      expect(
        Cardano.util.tryConvertPlutusMapToUtf8Record(
          {
            data: new Map<Cardano.PlutusData, Cardano.PlutusData>([
              [Buffer.from('key', 'utf8'), Buffer.from('value', 'utf8')]
            ])
          },
          dummyLogger
        )
      ).toEqual({
        key: 'value'
      });
    });

    it('omits keys that cannot be converted to utf8 string', () => {
      expect(
        Cardano.util.tryConvertPlutusMapToUtf8Record(
          {
            data: new Map<Cardano.PlutusData, Cardano.PlutusData>([[Buffer.from([1000]), Buffer.from('value', 'utf8')]])
          },
          dummyLogger
        )
      ).toEqual({});
    });

    it('keeps values that cannot converted to utf8 string unchanged', () => {
      const nonStringValue: Cardano.PlutusData = Buffer.from([1000]);
      expect(
        Cardano.util.tryConvertPlutusMapToUtf8Record(
          {
            data: new Map<Cardano.PlutusData, Cardano.PlutusData>([[Buffer.from('key', 'utf8'), nonStringValue]])
          },
          dummyLogger
        )
      ).toEqual({ key: nonStringValue });
    });
  });
});
