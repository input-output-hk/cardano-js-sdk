/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano';
import { HexBlob } from '@cardano-sdk/util';
import { VoteDelegation } from '../../../src/Serialization';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob(
  '83098200581c000000000000000000000000000000000000000000000000000000008200581c00000000000000000000000000000000000000000000000000000000'
);
const core = {
  __typename: 'VoteDelegationCertificate',
  dRep: {
    hash: '00000000000000000000000000000000000000000000000000000000',
    type: 0
  },
  stakeKeyHash: '00000000000000000000000000000000000000000000000000000000'
} as Cardano.VoteDelegationCertificate;

describe('VoteDelegation', () => {
  it('can encode VoteDelegation to CBOR', () => {
    const cert = VoteDelegation.fromCore(core);

    expect(cert.toCbor()).toEqual(cbor);
  });

  it('can encode VoteDelegation to Core', () => {
    const cert = VoteDelegation.fromCbor(cbor);

    expect(cert.toCore()).toEqual(core);
  });
});
