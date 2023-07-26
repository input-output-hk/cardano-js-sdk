import { Cardano, PlutusData } from '../../src';
import { HexBlob } from '@cardano-sdk/util';

describe('PlutusData', () => {
  it('round trip serializations produce the same core type output', () => {
    const plutusData: Cardano.PlutusData = 123n;
    const fromCore = PlutusData.fromCore(plutusData);
    const cbor = fromCore.toCbor();
    const fromCbor = PlutusData.fromCbor(cbor);
    expect(fromCbor.toCore()).toEqual(plutusData);
  });

  it.skip('converts (TODO: describe is special about this that fails) inline datum', () => {
    // tx: https://preprod.cexplorer.io/tx/32d2b9062680c7ef5673114abce804d8b854f54440518e48a6db3e555f3a84d2
    // parsed datum: https://preprod.cexplorer.io/datum/f20e5a0a42a9015cd4e53f8b8c020e535957f782ea3231453fe4cf46a52d07c9
    const cbor = HexBlob(
      'd8799fa3446e616d6548537061636542756445696d6167654b697066733a2f2f7465737445696d616765583061723a2f2f66355738525a6d4151696d757a5f7679744659396f66497a6439517047614449763255587272616854753401ff'
    );
    expect(() => PlutusData.fromCbor(cbor)).not.toThrowError();
  });
});
