/* eslint-disable sonarjs/no-duplicate-string */
import { Constitution } from '../../../../src/Serialization/index.js';
import { HexBlob } from '@cardano-sdk/util';
import type * as Cardano from '../../../../src/Cardano/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob(
  '82827668747470733a2f2f7777772e736f6d6575726c2e696f58200000000000000000000000000000000000000000000000000000000000000000f6'
);
const core = {
  anchor: {
    dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
    url: 'https://www.someurl.io'
  },
  scriptHash: null
} as Cardano.Constitution;

describe('Constitution', () => {
  it('can encode Constitution to CBOR', () => {
    const constitution = Constitution.fromCore(core);

    expect(constitution.toCbor()).toEqual(cbor);
  });

  it('can encode Constitution to Core', () => {
    const constitution = Constitution.fromCbor(cbor);

    expect(constitution.toCore()).toEqual(core);
  });
});
