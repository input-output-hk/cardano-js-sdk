/* eslint-disable sonarjs/no-duplicate-string */
import { CSL, Cardano, SerializationError, coreToCsl, cslToCore } from '../../src';
import { metadataJson, ownerRewardAccount, poolId, poolParameters, rewardAccount, stakeKey, vrf } from './testData';

describe('certificates', () => {
  describe('coreToCsl.certificate', () => {
    it('throws SerializationError with invalid stake key', () => {
      expect(() => coreToCsl.certificate.stakeKeyRegistration(poolId as unknown as Cardano.RewardAccount)).toThrowError(
        SerializationError
      );
    });

    it('stakeKeyRegistration', () =>
      expect(
        CSL.RewardAddress.new(
          1,
          coreToCsl.certificate.stakeKeyRegistration(stakeKey).as_stake_registration()!.stake_credential()
        )
          ?.to_address()
          .to_bech32()
      ).toBe(stakeKey));

    it('stakeKeyDeregistration', () =>
      expect(
        CSL.RewardAddress.new(
          1,
          coreToCsl.certificate.stakeKeyDeregistration(stakeKey).as_stake_deregistration()!.stake_credential()
        )
          ?.to_address()
          .to_bech32()
      ).toBe(stakeKey));

    it('stakeDelegation', () => {
      const delegation = coreToCsl.certificate.stakeDelegation(stakeKey, poolId).as_stake_delegation()!;
      expect(CSL.RewardAddress.new(1, delegation.stake_credential()).to_address().to_bech32()).toBe(stakeKey);
      expect(delegation.pool_keyhash().to_bech32('pool')).toBe(poolId);
    });

    it('poolRegistration', () => {
      const params = coreToCsl.certificate.poolRegistration(poolParameters).as_pool_registration()!.pool_params();
      expect(params.cost().to_str()).toBe('1000');
      expect(params.pledge().to_str()).toBe('10000');
      const margin = params.margin();
      expect(margin.numerator().to_str()).toBe('1');
      expect(margin.denominator().to_str()).toBe('5');
      const owners = params.pool_owners();
      expect(owners.len()).toBe(1);
      expect(
        CSL.RewardAddress.new(1, CSL.StakeCredential.from_keyhash(owners.get(0)))
          .to_address()
          .to_bech32()
      ).toBe(ownerRewardAccount);
      expect(params.operator().to_bech32('pool')).toBe(poolId);
      const relays = params.relays();
      expect(relays.len()).toBe(3);
      expect(Buffer.from(params.vrf_keyhash().to_bytes()).toString('hex')).toBe(vrf);
      expect(params.reward_account().to_address().to_bech32('stake')).toBe(rewardAccount);
      const metadata = params.pool_metadata()!;
      expect(metadata.url().url()).toBe(metadataJson.url);
      expect(Buffer.from(metadata.pool_metadata_hash().to_bytes()).toString('hex')).toBe(metadataJson.hash);
    });

    it('poolRetirement', () => {
      const retirement = coreToCsl.certificate.poolRetirement(poolId, 1000).as_pool_retirement()!;
      expect(retirement.pool_keyhash().to_bech32('pool')).toEqual(poolId);
      expect(retirement.epoch()).toEqual(1000);
    });
  });

  describe('cslToCore.certificate', () => {
    it('poolRegistration', () => {
      const cert = cslToCore.certificate.createCertificate(
        coreToCsl.certificate.poolRegistration(poolParameters)
      ) as Cardano.PoolRegistrationCertificate;
      expect(cert.poolParameters).toEqual(poolParameters);
    });
  });
});
