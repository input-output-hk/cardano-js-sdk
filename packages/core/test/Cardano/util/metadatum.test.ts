import { Cardano } from '../../../src';

describe('Cardano.util.metadatum', () => {
  describe('asMetadatumMap', () => {
    it('returns argument if it is a MetadatumMap', () => {
      const metadatum: Cardano.Metadatum = new Map([['some', 'metadatum']]);
      expect(Cardano.util.metadatum.asMetadatumMap(metadatum)).toBe(metadatum);
    });

    it('returns null for any other metadatum type', () => {
      const metadatum: Cardano.Metadatum = [new Map([['some', 'metadatum']])];
      expect(Cardano.util.metadatum.asMetadatumMap(metadatum)).toBeNull();
    });
  });

  describe('asMetadatumArray', () => {
    it('returns argument if it is Metadatum[]', () => {
      const metadatum: Cardano.Metadatum = [new Map([['some', 'metadatum']])];
      expect(Cardano.util.metadatum.asMetadatumArray(metadatum)).toBe(metadatum);
    });

    it('returns null for any other metadatum type', () => {
      const metadatum: Cardano.Metadatum = new Map([['some', 'metadatum']]);
      expect(Cardano.util.metadatum.asMetadatumArray(metadatum)).toBeNull();
    });
  });

  describe('jsonToMetadatum', () => {
    it('returns the json object from a metadatum object', () => {
      const json = {
        field1: '1',
        field2: '2',
        field3: '3'
      };
      const metadatum: Cardano.Metadatum = new Map([
        ['field1', '1'],
        ['field2', '2'],
        ['field3', '3']
      ]);

      expect(Cardano.util.metadatum.jsonToMetadatum(json)).toMatchObject(metadatum);
    });
  });

  describe('metadatumToJson', () => {
    it('returns the metadatum object from a json object', () => {
      const json = {
        field1: '1',
        field2: '2',
        field3: '3'
      };
      const metadatum: Cardano.Metadatum = new Map([
        ['field1', '1'],
        ['field2', '2'],
        ['field3', '3']
      ]);

      expect(Cardano.util.metadatum.metadatumToJson(metadatum)).toMatchObject(json);
    });
  });
});
