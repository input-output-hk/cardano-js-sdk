/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { StakeRegistration } from '../../../src/Serialization/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
describe('StakeRegistration', () => {
  it('can decode StakeRegistration from CBOR', () => {
    const cbor = HexBlob('82008200581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f');

    const certificate = StakeRegistration.fromCbor(cbor);

    expect(certificate.stakeCredential()).toEqual({
      hash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
      type: Cardano.CredentialType.KeyHash
    });
  });

  it('can decode StakeRegistration from Core', () => {
    const core: Cardano.StakeAddressCertificate = {
      __typename: Cardano.CertificateType.StakeRegistration,
      stakeCredential: {
        hash: Crypto.Hash28ByteBase16('cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f'),
        type: Cardano.CredentialType.KeyHash
      }
    };

    const certificate = StakeRegistration.fromCore(core);

    expect(certificate.stakeCredential()).toEqual({
      hash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
      type: Cardano.CredentialType.KeyHash
    });
  });

  it('can encode StakeRegistration to CBOR', () => {
    const core: Cardano.StakeAddressCertificate = {
      __typename: Cardano.CertificateType.StakeRegistration,
      stakeCredential: {
        hash: Crypto.Hash28ByteBase16('cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f'),
        type: Cardano.CredentialType.KeyHash
      }
    };

    const certificate = StakeRegistration.fromCore(core);

    expect(certificate.toCbor()).toEqual('82008200581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f');
  });

  it('can encode StakeRegistration to Core', () => {
    const cbor = HexBlob('82008200581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f');

    const certificate = StakeRegistration.fromCbor(cbor);

    expect(certificate.toCore()).toEqual({
      __typename: Cardano.CertificateType.StakeRegistration,
      stakeCredential: {
        hash: Crypto.Hash28ByteBase16('cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f'),
        type: Cardano.CredentialType.KeyHash
      }
    });
  });
});
