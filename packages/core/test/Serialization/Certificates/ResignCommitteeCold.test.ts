/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano';
import { HexBlob } from '@cardano-sdk/util';
import { ResignCommitteeCold } from '../../../src/Serialization';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob('820f8200581c00000000000000000000000000000000000000000000000000000000');

const core = {
  __typename: 'ResignCommitteeColdCertificate',
  coldCredential: {
    hash: '00000000000000000000000000000000000000000000000000000000',
    type: 0
  }
} as Cardano.ResignCommitteeColdCertificate;

describe('ResignCommitteeCold', () => {
  it('can encode ResignCommitteeCold to CBOR', () => {
    const cert = ResignCommitteeCold.fromCore(core);

    expect(cert.toCbor()).toEqual(cbor);
  });

  it('can encode ResignCommitteeCold to Core', () => {
    const cert = ResignCommitteeCold.fromCbor(cbor);

    expect(cert.toCore()).toEqual(core);
  });
});
