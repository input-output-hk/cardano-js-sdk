import * as Cardano from '../../../src/Cardano';
import * as Crypto from '@cardano-sdk/crypto';
import {
  CertificateType,
  PoolId,
  RewardAccount,
  createDelegationCert,
  createStakeDeregistrationCert,
  createStakeRegistrationCert,
  stakeKeyCertificates
} from '../../../src/Cardano';

const rewardAccount = RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr');
const stakeCredential = {
  hash: Crypto.Hash28ByteBase16('cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f'),
  type: Cardano.CredentialType.KeyHash
};
const poolId = PoolId('pool1ev8vy6fyj7693ergzty2t0azjvw35tvkt2vcjwpgajqs7z6u2vn');

describe('Certificate', () => {
  describe('createStakeRegistrationCert', () => {
    it('can create a stake key registration certificate', () => {
      const cert = createStakeRegistrationCert(rewardAccount);
      expect(cert).toEqual({
        __typename: CertificateType.StakeRegistration,
        stakeCredential
      });
    });
  });

  describe('createStakeDeregistrationCert', () => {
    it('can create a stake key de-registration certificate', () => {
      const cert = createStakeDeregistrationCert(rewardAccount);
      expect(cert).toEqual({
        __typename: CertificateType.StakeDeregistration,
        stakeCredential
      });
    });
  });

  describe('createDelegationCert', () => {
    it('can get the policy ID component from the asset id', () => {
      const cert = createDelegationCert(rewardAccount, poolId);
      expect(cert).toEqual({
        __typename: CertificateType.StakeDelegation,
        poolId: 'pool1ev8vy6fyj7693ergzty2t0azjvw35tvkt2vcjwpgajqs7z6u2vn',
        stakeCredential
      });
    });
  });

  it('can identify stake key certificates', () => {
    const certificates = stakeKeyCertificates([
      { __typename: Cardano.CertificateType.StakeDelegation } as Cardano.Certificate, // does not register stake key
      { __typename: Cardano.CertificateType.StakeRegistration } as Cardano.Certificate,
      { __typename: Cardano.CertificateType.StakeDeregistration } as Cardano.Certificate,
      { __typename: Cardano.CertificateType.StakeVoteDelegation } as Cardano.Certificate, // does not register stake key
      { __typename: Cardano.CertificateType.StakeRegistrationDelegation } as Cardano.Certificate,
      { __typename: Cardano.CertificateType.StakeVoteDelegation } as Cardano.Certificate, // does not register stake key
      { __typename: Cardano.CertificateType.StakeVoteRegistrationDelegation } as Cardano.Certificate,
      { __typename: Cardano.CertificateType.VoteRegistrationDelegation } as Cardano.Certificate,
      { __typename: Cardano.CertificateType.Registration } as Cardano.Certificate
    ]);
    expect(certificates).toHaveLength(6);
    expect(certificates[0].__typename).toBe(Cardano.CertificateType.StakeRegistration);
    expect(certificates[1].__typename).toBe(Cardano.CertificateType.StakeDeregistration);
  });

  it('can narrow down the type of a certificate based on CertificateType', () => {
    const cert: Cardano.StakeAddressCertificate = {
      __typename: Cardano.CertificateType.StakeRegistration,
      stakeCredential
    };

    expect(Cardano.isCertType(cert, [Cardano.CertificateType.StakeRegistration])).toBeTruthy();
    expect(Cardano.isCertType(cert, Cardano.StakeRegistrationCertificateTypes)).toBeTruthy();
    expect(Cardano.isCertType(cert, Cardano.StakeDelegationCertificateTypes)).toBeFalsy();
    expect(Cardano.isCertType(cert, Cardano.PostConwayStakeRegistrationCertificateTypes)).toBeFalsy();

    // Narrows down the type to certificates with stakeCredential property, based on the array of certificate types
    expect(Cardano.isCertType(cert, Cardano.StakeCredentialCertificateTypes) && cert.stakeCredential).toBeTruthy();
  });
});
