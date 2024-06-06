/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { StakeVoteRegistrationDelegation } from '../../../src/Serialization/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob(
  '850d8200581c00000000000000000000000000000000000000000000000000000000581c000000000000000000000000000000000000000000000000000000008200581c0000000000000000000000000000000000000000000000000000000000'
);
const core = {
  __typename: 'StakeVoteRegistrationDelegateCertificate',
  dRep: {
    hash: '00000000000000000000000000000000000000000000000000000000',
    type: 0
  },
  deposit: 0n,
  poolId: 'pool1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq8a7a2d',
  stakeCredential: {
    hash: Crypto.Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
    type: Cardano.CredentialType.KeyHash
  }
} as Cardano.StakeVoteRegistrationDelegationCertificate;

describe('StakeVoteRegistrationDelegation', () => {
  it('can encode StakeVoteRegistrationDelegation to CBOR', () => {
    const cert = StakeVoteRegistrationDelegation.fromCore(core);

    expect(cert.toCbor()).toEqual(cbor);
  });

  it('can encode StakeVoteRegistrationDelegation to Core', () => {
    const cert = StakeVoteRegistrationDelegation.fromCbor(cbor);

    expect(cert.toCore()).toEqual(core);
  });
});
