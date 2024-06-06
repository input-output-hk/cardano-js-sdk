/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { StakeRegistrationDelegation } from '../../../src/Serialization/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob(
  '840b8200581c00000000000000000000000000000000000000000000000000000000581c0000000000000000000000000000000000000000000000000000000000'
);
const core = {
  __typename: 'StakeRegistrationDelegateCertificate',
  deposit: 0n,
  poolId: 'pool1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq8a7a2d',
  stakeCredential: {
    hash: Crypto.Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
    type: Cardano.CredentialType.KeyHash
  }
} as Cardano.StakeRegistrationDelegationCertificate;

describe('StakeRegistrationDelegation', () => {
  it('can encode StakeRegistrationDelegation to CBOR', () => {
    const cert = StakeRegistrationDelegation.fromCore(core);

    expect(cert.toCbor()).toEqual(cbor);
  });

  it('can encode StakeRegistrationDelegation to Core', () => {
    const cert = StakeRegistrationDelegation.fromCbor(cbor);

    expect(cert.toCore()).toEqual(core);
  });
});
