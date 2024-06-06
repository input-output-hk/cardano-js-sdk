/* eslint-disable sonarjs/no-duplicate-string */
import { ExUnits } from '../../../src/Serialization/index.js';
import { HexBlob } from '@cardano-sdk/util';
import type * as Cardano from '../../../src/Cardano/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
describe('ExUnits', () => {
  it('can decode ExUnits from CBOR', () => {
    const cbor = HexBlob('821b000086788ffc4e831b00015060e9e46451');

    const units = ExUnits.fromCbor(cbor);

    expect(units.mem()).toEqual(147_852_369_874_563n);
    expect(units.steps()).toEqual(369_852_147_852_369n);
  });

  it('can decode ExUnits from Core', () => {
    const core = { memory: 147_852_369_874_563, steps: 369_852_147_852_369 } as Cardano.ExUnits;

    const units = ExUnits.fromCore(core);

    expect(units.mem()).toEqual(147_852_369_874_563n);
    expect(units.steps()).toEqual(369_852_147_852_369n);
  });

  it('can encode ExUnits to CBOR', () => {
    const core = { memory: 147_852_369_874_563, steps: 369_852_147_852_369 } as Cardano.ExUnits;

    const units = ExUnits.fromCore(core);

    expect(units.toCbor()).toEqual('821b000086788ffc4e831b00015060e9e46451');
  });

  it('can encode ExUnits to Core', () => {
    const cbor = HexBlob('821b000086788ffc4e831b00015060e9e46451');

    const units = ExUnits.fromCbor(cbor);

    expect(units.toCore()).toEqual({ memory: 147_852_369_874_563, steps: 369_852_147_852_369 });
  });
});
