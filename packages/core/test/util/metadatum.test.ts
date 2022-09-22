import { Cardano } from '../../src';
import { asMetadatumArray, asMetadatumMap, jsonToMetadatum, metadatumToJson } from '../../src/util/metadatum';

describe('Cardano.util.metadatum', () => {
  describe('asMetadatumMap', () => {
    it('returns argument if it is a MetadatumMap', () => {
      const metadatum: Cardano.Metadatum = new Map([['some', 'metadatum']]);
      expect(asMetadatumMap(metadatum)).toBe(metadatum);
    });

    it('returns null for any other metadatum type', () => {
      const metadatum: Cardano.Metadatum = [new Map([['some', 'metadatum']])];
      expect(asMetadatumMap(metadatum)).toBeNull();
    });
  });

  describe('asMetadatumArray', () => {
    it('returns argument if it is Metadatum[]', () => {
      const metadatum: Cardano.Metadatum = [new Map([['some', 'metadatum']])];
      expect(asMetadatumArray(metadatum)).toBe(metadatum);
    });

    it('returns null for any other metadatum type', () => {
      const metadatum: Cardano.Metadatum = new Map([['some', 'metadatum']]);
      expect(asMetadatumArray(metadatum)).toBeNull();
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

      expect(jsonToMetadatum(json)).toMatchObject(metadatum);
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

      expect(metadatumToJson(metadatum)).toMatchObject(json);
    });
  });
});
