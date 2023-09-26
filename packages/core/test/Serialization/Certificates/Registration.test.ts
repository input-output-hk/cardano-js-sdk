/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano';
import { HexBlob } from '@cardano-sdk/util';
import { Registration } from '../../../src/Serialization';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob('83078200581c0000000000000000000000000000000000000000000000000000000000');
const core = {
  __typename: 'RegistrationCertificate',
  deposit: 0n,
  stakeKeyHash: '00000000000000000000000000000000000000000000000000000000'
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
