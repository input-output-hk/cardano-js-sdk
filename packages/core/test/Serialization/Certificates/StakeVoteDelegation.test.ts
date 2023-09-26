/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano';
import { HexBlob } from '@cardano-sdk/util';
import { StakeVoteDelegation } from '../../../src/Serialization';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob(
  '840a8200581c00000000000000000000000000000000000000000000000000000000581c000000000000000000000000000000000000000000000000000000008200581c00000000000000000000000000000000000000000000000000000000'
);
const core = {
  __typename: 'StakeVoteDelegationCertificate',
  dRep: {
    hash: '00000000000000000000000000000000000000000000000000000000',
    type: 0
  },
  poolId: 'pool1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq8a7a2d',
  stakeKeyHash: '00000000000000000000000000000000000000000000000000000000'
} as Cardano.StakeVoteDelegationCertificate;

describe('StakeVoteDelegation', () => {
  it('can encode StakeVoteDelegation to CBOR', () => {
    const cert = StakeVoteDelegation.fromCore(core);

    expect(cert.toCbor()).toEqual(cbor);
  });

  it('can encode StakeVoteDelegation to Core', () => {
    const cert = StakeVoteDelegation.fromCbor(cbor);

    expect(cert.toCore()).toEqual(core);
  });
});
