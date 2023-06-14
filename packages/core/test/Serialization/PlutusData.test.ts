import { Cardano, Serialization } from '../../src';

describe('PlutusData', () => {
  it('round trip serializations produce the same core type output', () => {
    const plutusData: Cardano.PlutusData = 123n;
    const fromCore = Serialization.PlutusData.fromCore(plutusData);
    const cbor = fromCore.toCbor();
    const fromCbor = Serialization.PlutusData.fromCbor(cbor);
    expect(fromCbor.toCore()).toEqual(plutusData);
  });
});
