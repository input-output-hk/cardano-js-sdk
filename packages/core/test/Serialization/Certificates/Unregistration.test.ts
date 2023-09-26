/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano';
import { HexBlob } from '@cardano-sdk/util';
import { Unregistration } from '../../../src/Serialization';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob('83088200581c0000000000000000000000000000000000000000000000000000000000');
const core = {
  __typename: 'UnRegistrationCertificate',
  deposit: 0n,
  stakeKeyHash: '00000000000000000000000000000000000000000000000000000000'
} as Cardano.NewStakeAddressCertificate;

describe('Unregistration', () => {
  it('can encode Unregistration to CBOR', () => {
    const cert = Unregistration.fromCore(core);

    expect(cert.toCbor()).toEqual(cbor);
  });

  it('can encode Unregistration to Core', () => {
    const cert = Unregistration.fromCbor(cbor);

    expect(cert.toCore()).toEqual(core);
  });
});
