/* eslint-disable sonarjs/no-duplicate-string */
import { HexBlob } from '@cardano-sdk/util';
import { UnregisterDelegateRepresentative } from '../../../src/Serialization/index.js';
import type * as Cardano from '../../../src/Cardano/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob('83118200581c0000000000000000000000000000000000000000000000000000000000');

const core = {
  __typename: 'UnregisterDelegateRepresentativeCertificate',
  dRepCredential: {
    hash: '00000000000000000000000000000000000000000000000000000000',
    type: 0
  },
  deposit: 0n
} as Cardano.UnRegisterDelegateRepresentativeCertificate;

describe('UnregisterDelegateRepresentative', () => {
  it('can encode UnregisterDelegateRepresentative to CBOR', () => {
    const cert = UnregisterDelegateRepresentative.fromCore(core);

    expect(cert.toCbor()).toEqual(cbor);
  });

  it('can encode UnregisterDelegateRepresentative to Core', () => {
    const cert = UnregisterDelegateRepresentative.fromCbor(cbor);

    expect(cert.toCore()).toEqual(core);
  });
});
