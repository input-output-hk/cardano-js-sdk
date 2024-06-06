/* eslint-disable sonarjs/no-duplicate-string */
import { HexBlob } from '@cardano-sdk/util';
import { UpdateDelegateRepresentative } from '../../../src/Serialization/index.js';
import type * as Cardano from '../../../src/Cardano/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob(
  '83128200581c00000000000000000000000000000000000000000000000000000000827668747470733a2f2f7777772e736f6d6575726c2e696f58200000000000000000000000000000000000000000000000000000000000000000'
);

const core = {
  __typename: 'UpdateDelegateRepresentativeCertificate',
  anchor: {
    dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
    url: 'https://www.someurl.io'
  },
  dRepCredential: {
    hash: '00000000000000000000000000000000000000000000000000000000',
    type: 0
  }
} as Cardano.UpdateDelegateRepresentativeCertificate;

describe('UpdateDelegateRepresentative', () => {
  it('can encode UpdateDelegateRepresentative to CBOR', () => {
    const cert = UpdateDelegateRepresentative.fromCore(core);

    expect(cert.toCbor()).toEqual(cbor);
  });

  it('can encode UpdateDelegateRepresentative to Core', () => {
    const cert = UpdateDelegateRepresentative.fromCbor(cbor);

    expect(cert.toCore()).toEqual(core);
  });
});
