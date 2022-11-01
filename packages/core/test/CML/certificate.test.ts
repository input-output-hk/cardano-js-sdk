/* eslint-disable sonarjs/no-duplicate-string */
import { CML, Cardano, cmlToCore, coreToCml } from '../../src';
import { ManagedFreeableScope } from '@cardano-sdk/util';
import { metadataJson, ownerRewardAccount, poolId, poolParameters, rewardAccount, stakeKeyHash, vrf } from './testData';

describe('certificates', () => {
  let scope: ManagedFreeableScope;

  beforeEach(() => {
    scope = new ManagedFreeableScope();
  });

  afterEach(() => {
    scope.dispose();
  });

  describe('coreToCml.certificate', () => {
    it('stakeKeyRegistration', () => {
      const certificate = coreToCml.certificate.stakeKeyRegistration(scope, stakeKeyHash);
      const registration = scope.manage(certificate.as_stake_registration())!;
      const stakeCredential = scope.manage(registration.stake_credential());
      const rewardAddress = scope.manage(CML.RewardAddress.new(1, stakeCredential));
      const cmlAddress = scope.manage(rewardAddress.to_address());
      expect(cmlAddress.to_bech32()).toBe(rewardAccount);
    });

    it('stakeKeyDeregistration', () => {
      const certificate = coreToCml.certificate.stakeKeyDeregistration(scope, stakeKeyHash);
      const deregistration = scope.manage(certificate.as_stake_deregistration())!;
      const stakeCredential = scope.manage(deregistration.stake_credential());
      const rewardAddress = scope.manage(CML.RewardAddress.new(1, stakeCredential));
      const cmlAddress = scope.manage(rewardAddress.to_address());
      expect(cmlAddress.to_bech32()).toBe(rewardAccount);
    });

    it('stakeDelegation', () => {
      const certificate = coreToCml.certificate.stakeDelegation(scope, stakeKeyHash, poolId);
      const delegation = scope.manage(certificate.as_stake_delegation())!;
      const poolKeyHash = scope.manage(delegation.pool_keyhash());
      const stakeCredential = scope.manage(delegation.stake_credential());
      const rewardAddress = scope.manage(CML.RewardAddress.new(1, stakeCredential));
      const cmlAddress = rewardAddress.to_address();
      expect(cmlAddress.to_bech32()).toBe(rewardAccount);
      expect(poolKeyHash.to_bech32('pool')).toBe(poolId);
    });

    // eslint-disable-next-line max-statements
    it('poolRegistration', () => {
      const certificate = coreToCml.certificate.poolRegistration(scope, poolParameters);
      const poolRegistration = scope.manage(certificate.as_pool_registration())!;
      const params = scope.manage(poolRegistration.pool_params());
      const poolRewardAccount = scope.manage(params.reward_account());
      const poolRewardAccountcmlAddress = scope.manage(poolRewardAccount.to_address());
      const operator = scope.manage(params.operator());
      const relays = scope.manage(params.relays());
      const vrfKeyHash = scope.manage(params.vrf_keyhash());
      const cost = scope.manage(params.cost());
      const pledge = scope.manage(params.pledge());
      const margin = scope.manage(params.margin());
      const owners = scope.manage(params.pool_owners());
      const owner = scope.manage(owners.get(0));
      const stakeCredential = scope.manage(CML.StakeCredential.from_keyhash(owner));
      const rewardAddress = scope.manage(CML.RewardAddress.new(1, stakeCredential));
      const cmlAddress = scope.manage(rewardAddress.to_address());
      const metadata = scope.manage(params.pool_metadata())!;
      const metadataUrl = scope.manage(metadata.url());
      const metadataHash = scope.manage(metadata.pool_metadata_hash());

      expect(cost.to_str()).toBe('1000');
      expect(pledge.to_str()).toBe('10000');
      expect(scope.manage(margin.numerator()).to_str()).toBe('1');
      expect(scope.manage(margin.denominator()).to_str()).toBe('5');
      expect(owners.len()).toBe(1);
      expect(cmlAddress.to_bech32()).toBe(ownerRewardAccount);
      expect(operator.to_bech32('pool')).toBe(poolId);
      expect(relays.len()).toBe(3);
      expect(Buffer.from(vrfKeyHash.to_bytes()).toString('hex')).toBe(vrf);
      expect(poolRewardAccountcmlAddress.to_bech32('stake')).toBe(rewardAccount);
      expect(metadataUrl.url()).toBe(metadataJson.url);
      expect(Buffer.from(metadataHash.to_bytes()).toString('hex')).toBe(metadataJson.hash);
    });

    it('poolRetirement', () => {
      const retirement = scope.manage(coreToCml.certificate.poolRetirement(scope, poolId, 1000).as_pool_retirement())!;
      const poolKeyHash = scope.manage(retirement.pool_keyhash());
      expect(poolKeyHash.to_bech32('pool')).toEqual(poolId);
      expect(retirement.epoch()).toEqual(1000);
    });
  });

  describe('cmlToCore.certificate', () => {
    it('stakeKeyRegistration', () => {
      const cert = cmlToCore.certificate.createCertificate(
        coreToCml.certificate.stakeKeyRegistration(scope, stakeKeyHash)
      ) as Cardano.StakeAddressCertificate;
      expect(cert.__typename).toBe(Cardano.CertificateType.StakeKeyRegistration);
      expect(cert.stakeKeyHash).toBe(stakeKeyHash);
    });

    it('stakeKeyDeregistration', () => {
      const cert = cmlToCore.certificate.createCertificate(
        coreToCml.certificate.stakeKeyDeregistration(scope, stakeKeyHash)
      ) as Cardano.StakeAddressCertificate;
      expect(cert.__typename).toBe(Cardano.CertificateType.StakeKeyDeregistration);
      expect(cert.stakeKeyHash).toBe(stakeKeyHash);
    });

    it('stakeDelegation', () => {
      const cert = cmlToCore.certificate.createCertificate(
        coreToCml.certificate.stakeDelegation(scope, stakeKeyHash, poolId)
      ) as Cardano.StakeDelegationCertificate;
      expect(cert.stakeKeyHash).toBe(stakeKeyHash);
      expect(cert.poolId).toBe(poolId);
    });

    it('poolRegistration', () => {
      const cert = cmlToCore.certificate.createCertificate(
        coreToCml.certificate.poolRegistration(scope, poolParameters)
      ) as Cardano.PoolRegistrationCertificate;
      expect(cert.poolParameters).toEqual(poolParameters);
    });

    it('poolRetirement', () => {
      const cert = cmlToCore.certificate.createCertificate(
        coreToCml.certificate.poolRetirement(scope, poolId, 1000)
      ) as Cardano.PoolRetirementCertificate;
      expect(cert.poolId).toEqual(poolId);
      expect(cert.epoch).toEqual(1000);
    });
  });
});
