/* eslint-disable sonarjs/no-duplicate-string */
import { AuthCommitteeHot } from '../../../src/Serialization/index.js';
import { HexBlob } from '@cardano-sdk/util';
import type * as Cardano from '../../../src/Cardano/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob(
  '830e8200581c000000000000000000000000000000000000000000000000000000008200581c00000000000000000000000000000000000000000000000000000000'
);
const core = {
  __typename: 'AuthorizeCommitteeHotCertificate',
  coldCredential: {
    hash: '00000000000000000000000000000000000000000000000000000000',
    type: 0
  },
  hotCredential: {
    hash: '00000000000000000000000000000000000000000000000000000000',
    type: 0
  }
} as Cardano.AuthorizeCommitteeHotCertificate;

describe('AuthCommitteeHot', () => {
  it('can encode AuthCommitteeHot to CBOR', () => {
    const cert = AuthCommitteeHot.fromCore(core);

    expect(cert.toCbor()).toEqual(cbor);
  });

  it('can encode AuthCommitteeHot to Core', () => {
    const cert = AuthCommitteeHot.fromCbor(cbor);

    expect(cert.toCore()).toEqual(core);
  });
});
