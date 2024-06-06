/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { VoteRegistrationDelegation } from '../../../src/Serialization/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob(
  '840c8200581c000000000000000000000000000000000000000000000000000000008200581c0000000000000000000000000000000000000000000000000000000000'
);
const core = {
  __typename: 'VoteRegistrationDelegateCertificate',
  dRep: {
    hash: '00000000000000000000000000000000000000000000000000000000',
    type: 0
  },
  deposit: 0n,
  stakeCredential: {
    hash: Crypto.Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
    type: Cardano.CredentialType.KeyHash
  }
} as Cardano.VoteRegistrationDelegationCertificate;

describe('VoteRegistrationDelegation', () => {
  it('can encode VoteRegistrationDelegation to CBOR', () => {
    const cert = VoteRegistrationDelegation.fromCore(core);

    expect(cert.toCbor()).toEqual(cbor);
  });

  it('can encode VoteRegistrationDelegation to Core', () => {
    const cert = VoteRegistrationDelegation.fromCbor(cbor);

    expect(cert.toCore()).toEqual(core);
  });
});
