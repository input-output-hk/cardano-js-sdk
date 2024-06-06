/* eslint-disable sonarjs/no-duplicate-string */
import { Datum, DatumKind } from '../../../src/Serialization/index.js';
import { HexBlob } from '@cardano-sdk/util';
import type * as Cardano from '../../../src/Cardano/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib

const datumHashCbor = HexBlob('820058200000000000000000000000000000000000000000000000000000000000000000');
const inlineDatumCbor = HexBlob('8201d8799f0102030405ff');

const datumHashCore = HexBlob(
  '0000000000000000000000000000000000000000000000000000000000000000'
) as unknown as Cardano.DatumHash;

const inlineDatumCore = {
  cbor: HexBlob('d8799f0102030405ff'),
  constructor: 0n,
  fields: { cbor: HexBlob('9f0102030405ff'), items: [1n, 2n, 3n, 4n, 5n] }
};

describe('Datum', () => {
  it('can decode Datum hash from CBOR', () => {
    const datum = Datum.fromCbor(datumHashCbor);

    expect(datum.kind()).toEqual(DatumKind.DataHash);
    expect(datum.asInlineData()).toBeUndefined();
    expect(datum.asDataHash()).toEqual(datumHashCore);
  });

  it('can decode Datum hash from Core', () => {
    const datum = Datum.fromCore(datumHashCore);

    expect(datum.kind()).toEqual(DatumKind.DataHash);
    expect(datum.asInlineData()).toBeUndefined();
    expect(datum.asDataHash()).toEqual(datumHashCore);
  });

  it('can encode Datum hash to CBOR', () => {
    const datum = Datum.fromCore(datumHashCore);

    expect(datum.toCbor()).toEqual(datumHashCbor);
  });

  it('can encode Datum hash to Core', () => {
    const datum = Datum.fromCbor(datumHashCbor);

    expect(datum.toCore()).toEqual(datumHashCore);
  });

  it('can decode inline Datum from CBOR', () => {
    const datum = Datum.fromCbor(inlineDatumCbor);

    expect(datum.kind()).toEqual(DatumKind.InlineData);
    expect(datum.asDataHash()).toBeUndefined();
    expect(datum.asInlineData()?.toCbor()).toEqual('d8799f0102030405ff');
  });

  it('can decode inline Datum from Core', () => {
    const datum = Datum.fromCore(inlineDatumCore);

    expect(datum.kind()).toEqual(DatumKind.InlineData);
    expect(datum.asDataHash()).toBeUndefined();
    expect(datum.asInlineData()?.toCbor()).toEqual('d8799f0102030405ff');
  });

  it('can encode inline Datum to CBOR', () => {
    const datum = Datum.fromCore(inlineDatumCore);

    expect(datum.toCbor()).toEqual(inlineDatumCbor);
  });

  it('can encode inline Datum to Core', () => {
    const datum = Datum.fromCbor(inlineDatumCbor);

    expect(datum.toCore()).toEqual(inlineDatumCore);
  });
});
