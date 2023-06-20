import {
  CertificateType,
  PoolId,
  RewardAccount,
  createDelegationCert,
  createStakeKeyDeregistrationCert,
  createStakeKeyRegistrationCert
} from '../../../src/Cardano';

const rewardAccount = RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr');
const stakeKeyHash = 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f';
const poolId = PoolId('pool1ev8vy6fyj7693ergzty2t0azjvw35tvkt2vcjwpgajqs7z6u2vn');

describe('Certificate', () => {
  describe('createStakeKeyRegistrationCert', () => {
    it('can create a stake key registration certificate', () => {
      const cert = createStakeKeyRegistrationCert(rewardAccount);
      expect(cert).toEqual({
        __typename: CertificateType.StakeKeyRegistration,
        stakeKeyHash
      });
    });
  });

  describe('createStakeKeyDeregistrationCert', () => {
    it('can create a stake key de-registration certificate', () => {
      const cert = createStakeKeyDeregistrationCert(rewardAccount);
      expect(cert).toEqual({
        __typename: CertificateType.StakeKeyDeregistration,
        stakeKeyHash
      });
    });
  });

  describe('createDelegationCert', () => {
    it('can get the policy ID component from the asset id', () => {
      const cert = createDelegationCert(rewardAccount, poolId);
      expect(cert).toEqual({
        __typename: CertificateType.StakeDelegation,
        poolId: 'pool1ev8vy6fyj7693ergzty2t0azjvw35tvkt2vcjwpgajqs7z6u2vn',
        stakeKeyHash
      });
    });
  });
});
