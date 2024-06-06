/* eslint-disable sonarjs/no-duplicate-string */
import { HexBlob } from '@cardano-sdk/util';
import { UnitInterval } from '../../../src/Serialization/index.js';
import type * as Cardano from '../../../src/Cardano/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
describe('UnitInterval', () => {
  it('can decode UnitInterval from CBOR', () => {
    const cbor = HexBlob('d81e820105');

    const interval = UnitInterval.fromCbor(cbor);

    expect(interval.numerator()).toEqual(1n);
    expect(interval.denominator()).toEqual(5n);
  });

  it('can decode UnitInterval from Core', () => {
    const core = { denominator: 5, numerator: 1 } as Cardano.Fraction;

    const interval = UnitInterval.fromCore(core);

    expect(interval.numerator()).toEqual(1n);
    expect(interval.denominator()).toEqual(5n);
  });

  it('can encode UnitInterval to CBOR', () => {
    const core = { denominator: 5, numerator: 1 } as Cardano.Fraction;

    const interval = UnitInterval.fromCore(core);

    expect(interval.toCbor()).toEqual('d81e820105');
  });

  it('can encode UnitInterval to Core', () => {
    const cbor = HexBlob('d81e820105');

    const interval = UnitInterval.fromCbor(cbor);

    expect(interval.toCore()).toEqual({ denominator: 5, numerator: 1 });
  });

  it('can convert to a float number', () => {
    const cbor = HexBlob('d81e820102');

    const interval = UnitInterval.fromCbor(cbor);

    expect(interval.toFloat()).toEqual(0.5);
  });

  it('can be created from a float number', () => {
    const interval = UnitInterval.fromFloat(0.5)!;

    expect(interval.toCore()).toEqual({ denominator: 2, numerator: 1 });
    expect(interval.toCbor()).toEqual('d81e820102');
  });
});
