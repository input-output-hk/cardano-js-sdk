/* eslint-disable sonarjs/no-duplicate-string */
import { ExUnitPrices } from '../../../src/Serialization/index.js';
import { HexBlob } from '@cardano-sdk/util';
import type * as Cardano from '../../../src/Cardano/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
describe('ExUnitPrices', () => {
  it('can decode ExUnitPrices from CBOR', () => {
    const cbor = HexBlob('82d81e820102d81e820103');

    const prices = ExUnitPrices.fromCbor(cbor);

    expect(prices.memPrice().toFloat()).toEqual(0.5);
    expect(prices.stepsPrice().toFloat()).toEqual(0.333_333_333_333_333_3);
  });

  it('can decode ExUnitPrices from Core', () => {
    const core = { memory: 0.5, steps: 0.333_333_333_333_333_3 } as Cardano.Prices;

    const prices = ExUnitPrices.fromCore(core);

    expect(prices.memPrice().toFloat()).toEqual(0.5);
    expect(prices.stepsPrice().toFloat()).toEqual(0.333_333_333_333_333_3);
  });

  it('can encode ExUnitPrices to CBOR', () => {
    const core = { memory: 0.5, steps: 0.333_333_333_333_333_3 } as Cardano.Prices;

    const prices = ExUnitPrices.fromCore(core);

    expect(prices.toCbor()).toEqual('82d81e820102d81e820103');
  });

  it('can encode ExUnitPrices to Core', () => {
    const cbor = HexBlob('82d81e820102d81e820103');

    const prices = ExUnitPrices.fromCbor(cbor);

    expect(prices.toCore()).toEqual({ memory: 0.5, steps: 0.333_333_333_333_333_3 });
  });
});
