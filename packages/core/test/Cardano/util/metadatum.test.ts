import { Cardano } from '@cardano-sdk/core';

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
});
