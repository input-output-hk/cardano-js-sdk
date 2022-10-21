import { CSL } from '../CSL';
import {
  Certificate,
  CertificateType,
  Ed25519KeyHash,
  GenesisKeyDelegationCertificate,
  PoolId,
  PoolMetadataJson,
  PoolRegistrationCertificate,
  PoolRetirementCertificate,
  Relay,
  RewardAccount,
  StakeAddressCertificate,
  StakeDelegationCertificate,
  VrfVkHex
} from '../../Cardano/types';
import { Hash32ByteBase16 } from '../../Cardano/util/primitives';
import { NetworkId } from '../../Cardano/NetworkId';
import { NotImplementedError, SerializationError, SerializationFailure } from '../../errors';
import { usingAutoFree } from '@cardano-sdk/util';

const stakeRegistration = (certificate: CSL.StakeRegistration): StakeAddressCertificate =>
  usingAutoFree((scope) => ({
    __typename: CertificateType.StakeKeyRegistration,
    stakeKeyHash: Ed25519KeyHash(
      Buffer.from(scope.manage(scope.manage(certificate.stake_credential()).to_keyhash())!.to_bytes()).toString('hex')
    )
  }));

const stakeDeregistration = (certificate: CSL.StakeDeregistration): StakeAddressCertificate =>
  usingAutoFree((scope) => ({
    __typename: CertificateType.StakeKeyDeregistration,
    stakeKeyHash: Ed25519KeyHash(
      Buffer.from(scope.manage(scope.manage(certificate.stake_credential()).to_keyhash())!.to_bytes()).toString('hex')
    )
  }));

const stakeDelegation = (certificate: CSL.StakeDelegation): StakeDelegationCertificate =>
  usingAutoFree((scope) => ({
    __typename: CertificateType.StakeDelegation,
    poolId: PoolId(scope.manage(certificate.pool_keyhash()).to_bech32('pool')),
    stakeKeyHash: Ed25519KeyHash(
      Buffer.from(scope.manage(scope.manage(certificate.stake_credential()).to_keyhash())!.to_bytes()).toString('hex')
    )
  }));

const createCardanoRelays = (relays: CSL.Relays): Relay[] =>
  usingAutoFree((scope) => {
    const result: Relay[] = [];
    for (let i = 0; i < relays.len(); i++) {
      const relay = scope.manage(relays.get(i));
      const relayByAddress = scope.manage(relay.as_single_host_addr());
      const relayByName = scope.manage(relay.as_single_host_name());
      const relayByNameMultihost = scope.manage(relay.as_multi_host_name());

      if (relayByAddress) {
        // RelayByAddress
        result.push({
          __typename: 'RelayByAddress',
          ipv4: scope.manage(relayByAddress.ipv4())?.ip().join('.'),
          ipv6: scope.manage(relayByAddress.ipv6())?.ip().join('.'),
          port: relayByAddress.port()
        });
      }
      if (relayByName) {
        // RelayByName
        result.push({
          __typename: 'RelayByName',
          hostname: scope.manage(relayByName.dns_name()).record(),
          port: relayByName.port()
        });
      }
      if (relayByNameMultihost) {
        // RelayByNameMultihost
        result.push({
          __typename: 'RelayByNameMultihost',
          dnsName: scope.manage(relayByNameMultihost.dns_name()).record()
        });
      }
    }
    return result;
  });

const createCardanoOwners = (owners: CSL.Ed25519KeyHashes, networkId: NetworkId): RewardAccount[] =>
  usingAutoFree((scope) => {
    const result: RewardAccount[] = [];
    for (let i = 0; i < owners.len(); i++) {
      const keyHash = scope.manage(owners.get(i));
      const stakeCredential = scope.manage(CSL.StakeCredential.from_keyhash(keyHash));
      const rewardAccount = scope.manage(CSL.RewardAddress.new(networkId, stakeCredential));
      result.push(RewardAccount(scope.manage(rewardAccount.to_address()).to_bech32()));
    }
    return result;
  });

const jsonMetadata = (poolMetadata?: CSL.PoolMetadata): PoolMetadataJson | undefined =>
  usingAutoFree((scope) => {
    if (!poolMetadata) return;
    return {
      hash: Hash32ByteBase16(Buffer.from(scope.manage(poolMetadata.pool_metadata_hash()).to_bytes()).toString('hex')),
      url: scope.manage(poolMetadata.url()).url()
    };
  });

export const poolRegistration = (certificate: CSL.PoolRegistration): PoolRegistrationCertificate =>
  usingAutoFree((scope) => {
    const poolParams = scope.manage(certificate.pool_params());
    const rewardAccountAddress = scope.manage(scope.manage(poolParams.reward_account()).to_address());
    return {
      __typename: CertificateType.PoolRegistration,
      poolParameters: {
        cost: BigInt(scope.manage(poolParams.cost()).to_str()),
        id: PoolId(scope.manage(poolParams.operator()).to_bech32('pool')),
        margin: {
          denominator: Number(scope.manage(scope.manage(poolParams.margin()).denominator()).to_str()),
          numerator: Number(scope.manage(scope.manage(poolParams.margin()).numerator()).to_str())
        },
        metadataJson: jsonMetadata(scope.manage(poolParams.pool_metadata())),
        owners: createCardanoOwners(scope.manage(poolParams.pool_owners()), rewardAccountAddress.network_id()),
        pledge: BigInt(scope.manage(poolParams.pledge()).to_str()),
        relays: createCardanoRelays(scope.manage(poolParams.relays())),
        rewardAccount: RewardAccount(rewardAccountAddress.to_bech32()),
        vrf: VrfVkHex(Buffer.from(scope.manage(poolParams.vrf_keyhash()).to_bytes()).toString('hex'))
      }
    } as PoolRegistrationCertificate;
  });

const poolRetirement = (certificate: CSL.PoolRetirement): PoolRetirementCertificate =>
  usingAutoFree((scope) => ({
    __typename: CertificateType.PoolRetirement,
    epoch: certificate.epoch(),
    poolId: PoolId(scope.manage(certificate.pool_keyhash()).to_bech32('pool'))
  }));

const genesisKeyDelegaation = (certificate: CSL.GenesisKeyDelegation): GenesisKeyDelegationCertificate =>
  usingAutoFree((scope) => ({
    __typename: CertificateType.GenesisKeyDelegation,
    genesisDelegateHash: Hash32ByteBase16(
      Buffer.from(scope.manage(certificate.genesis_delegate_hash()).to_bytes()).toString()
    ),
    genesisHash: Hash32ByteBase16(Buffer.from(scope.manage(certificate.genesishash()).to_bytes()).toString()),
    vrfKeyHash: Hash32ByteBase16(Buffer.from(scope.manage(certificate.vrf_keyhash()).to_bytes()).toString())
  }));

export const createCertificate = (cslCertificate: CSL.Certificate): Certificate =>
  usingAutoFree((scope) => {
    switch (cslCertificate.kind()) {
      case CSL.CertificateKind.StakeRegistration:
        return stakeRegistration(scope.manage(cslCertificate.as_stake_registration()!));
      case CSL.CertificateKind.StakeDeregistration:
        return stakeDeregistration(scope.manage(cslCertificate.as_stake_deregistration()!));
      case CSL.CertificateKind.StakeDelegation:
        return stakeDelegation(scope.manage(cslCertificate.as_stake_delegation()!));
      case CSL.CertificateKind.PoolRegistration:
        return poolRegistration(scope.manage(cslCertificate.as_pool_registration()!));
      case CSL.CertificateKind.PoolRetirement:
        return poolRetirement(scope.manage(cslCertificate.as_pool_retirement()!));
      case CSL.CertificateKind.GenesisKeyDelegation:
        return genesisKeyDelegaation(scope.manage(cslCertificate.as_genesis_key_delegation()!));
      case CSL.CertificateKind.MoveInstantaneousRewardsCert:
        throw new NotImplementedError('MIR certificate conversion'); // TODO: support this certificate type
      default:
        throw new SerializationError(SerializationFailure.InvalidType);
    }
  });
