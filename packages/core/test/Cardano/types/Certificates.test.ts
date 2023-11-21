import * as Cardano from '../../../src/Cardano';
import * as Crypto from '@cardano-sdk/crypto';
import {
  CertificateType,
  PoolId,
  RewardAccount,
  createDelegationCert,
  createStakeDeregistrationCert,
  createStakeRegistrationCert
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
});
