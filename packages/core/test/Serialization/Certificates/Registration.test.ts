/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { Registration } from '../../../src/Serialization/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob('83078200581c0000000000000000000000000000000000000000000000000000000000');
const core = {
  __typename: 'RegistrationCertificate',
  deposit: 0n,
  stakeCredential: {
    hash: Crypto.Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
    type: Cardano.CredentialType.KeyHash
  }
} as Cardano.NewStakeAddressCertificate;

describe('Registration', () => {
  it('can encode Registration to CBOR', () => {
    const cert = Registration.fromCore(core);

    expect(cert.toCbor()).toEqual(cbor);
  });

  it('can encode Registration to Core', () => {
    const cert = Registration.fromCbor(cbor);

    expect(cert.toCore()).toEqual(core);
  });
});
