/* eslint-disable sonarjs/no-duplicate-string */
import { HexBlob } from '@cardano-sdk/util';
import { RegisterDelegateRepresentative } from '../../../src/Serialization/index.js';
import type * as Cardano from '../../../src/Cardano/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob('84108200581c0000000000000000000000000000000000000000000000000000000000f6');

const core = {
  __typename: 'RegisterDelegateRepresentativeCertificate',
  anchor: null,
  dRepCredential: {
    hash: '00000000000000000000000000000000000000000000000000000000',
    type: 0
  },
  deposit: 0n
} as Cardano.RegisterDelegateRepresentativeCertificate;

describe('RegisterDelegateRepresentative', () => {
  it('can encode RegisterDelegateRepresentative to CBOR', () => {
    const cert = RegisterDelegateRepresentative.fromCore(core);

    expect(cert.toCbor()).toEqual(cbor);
  });

  it('can encode RegisterDelegateRepresentative to Core', () => {
    const cert = RegisterDelegateRepresentative.fromCbor(cbor);

    expect(cert.toCore()).toEqual(core);
  });
});
