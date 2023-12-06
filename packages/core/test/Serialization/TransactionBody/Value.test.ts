/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano';
import { CborContentException, Value } from '../../../src/Serialization';
import { HexBlob } from '@cardano-sdk/util';

// Test data used in the following tests was generated with the cardano-serialization-lib

const cbor = HexBlob(
  '821a000f4240a2581c00000000000000000000000000000000000000000000000000000000a3443031323218644433343536186344404142420a581c11111111111111111111111111111111111111111111111111111111a3443031323218644433343536186344404142420a'
);

const cborWithNegativeCoin = HexBlob(
  '823a000f423fa2581c00000000000000000000000000000000000000000000000000000000a3443031323218644433343536186344404142420a581c11111111111111111111111111111111111111111111111111111111a3443031323218644433343536186344404142420a'
);

const unsortedCore = {
  assets: new Map([
    ['1111111111111111111111111111111111111111111111111111111140414242' as unknown as Cardano.AssetId, 10n],
    ['0000000000000000000000000000000000000000000000000000000030313232' as unknown as Cardano.AssetId, 100n],
    ['1111111111111111111111111111111111111111111111111111111133343536' as unknown as Cardano.AssetId, 99n],
    ['0000000000000000000000000000000000000000000000000000000040414242' as unknown as Cardano.AssetId, 10n],
    ['1111111111111111111111111111111111111111111111111111111130313232' as unknown as Cardano.AssetId, 100n],
    ['0000000000000000000000000000000000000000000000000000000033343536' as unknown as Cardano.AssetId, 99n]
  ]),
  coins: 1_000_000n
};

const onlyLovelaceCore = {
  coins: 1_000_000n
};

const onlyLovelaceCbor = HexBlob('1a000f4240');

const canonicallySortedAssets = new Map([
  ['0000000000000000000000000000000000000000000000000000000030313232' as unknown as Cardano.AssetId, 100n],
  ['0000000000000000000000000000000000000000000000000000000033343536' as unknown as Cardano.AssetId, 99n],
  ['0000000000000000000000000000000000000000000000000000000040414242' as unknown as Cardano.AssetId, 10n],
  ['1111111111111111111111111111111111111111111111111111111130313232' as unknown as Cardano.AssetId, 100n],
  ['1111111111111111111111111111111111111111111111111111111133343536' as unknown as Cardano.AssetId, 99n],
  ['1111111111111111111111111111111111111111111111111111111140414242' as unknown as Cardano.AssetId, 10n]
]);

const sortedCore = {
  assets: canonicallySortedAssets,
  coins: 1_000_000n
};

describe('Value', () => {
  it('can decode Value from CBOR', () => {
    const value = Value.fromCbor(cbor);

    expect(value.coin()).toEqual(1_000_000n);
    expect(value.multiasset()).toEqual(canonicallySortedAssets);
  });

  it('can decode Value from Core', () => {
    const value = Value.fromCore(unsortedCore);

    expect(value.coin()).toEqual(1_000_000n);
    expect(value.multiasset()).toEqual(canonicallySortedAssets);
  });

  it('can encode Value to CBOR', () => {
    const value = Value.fromCore(unsortedCore);

    expect(value.toCbor()).toEqual(cbor);
  });

  it('can encode Value to Core', () => {
    const interval = Value.fromCbor(cbor);
    expect(interval.toCore()).toEqual(sortedCore);
  });

  it('can decode Value with only lovelace from CBOR', () => {
    const value = Value.fromCbor(onlyLovelaceCbor);

    expect(value.coin()).toEqual(1_000_000n);
    expect(value.multiasset()).toBeUndefined();
  });

  it('can decode Value with only lovelace from Core', () => {
    const value = Value.fromCore(onlyLovelaceCore);

    expect(value.coin()).toEqual(1_000_000n);
    expect(value.multiasset()).toBeUndefined();
  });

  it('can encode Value with only lovelace to CBOR', () => {
    const value = Value.fromCore(onlyLovelaceCore);

    expect(value.toCbor()).toEqual(onlyLovelaceCbor);
  });

  it('can encode Value with only lovelace to Core', () => {
    const interval = Value.fromCbor(onlyLovelaceCbor);
    expect(interval.toCore()).toEqual(onlyLovelaceCore);
  });

  it('can throws if Value CBOR contains negative numbers', () => {
    expect(() => Value.fromCbor(cborWithNegativeCoin)).toThrow(CborContentException);
  });
});
