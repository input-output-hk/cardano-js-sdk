/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano';
import { HexBlob } from '@cardano-sdk/util';
import { UnitInterval } from '../../../src/Serialization';

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
});
