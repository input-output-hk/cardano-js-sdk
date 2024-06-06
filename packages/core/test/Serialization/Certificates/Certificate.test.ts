/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { Certificate } from '../../../src/Serialization/index.js';
import { HexBlob } from '@cardano-sdk/util';

const poolParameters: Cardano.PoolParameters = {
  cost: 1000n,
  id: Cardano.PoolId('pool1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumheygxmn34'),
  margin: { denominator: 5, numerator: 1 },
  metadataJson: {
    hash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
    url: 'https://example.com'
  },
  owners: [Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr')],
  pledge: 10_000n,
  relays: [
    { __typename: 'RelayByName', hostname: 'example.com', port: 5000 },
    {
      __typename: 'RelayByAddress',
      ipv4: '127.0.0.1',
      port: 6000
    },
    { __typename: 'RelayByNameMultihost', dnsName: 'example.com' }
  ],
  rewardAccount: Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr'),
  vrf: Cardano.VrfVkHex('8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0')
};

// Test data used in the following tests was generated with the cardano-serialization-lib
describe('Certificate', () => {
  describe('StakeRegistration', () => {
    it('can decode StakeRegistration from CBOR', () => {
      const cbor = HexBlob('82008200581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f');

      const certificate = Certificate.fromCbor(cbor);

      expect(certificate.asGenesisKeyDelegation()).toBeUndefined();
      expect(certificate.asMoveInstantaneousRewardsCert()).toBeUndefined();
      expect(certificate.asStakeDelegation()).toBeUndefined();
      expect(certificate.asPoolRegistration()).toBeUndefined();
      expect(certificate.asPoolRetirement()).toBeUndefined();
      expect(certificate.asStakeDeregistration()).toBeUndefined();
      expect(certificate.asStakeRegistration()!.stakeCredential()).toEqual({
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

      const certificate = Certificate.fromCore(core);

      expect(certificate.asGenesisKeyDelegation()).toBeUndefined();
      expect(certificate.asMoveInstantaneousRewardsCert()).toBeUndefined();
      expect(certificate.asStakeDelegation()).toBeUndefined();
      expect(certificate.asPoolRegistration()).toBeUndefined();
      expect(certificate.asPoolRetirement()).toBeUndefined();
      expect(certificate.asStakeDeregistration()).toBeUndefined();
      expect(certificate.asStakeRegistration()!.stakeCredential()).toEqual({
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

      const certificate = Certificate.fromCore(core);

      expect(certificate.toCbor()).toEqual('82008200581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f');
    });

    it('can encode StakeRegistration to Core', () => {
      const cbor = HexBlob('82008200581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f');

      const certificate = Certificate.fromCbor(cbor);

      expect(certificate.toCore()).toEqual({
        __typename: Cardano.CertificateType.StakeRegistration,
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16('cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f'),
          type: Cardano.CredentialType.KeyHash
        }
      });
    });
  });

  describe('StakeDeregistration', () => {
    it('can decode StakeDeregistration from CBOR', () => {
      const cbor = HexBlob('82018200581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f');

      const certificate = Certificate.fromCbor(cbor);

      expect(certificate.asGenesisKeyDelegation()).toBeUndefined();
      expect(certificate.asMoveInstantaneousRewardsCert()).toBeUndefined();
      expect(certificate.asStakeDelegation()).toBeUndefined();
      expect(certificate.asPoolRegistration()).toBeUndefined();
      expect(certificate.asPoolRetirement()).toBeUndefined();
      expect(certificate.asStakeRegistration()).toBeUndefined();
      expect(certificate.asStakeDeregistration()!.stakeCredential()).toEqual({
        hash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
        type: Cardano.CredentialType.KeyHash
      });
    });

    it('can decode StakeDeregistration from Core', () => {
      const core: Cardano.StakeAddressCertificate = {
        __typename: Cardano.CertificateType.StakeDeregistration,
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16('cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f'),
          type: Cardano.CredentialType.KeyHash
        }
      };

      const certificate = Certificate.fromCore(core);

      expect(certificate.asGenesisKeyDelegation()).toBeUndefined();
      expect(certificate.asMoveInstantaneousRewardsCert()).toBeUndefined();
      expect(certificate.asStakeDelegation()).toBeUndefined();
      expect(certificate.asPoolRegistration()).toBeUndefined();
      expect(certificate.asPoolRetirement()).toBeUndefined();
      expect(certificate.asStakeRegistration()).toBeUndefined();
      expect(certificate.asStakeDeregistration()!.stakeCredential()).toEqual({
        hash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
        type: Cardano.CredentialType.KeyHash
      });
    });

    it('can encode StakeDeregistration to CBOR', () => {
      const core: Cardano.StakeAddressCertificate = {
        __typename: Cardano.CertificateType.StakeDeregistration,
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16('cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f'),
          type: Cardano.CredentialType.KeyHash
        }
      };

      const certificate = Certificate.fromCore(core);

      expect(certificate.toCbor()).toEqual('82018200581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f');
    });

    it('can encode StakeDeregistration to Core', () => {
      const cbor = HexBlob('82018200581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f');

      const certificate = Certificate.fromCbor(cbor);

      expect(certificate.toCore()).toEqual({
        __typename: Cardano.CertificateType.StakeDeregistration,
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16('cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f'),
          type: Cardano.CredentialType.KeyHash
        }
      });
    });
  });

  describe('StakeDelegation', () => {
    it('can decode StakeDelegation from CBOR', () => {
      const cbor = HexBlob(
        '83028200581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f581cd85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef92'
      );

      const certificate = Certificate.fromCbor(cbor);

      expect(certificate.asGenesisKeyDelegation()).toBeUndefined();
      expect(certificate.asMoveInstantaneousRewardsCert()).toBeUndefined();
      expect(certificate.asPoolRegistration()).toBeUndefined();
      expect(certificate.asPoolRetirement()).toBeUndefined();
      expect(certificate.asStakeRegistration()).toBeUndefined();
      expect(certificate.asStakeDeregistration()).toBeUndefined();
      expect(certificate.asStakeDelegation()!.stakeCredential()).toEqual({
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

      const certificate = Certificate.fromCore(core);

      expect(certificate.asGenesisKeyDelegation()).toBeUndefined();
      expect(certificate.asMoveInstantaneousRewardsCert()).toBeUndefined();
      expect(certificate.asPoolRegistration()).toBeUndefined();
      expect(certificate.asPoolRetirement()).toBeUndefined();
      expect(certificate.asStakeRegistration()).toBeUndefined();
      expect(certificate.asStakeDeregistration()).toBeUndefined();
      expect(certificate.asStakeDelegation()!.stakeCredential()).toEqual({
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

      const certificate = Certificate.fromCore(core);

      expect(certificate.toCbor()).toEqual(
        '83028200581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f581cd85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef92'
      );
    });

    it('can encode StakeDelegation to Core', () => {
      const cbor = HexBlob(
        '83028200581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f581cd85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef92'
      );

      const certificate = Certificate.fromCbor(cbor);

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

  describe('PoolRetirement', () => {
    it('can decode PoolRetirement from CBOR', () => {
      const cbor = HexBlob('8304581cd85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef921903e8');

      const certificate = Certificate.fromCbor(cbor);

      expect(certificate.asGenesisKeyDelegation()).toBeUndefined();
      expect(certificate.asMoveInstantaneousRewardsCert()).toBeUndefined();
      expect(certificate.asPoolRegistration()).toBeUndefined();
      expect(certificate.asStakeRegistration()).toBeUndefined();
      expect(certificate.asStakeDeregistration()).toBeUndefined();
      expect(certificate.asStakeDelegation()).toBeUndefined();

      expect(certificate.asPoolRetirement()!.epoch()).toEqual(1000);
      expect(certificate.asPoolRetirement()!.poolKeyHash()).toEqual(
        'd85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef92'
      );
    });

    it('can decode PoolRetirement from Core', () => {
      const core: Cardano.PoolRetirementCertificate = {
        __typename: Cardano.CertificateType.PoolRetirement,
        epoch: Cardano.EpochNo(1000),
        poolId: Cardano.PoolId('pool1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumheygxmn34')
      };

      const certificate = Certificate.fromCore(core);

      expect(certificate.asGenesisKeyDelegation()).toBeUndefined();
      expect(certificate.asMoveInstantaneousRewardsCert()).toBeUndefined();
      expect(certificate.asPoolRegistration()).toBeUndefined();
      expect(certificate.asStakeRegistration()).toBeUndefined();
      expect(certificate.asStakeDeregistration()).toBeUndefined();
      expect(certificate.asStakeDelegation()).toBeUndefined();
      expect(certificate.asPoolRetirement()!.epoch()).toEqual(1000);
      expect(certificate.asPoolRetirement()!.poolKeyHash()).toEqual(
        'd85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef92'
      );
    });

    it('can encode PoolRetirement to CBOR', () => {
      const core: Cardano.PoolRetirementCertificate = {
        __typename: Cardano.CertificateType.PoolRetirement,
        epoch: Cardano.EpochNo(1000),
        poolId: Cardano.PoolId('pool1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumheygxmn34')
      };

      const certificate = Certificate.fromCore(core);

      expect(certificate.toCbor()).toEqual('8304581cd85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef921903e8');
    });

    it('can encode PoolRetirement to Core', () => {
      const cbor = HexBlob('8304581cd85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef921903e8');

      const certificate = Certificate.fromCbor(cbor);

      expect(certificate.toCore()).toEqual({
        __typename: Cardano.CertificateType.PoolRetirement,
        epoch: Cardano.EpochNo(1000),
        poolId: Cardano.PoolId('pool1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumheygxmn34')
      });
    });
  });

  describe('PoolRegistration', () => {
    it('can decode PoolRegistration from CBOR', () => {
      const cbor = HexBlob(
        '8a03581cd85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef9258208dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db01927101903e8d81e820105581de1cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f81581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f8383011913886b6578616d706c652e636f6d8400191770447f000001f682026b6578616d706c652e636f6d827368747470733a2f2f6578616d706c652e636f6d58200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
      );

      const certificate = Certificate.fromCbor(cbor);

      expect(certificate.asGenesisKeyDelegation()).toBeUndefined();
      expect(certificate.asMoveInstantaneousRewardsCert()).toBeUndefined();
      expect(certificate.asPoolRetirement()).toBeUndefined();
      expect(certificate.asStakeRegistration()).toBeUndefined();
      expect(certificate.asStakeDeregistration()).toBeUndefined();
      expect(certificate.asStakeDelegation()).toBeUndefined();
      const params = certificate.asPoolRegistration()!.poolParameters();

      expect(params.operator()).toEqual(
        Cardano.PoolId.toKeyHash(Cardano.PoolId('pool1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumheygxmn34'))
      );
      expect(params.vrfKeyHash()).toEqual(
        Cardano.VrfVkHex('8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0')
      );
      expect(params.pledge()).toEqual(10_000n);
      expect(params.cost()).toEqual(1000n);
      expect(params.margin().toCore()).toEqual({ denominator: 5, numerator: 1 });
      expect(params.rewardAccount().toAddress().toBech32()).toEqual(
        Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr')
      );
      expect(
        params
          .poolOwners()
          .toCore()
          .map((keyHash) => Cardano.createRewardAccount(keyHash, params.rewardAccount().toAddress().getNetworkId()))
      ).toEqual([Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr')]);
      expect(params.relays().map((relay) => relay.toCore())).toEqual([
        { __typename: 'RelayByName', hostname: 'example.com', port: 5000 },
        {
          __typename: 'RelayByAddress',
          ipv4: '127.0.0.1',
          port: 6000
        },
        { __typename: 'RelayByNameMultihost', dnsName: 'example.com' }
      ]);
      expect(params.poolMetadata()?.toCore()).toEqual({
        hash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
        url: 'https://example.com'
      });
    });

    it('can decode PoolRegistration from Core', () => {
      const core: Cardano.PoolRegistrationCertificate = {
        __typename: Cardano.CertificateType.PoolRegistration,
        poolParameters
      };

      const certificate = Certificate.fromCore(core);

      expect(certificate.asGenesisKeyDelegation()).toBeUndefined();
      expect(certificate.asMoveInstantaneousRewardsCert()).toBeUndefined();
      expect(certificate.asPoolRetirement()).toBeUndefined();
      expect(certificate.asStakeRegistration()).toBeUndefined();
      expect(certificate.asStakeDeregistration()).toBeUndefined();
      expect(certificate.asStakeDelegation()).toBeUndefined();
      const params = certificate.asPoolRegistration()!.poolParameters();

      expect(params.operator()).toEqual(
        Cardano.PoolId.toKeyHash(Cardano.PoolId('pool1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumheygxmn34'))
      );
      expect(params.vrfKeyHash()).toEqual(
        Cardano.VrfVkHex('8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0')
      );
      expect(params.pledge()).toEqual(10_000n);
      expect(params.cost()).toEqual(1000n);
      expect(params.margin().toCore()).toEqual({ denominator: 5, numerator: 1 });
      expect(params.rewardAccount().toAddress().toBech32()).toEqual(
        Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr')
      );
      expect(
        params
          .poolOwners()
          .toCore()
          .map((keyHash) => Cardano.createRewardAccount(keyHash, params.rewardAccount().toAddress().getNetworkId()))
      ).toEqual([Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr')]);
      expect(params.relays().map((relay) => relay.toCore())).toEqual([
        { __typename: 'RelayByName', hostname: 'example.com', port: 5000 },
        {
          __typename: 'RelayByAddress',
          ipv4: '127.0.0.1',
          port: 6000
        },
        { __typename: 'RelayByNameMultihost', dnsName: 'example.com' }
      ]);
      expect(params.poolMetadata()?.toCore()).toEqual({
        hash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
        url: 'https://example.com'
      });
    });

    it('can encode PoolRegistration to CBOR', () => {
      const core: Cardano.PoolRegistrationCertificate = {
        __typename: Cardano.CertificateType.PoolRegistration,
        poolParameters
      };

      const certificate = Certificate.fromCore(core);

      expect(certificate.toCbor()).toEqual(
        '8a03581cd85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef9258208dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db01927101903e8d81e820105581de1cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f81581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f8383011913886b6578616d706c652e636f6d8400191770447f000001f682026b6578616d706c652e636f6d827368747470733a2f2f6578616d706c652e636f6d58200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
      );
    });

    it('can encode PoolRegistration to Core', () => {
      const cbor = HexBlob(
        '8a03581cd85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef9258208dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db01927101903e8d81e820105581de1cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f81581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f8383011913886b6578616d706c652e636f6d8400191770447f000001f682026b6578616d706c652e636f6d827368747470733a2f2f6578616d706c652e636f6d58200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
      );

      const certificate = Certificate.fromCbor(cbor);

      expect(certificate.toCore()).toEqual({
        __typename: Cardano.CertificateType.PoolRegistration,
        poolParameters
      });
    });
  });

  describe('MoveInstantaneousReward', () => {
    describe('toOtherPot', () => {
      it('can decode toOtherPot MoveInstantaneousReward from CBOR', () => {
        const cborUseReserves = HexBlob('820682001a000f4240');
        const cborUseTreasury = HexBlob('820682011a000f4240');

        const certUseReserves = Certificate.fromCbor(cborUseReserves);
        const certUseTreasury = Certificate.fromCbor(cborUseTreasury);

        expect(certUseReserves.asMoveInstantaneousRewardsCert()!.asToOtherPot()?.pot()).toEqual(
          Cardano.MirCertificatePot.Reserves
        );
        expect(certUseReserves.asMoveInstantaneousRewardsCert()!.asToOtherPot()?.getAmount()).toEqual(1_000_000n);
        expect(certUseTreasury.asMoveInstantaneousRewardsCert()!.asToOtherPot()?.pot()).toEqual(
          Cardano.MirCertificatePot.Treasury
        );
        expect(certUseTreasury.asMoveInstantaneousRewardsCert()!.asToOtherPot()?.getAmount()).toEqual(1_000_000n);
      });

      it('can decode toOtherPot MoveInstantaneousReward from Core', () => {
        const coreUseReservers: Cardano.MirCertificate = {
          __typename: Cardano.CertificateType.MIR,
          kind: Cardano.MirCertificateKind.ToOtherPot,
          pot: Cardano.MirCertificatePot.Reserves,
          quantity: 1_000_000n
        };

        const coreUseTreasury: Cardano.MirCertificate = {
          __typename: Cardano.CertificateType.MIR,
          kind: Cardano.MirCertificateKind.ToOtherPot,
          pot: Cardano.MirCertificatePot.Treasury,
          quantity: 1_000_000n
        };

        const certUseReserves = Certificate.fromCore(coreUseReservers);
        const certUseTreasury = Certificate.fromCore(coreUseTreasury);

        expect(certUseReserves.asMoveInstantaneousRewardsCert()!.asToOtherPot()?.pot()).toEqual(
          Cardano.MirCertificatePot.Reserves
        );
        expect(certUseReserves.asMoveInstantaneousRewardsCert()!.asToOtherPot()?.getAmount()).toEqual(1_000_000n);
        expect(certUseTreasury.asMoveInstantaneousRewardsCert()!.asToOtherPot()?.pot()).toEqual(
          Cardano.MirCertificatePot.Treasury
        );
        expect(certUseTreasury.asMoveInstantaneousRewardsCert()!.asToOtherPot()?.getAmount()).toEqual(1_000_000n);
      });

      it('can encode toOtherPot MoveInstantaneousReward to CBOR', () => {
        const coreUseReservers: Cardano.MirCertificate = {
          __typename: Cardano.CertificateType.MIR,
          kind: Cardano.MirCertificateKind.ToOtherPot,
          pot: Cardano.MirCertificatePot.Reserves,
          quantity: 1_000_000n
        };

        const coreUseTreasury: Cardano.MirCertificate = {
          __typename: Cardano.CertificateType.MIR,
          kind: Cardano.MirCertificateKind.ToOtherPot,
          pot: Cardano.MirCertificatePot.Treasury,
          quantity: 1_000_000n
        };

        const certUseReserves = Certificate.fromCore(coreUseReservers);
        const certUseTreasury = Certificate.fromCore(coreUseTreasury);

        expect(certUseReserves.toCbor()).toEqual('820682001a000f4240');
        expect(certUseTreasury.toCbor()).toEqual('820682011a000f4240');
      });

      it('can encode toOtherPot MoveInstantaneousReward to Core', () => {
        const cborUseReserves = HexBlob('820682001a000f4240');
        const cborUseTreasury = HexBlob('820682011a000f4240');

        const certUseReserves = Certificate.fromCbor(cborUseReserves);
        const certUseTreasury = Certificate.fromCbor(cborUseTreasury);

        expect(certUseReserves.toCore()).toEqual({
          __typename: Cardano.CertificateType.MIR,
          kind: Cardano.MirCertificateKind.ToOtherPot,
          pot: Cardano.MirCertificatePot.Reserves,
          quantity: 1_000_000n
        });

        expect(certUseTreasury.toCore()).toEqual({
          __typename: Cardano.CertificateType.MIR,
          kind: Cardano.MirCertificateKind.ToOtherPot,
          pot: Cardano.MirCertificatePot.Treasury,
          quantity: 1_000_000n
        });
      });
    });

    describe('toStakeCreds', () => {
      it('can decode toStakeCreds MoveInstantaneousReward from CBOR', () => {
        const cborUseReserves = HexBlob('82068200a18200581c0101010101010101010101010101010101010101010101010101010100');
        const cborUseTreasury = HexBlob('82068201a18200581c0101010101010101010101010101010101010101010101010101010100');

        const certUseReserves = Certificate.fromCbor(cborUseReserves);
        const certUseTreasury = Certificate.fromCbor(cborUseTreasury);

        expect(certUseReserves.asMoveInstantaneousRewardsCert()!.asToStakeCreds()?.pot()).toEqual(
          Cardano.MirCertificatePot.Reserves
        );
        expect(certUseReserves.asMoveInstantaneousRewardsCert()!.asToStakeCreds()?.getStakeCreds()).toEqual(
          new Map([
            [
              {
                hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
                type: Cardano.CredentialType.KeyHash
              },
              0n
            ]
          ])
        );
        expect(certUseTreasury.asMoveInstantaneousRewardsCert()!.asToStakeCreds()?.pot()).toEqual(
          Cardano.MirCertificatePot.Treasury
        );
        expect(certUseTreasury.asMoveInstantaneousRewardsCert()!.asToStakeCreds()?.getStakeCreds()).toEqual(
          new Map([
            [
              {
                hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
                type: Cardano.CredentialType.KeyHash
              },
              0n
            ]
          ])
        );
      });

      it('can decode toStakeCreds MoveInstantaneousReward from Core', () => {
        const coreUseReserves: Cardano.MirCertificate = {
          __typename: Cardano.CertificateType.MIR,
          kind: Cardano.MirCertificateKind.ToStakeCreds,
          pot: Cardano.MirCertificatePot.Reserves,
          quantity: 0n,
          stakeCredential: {
            hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
            type: Cardano.CredentialType.KeyHash
          }
        };

        const coreUseTreasury: Cardano.MirCertificate = {
          __typename: Cardano.CertificateType.MIR,
          kind: Cardano.MirCertificateKind.ToStakeCreds,
          pot: Cardano.MirCertificatePot.Treasury,
          quantity: 0n,
          stakeCredential: {
            hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
            type: Cardano.CredentialType.KeyHash
          }
        };

        const certUseReserves = Certificate.fromCore(coreUseReserves);
        const certUseTreasury = Certificate.fromCore(coreUseTreasury);

        expect(certUseReserves.asMoveInstantaneousRewardsCert()!.asToStakeCreds()?.pot()).toEqual(
          Cardano.MirCertificatePot.Reserves
        );
        expect(certUseReserves.asMoveInstantaneousRewardsCert()!.asToStakeCreds()?.getStakeCreds()).toEqual(
          new Map([
            [
              {
                hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
                type: Cardano.CredentialType.KeyHash
              },
              0n
            ]
          ])
        );
        expect(certUseTreasury.asMoveInstantaneousRewardsCert()!.asToStakeCreds()?.pot()).toEqual(
          Cardano.MirCertificatePot.Treasury
        );
        expect(certUseTreasury.asMoveInstantaneousRewardsCert()!.asToStakeCreds()?.getStakeCreds()).toEqual(
          new Map([
            [
              {
                hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
                type: Cardano.CredentialType.KeyHash
              },
              0n
            ]
          ])
        );
      });

      it('can encode toStakeCreds MoveInstantaneousReward to CBOR', () => {
        const coreUseReservers: Cardano.MirCertificate = {
          __typename: Cardano.CertificateType.MIR,
          kind: Cardano.MirCertificateKind.ToStakeCreds,
          pot: Cardano.MirCertificatePot.Reserves,
          quantity: 0n,
          stakeCredential: {
            hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
            type: Cardano.CredentialType.KeyHash
          }
        };

        const coreUseTreasury: Cardano.MirCertificate = {
          __typename: Cardano.CertificateType.MIR,
          kind: Cardano.MirCertificateKind.ToStakeCreds,
          pot: Cardano.MirCertificatePot.Treasury,
          quantity: 0n,
          stakeCredential: {
            hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
            type: Cardano.CredentialType.KeyHash
          }
        };

        const certUseReserves = Certificate.fromCore(coreUseReservers);
        const certUseTreasury = Certificate.fromCore(coreUseTreasury);

        expect(certUseReserves.toCbor()).toEqual(
          '82068200a18200581c0101010101010101010101010101010101010101010101010101010100'
        );
        expect(certUseTreasury.toCbor()).toEqual(
          '82068201a18200581c0101010101010101010101010101010101010101010101010101010100'
        );
      });

      it('can encode toStakeCreds MoveInstantaneousReward to Core', () => {
        const cborUseReserves = HexBlob('82068200a18200581c0101010101010101010101010101010101010101010101010101010100');
        const cborUseTreasury = HexBlob('82068201a18200581c0101010101010101010101010101010101010101010101010101010100');

        const certUseReserves = Certificate.fromCbor(cborUseReserves);
        const certUseTreasury = Certificate.fromCbor(cborUseTreasury);

        expect(certUseReserves.toCore()).toEqual({
          __typename: Cardano.CertificateType.MIR,
          kind: Cardano.MirCertificateKind.ToStakeCreds,
          pot: Cardano.MirCertificatePot.Reserves,
          quantity: 0n,
          stakeCredential: {
            hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
            type: Cardano.CredentialType.KeyHash
          }
        });

        expect(certUseTreasury.toCore()).toEqual({
          __typename: Cardano.CertificateType.MIR,
          kind: Cardano.MirCertificateKind.ToStakeCreds,
          pot: Cardano.MirCertificatePot.Treasury,
          quantity: 0n,
          stakeCredential: {
            hash: Crypto.Hash28ByteBase16('01010101010101010101010101010101010101010101010101010101'),
            type: Cardano.CredentialType.KeyHash
          }
        });
      });
    });
  });

  describe('GenesisKeyDelegation', () => {
    it('can decode GenesisKeyDelegation from CBOR', () => {
      const cbor = HexBlob(
        '8405581c00010001000100010001000100010001000100010001000100010001581c0002000200020002000200020002000200020002000200020002000258200003000300030003000300030003000300030003000300030003000300030003'
      );

      const certificate = Certificate.fromCbor(cbor);

      expect(certificate.asMoveInstantaneousRewardsCert()).toBeUndefined();
      expect(certificate.asPoolRetirement()).toBeUndefined();
      expect(certificate.asPoolRegistration()).toBeUndefined();
      expect(certificate.asStakeRegistration()).toBeUndefined();
      expect(certificate.asStakeDeregistration()).toBeUndefined();
      expect(certificate.asStakeDelegation()).toBeUndefined();
      expect(certificate.asGenesisKeyDelegation()!.genesisHash()).toEqual(
        '00010001000100010001000100010001000100010001000100010001'
      );
      expect(certificate.asGenesisKeyDelegation()!.genesisDelegateHash()).toEqual(
        '00020002000200020002000200020002000200020002000200020002'
      );
      expect(certificate.asGenesisKeyDelegation()!.vrfKeyHash()).toEqual(
        '0003000300030003000300030003000300030003000300030003000300030003'
      );
    });

    it('can decode GenesisKeyDelegation from Core', () => {
      const core: Cardano.GenesisKeyDelegationCertificate = {
        __typename: Cardano.CertificateType.GenesisKeyDelegation,
        genesisDelegateHash: Crypto.Hash28ByteBase16('00020002000200020002000200020002000200020002000200020002'),
        genesisHash: Crypto.Hash28ByteBase16('00010001000100010001000100010001000100010001000100010001'),
        vrfKeyHash: Crypto.Hash32ByteBase16('0003000300030003000300030003000300030003000300030003000300030003')
      };

      const certificate = Certificate.fromCore(core);

      expect(certificate.asMoveInstantaneousRewardsCert()).toBeUndefined();
      expect(certificate.asPoolRetirement()).toBeUndefined();
      expect(certificate.asPoolRegistration()).toBeUndefined();
      expect(certificate.asStakeRegistration()).toBeUndefined();
      expect(certificate.asStakeDeregistration()).toBeUndefined();
      expect(certificate.asStakeDelegation()).toBeUndefined();
      expect(certificate.asGenesisKeyDelegation()!.genesisHash()).toEqual(
        '00010001000100010001000100010001000100010001000100010001'
      );
      expect(certificate.asGenesisKeyDelegation()!.genesisDelegateHash()).toEqual(
        '00020002000200020002000200020002000200020002000200020002'
      );
      expect(certificate.asGenesisKeyDelegation()!.vrfKeyHash()).toEqual(
        '0003000300030003000300030003000300030003000300030003000300030003'
      );
    });

    it('can encode GenesisKeyDelegation to CBOR', () => {
      const core: Cardano.GenesisKeyDelegationCertificate = {
        __typename: Cardano.CertificateType.GenesisKeyDelegation,
        genesisDelegateHash: Crypto.Hash28ByteBase16('00020002000200020002000200020002000200020002000200020002'),
        genesisHash: Crypto.Hash28ByteBase16('00010001000100010001000100010001000100010001000100010001'),
        vrfKeyHash: Crypto.Hash32ByteBase16('0003000300030003000300030003000300030003000300030003000300030003')
      };

      const certificate = Certificate.fromCore(core);

      expect(certificate.toCbor()).toEqual(
        '8405581c00010001000100010001000100010001000100010001000100010001581c0002000200020002000200020002000200020002000200020002000258200003000300030003000300030003000300030003000300030003000300030003'
      );
    });

    it('can encode GenesisKeyDelegation to Core', () => {
      const cbor = HexBlob(
        '8405581c00010001000100010001000100010001000100010001000100010001581c0002000200020002000200020002000200020002000200020002000258200003000300030003000300030003000300030003000300030003000300030003'
      );

      const certificate = Certificate.fromCbor(cbor);

      expect(certificate.toCore()).toEqual({
        __typename: Cardano.CertificateType.GenesisKeyDelegation,
        genesisDelegateHash: Crypto.Hash28ByteBase16('00020002000200020002000200020002000200020002000200020002'),
        genesisHash: Crypto.Hash28ByteBase16('00010001000100010001000100010001000100010001000100010001'),
        vrfKeyHash: Crypto.Hash32ByteBase16('0003000300030003000300030003000300030003000300030003000300030003')
      });
    });
  });

  describe('StakeVoteDelegation', () => {
    it('can decode StakeVoteDelegation from CBOR', () => {
      const cbor = HexBlob(
        '840a8200581c00000000000000000000000000000000000000000000000000000000581c000000000000000000000000000000000000000000000000000000008200581c00000000000000000000000000000000000000000000000000000000'
      );

      const certificate = Certificate.fromCbor(cbor);

      expect(certificate.asMoveInstantaneousRewardsCert()).toBeUndefined();
      expect(certificate.asPoolRetirement()).toBeUndefined();
      expect(certificate.asPoolRegistration()).toBeUndefined();
      expect(certificate.asStakeRegistration()).toBeUndefined();
      expect(certificate.asStakeDeregistration()).toBeUndefined();
      expect(certificate.asStakeDelegation()).toBeUndefined();
      expect(certificate.asStakeVoteDelegationCert()!.drep().toKeyHash()).toEqual(
        '00000000000000000000000000000000000000000000000000000000'
      );
      expect(certificate.asStakeVoteDelegationCert()!.stakeCredential().hash).toEqual(
        '00000000000000000000000000000000000000000000000000000000'
      );
      expect(certificate.asStakeVoteDelegationCert()!.poolKeyHash()).toEqual(
        '00000000000000000000000000000000000000000000000000000000'
      );
    });

    it('can decode StakeVoteDelegation from Core', () => {
      const core: Cardano.StakeVoteDelegationCertificate = {
        __typename: Cardano.CertificateType.StakeVoteDelegation,
        dRep: {
          hash: '00000000000000000000000000000000000000000000000000000000',
          type: 0
        },
        poolId: 'pool1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq8a7a2d',
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
          type: Cardano.CredentialType.KeyHash
        }
      } as Cardano.StakeVoteDelegationCertificate;

      const certificate = Certificate.fromCore(core);

      expect(certificate.asMoveInstantaneousRewardsCert()).toBeUndefined();
      expect(certificate.asPoolRetirement()).toBeUndefined();
      expect(certificate.asPoolRegistration()).toBeUndefined();
      expect(certificate.asStakeRegistration()).toBeUndefined();
      expect(certificate.asStakeDeregistration()).toBeUndefined();
      expect(certificate.asStakeDelegation()).toBeUndefined();
      expect(certificate.asStakeVoteDelegationCert()!.drep().toCore()).toEqual({
        hash: '00000000000000000000000000000000000000000000000000000000',
        type: 0
      });
      expect(certificate.asStakeVoteDelegationCert()!.stakeCredential()).toEqual({
        hash: '00000000000000000000000000000000000000000000000000000000',
        type: 0
      });
      expect(certificate.asStakeVoteDelegationCert()!.poolKeyHash()).toEqual(
        '00000000000000000000000000000000000000000000000000000000'
      );
    });

    it('can encode StakeVoteDelegation to CBOR', () => {
      const core: Cardano.StakeVoteDelegationCertificate = {
        __typename: Cardano.CertificateType.StakeVoteDelegation,
        dRep: {
          hash: '00000000000000000000000000000000000000000000000000000000',
          type: 0
        },
        poolId: 'pool1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq8a7a2d',
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
          type: Cardano.CredentialType.KeyHash
        }
      } as Cardano.StakeVoteDelegationCertificate;

      const certificate = Certificate.fromCore(core);

      expect(certificate.toCbor()).toEqual(
        '840a8200581c00000000000000000000000000000000000000000000000000000000581c000000000000000000000000000000000000000000000000000000008200581c00000000000000000000000000000000000000000000000000000000'
      );
    });

    it('can encode StakeVoteDelegation to Core', () => {
      const cbor = HexBlob(
        '840a8200581c00000000000000000000000000000000000000000000000000000000581c000000000000000000000000000000000000000000000000000000008200581c00000000000000000000000000000000000000000000000000000000'
      );

      const certificate = Certificate.fromCbor(cbor);

      expect(certificate.toCore()).toEqual({
        __typename: Cardano.CertificateType.StakeVoteDelegation,
        dRep: {
          hash: '00000000000000000000000000000000000000000000000000000000',
          type: 0
        },
        poolId: 'pool1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq8a7a2d',
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
          type: Cardano.CredentialType.KeyHash
        }
      });
    });
  });
});
