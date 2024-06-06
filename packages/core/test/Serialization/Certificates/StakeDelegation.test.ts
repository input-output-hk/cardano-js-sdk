/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { StakeDelegation } from '../../../src/Serialization/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
describe('StakeDelegation', () => {
  it('can decode StakeDelegation from CBOR', () => {
    const cbor = HexBlob(
      '83028200581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f581cd85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef92'
    );

    const certificate = StakeDelegation.fromCbor(cbor);

    expect(certificate.stakeCredential()).toEqual({
      hash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
      type: Cardano.CredentialType.KeyHash
    });
  });

  it('can decode StakeDelegation from Core', () => {
    const core: Cardano.StakeDelegationCertificate = {
      __typename: Cardano.CertificateType.StakeDelegation,
      poolId: Cardano.PoolId('pool1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumheygxmn34'),
      stakeCredential: {
        hash: Crypto.Hash28ByteBase16('cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f'),
        type: Cardano.CredentialType.KeyHash
      }
    };

    const certificate = StakeDelegation.fromCore(core);

    expect(certificate.stakeCredential()).toEqual({
      hash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
      type: Cardano.CredentialType.KeyHash
    });
  });

  it('can encode StakeDelegation to CBOR', () => {
    const core: Cardano.StakeDelegationCertificate = {
      __typename: Cardano.CertificateType.StakeDelegation,
      poolId: Cardano.PoolId('pool1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumheygxmn34'),
      stakeCredential: {
        hash: Crypto.Hash28ByteBase16('cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f'),
        type: Cardano.CredentialType.KeyHash
      }
    };

    const certificate = StakeDelegation.fromCore(core);

    expect(certificate.toCbor()).toEqual(
      '83028200581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f581cd85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef92'
    );
  });

  it('can encode StakeDelegation to Core', () => {
    const cbor = HexBlob(
      '83028200581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f581cd85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef92'
    );

    const certificate = StakeDelegation.fromCbor(cbor);

    expect(certificate.toCore()).toEqual({
      __typename: Cardano.CertificateType.StakeDelegation,
      poolId: Cardano.PoolId('pool1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumheygxmn34'),
      stakeCredential: {
        hash: Crypto.Hash28ByteBase16('cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f'),
        type: Cardano.CredentialType.KeyHash
      }
    });
  });
});
