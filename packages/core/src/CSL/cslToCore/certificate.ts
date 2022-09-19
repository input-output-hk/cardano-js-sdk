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

const stakeRegistration = (certificate: CSL.StakeRegistration): StakeAddressCertificate => ({
  __typename: CertificateType.StakeKeyRegistration,
  stakeKeyHash: Ed25519KeyHash(Buffer.from(certificate.stake_credential().to_keyhash()!.to_bytes()).toString('hex'))
});

const stakeDeregistration = (certificate: CSL.StakeDeregistration): StakeAddressCertificate => ({
  __typename: CertificateType.StakeKeyDeregistration,
  stakeKeyHash: Ed25519KeyHash(Buffer.from(certificate.stake_credential().to_keyhash()!.to_bytes()).toString('hex'))
});

const stakeDelegation = (certificate: CSL.StakeDelegation): StakeDelegationCertificate => ({
  __typename: CertificateType.StakeDelegation,
  poolId: PoolId(certificate.pool_keyhash().to_bech32('pool')),
  stakeKeyHash: Ed25519KeyHash(Buffer.from(certificate.stake_credential().to_keyhash()!.to_bytes()).toString('hex'))
});

const createCardanoRelays = (relays: CSL.Relays): Relay[] => {
  const result: Relay[] = [];
  for (let i = 0; i < relays.len(); i++) {
    const relay = relays.get(i);
    const relayByAddress = relay.as_single_host_addr();
    const relayByName = relay.as_single_host_name();
    const relayByNameMultihost = relay.as_multi_host_name();

    if (relayByAddress) {
      // RelayByAddress
      result.push({
        __typename: 'RelayByAddress',
        ipv4: relayByAddress.ipv4()?.ip().join('.'),
        ipv6: relayByAddress.ipv6()?.ip().join('.'),
        port: relayByAddress.port()
      });
    }
    if (relayByName) {
      // RelayByName
      result.push({
        __typename: 'RelayByName',
        hostname: relayByName.dns_name().record(),
        port: relayByName.port()
      });
    }
    if (relayByNameMultihost) {
      // RelayByNameMultihost
      result.push({
        __typename: 'RelayByNameMultihost',
        dnsName: relayByNameMultihost.dns_name().record()
      });
    }
  }
  return result;
};

const createCardanoOwners = (owners: CSL.Ed25519KeyHashes, networkId: NetworkId): RewardAccount[] => {
  const result: RewardAccount[] = [];
  for (let i = 0; i < owners.len(); i++) {
    const keyHash = owners.get(i);
    const stakeCredential = CSL.StakeCredential.from_keyhash(keyHash);
    const rewardAccount = CSL.RewardAddress.new(networkId, stakeCredential);
    result.push(RewardAccount(rewardAccount.to_address().to_bech32()));
  }
  return result;
};

const jsonMetadata = (poolMetadata?: CSL.PoolMetadata): PoolMetadataJson | undefined => {
  if (!poolMetadata) return;
  return {
    hash: Hash32ByteBase16(Buffer.from(poolMetadata.pool_metadata_hash().to_bytes()).toString('hex')),
    url: poolMetadata.url().url()
  };
};

export const poolRegistration = (certificate: CSL.PoolRegistration): PoolRegistrationCertificate => {
  const poolParams = certificate.pool_params();
  const rewardAccountAddress = poolParams.reward_account().to_address();
  return {
    __typename: CertificateType.PoolRegistration,
    poolParameters: {
      cost: BigInt(poolParams.cost().to_str()),
      id: PoolId(poolParams.operator().to_bech32('pool')),
      margin: {
        denominator: Number(poolParams.margin().denominator().to_str()),
        numerator: Number(poolParams.margin().numerator().to_str())
      },
      metadataJson: jsonMetadata(poolParams.pool_metadata()),
      owners: createCardanoOwners(poolParams.pool_owners(), rewardAccountAddress.network_id()),
      pledge: BigInt(poolParams.pledge().to_str()),
      relays: createCardanoRelays(poolParams.relays()),
      rewardAccount: RewardAccount(rewardAccountAddress.to_bech32()),
      vrf: VrfVkHex(Buffer.from(poolParams.vrf_keyhash().to_bytes()).toString('hex'))
    }
  } as PoolRegistrationCertificate;
};

const poolRetirement = (certificate: CSL.PoolRetirement): PoolRetirementCertificate => ({
  __typename: CertificateType.PoolRetirement,
  epoch: certificate.epoch(),
  poolId: PoolId(certificate.pool_keyhash().to_bech32('pool'))
});

const genesisKeyDelegaation = (certificate: CSL.GenesisKeyDelegation): GenesisKeyDelegationCertificate => ({
  __typename: CertificateType.GenesisKeyDelegation,
  genesisDelegateHash: Hash32ByteBase16(Buffer.from(certificate.genesis_delegate_hash().to_bytes()).toString()),
  genesisHash: Hash32ByteBase16(Buffer.from(certificate.genesishash().to_bytes()).toString()),
  vrfKeyHash: Hash32ByteBase16(Buffer.from(certificate.vrf_keyhash().to_bytes()).toString())
});

export const createCertificate = (cslCertificate: CSL.Certificate): Certificate => {
  switch (cslCertificate.kind()) {
    case CSL.CertificateKind.StakeRegistration:
      return stakeRegistration(cslCertificate.as_stake_registration()!);
    case CSL.CertificateKind.StakeDeregistration:
      return stakeDeregistration(cslCertificate.as_stake_deregistration()!);
    case CSL.CertificateKind.StakeDelegation:
      return stakeDelegation(cslCertificate.as_stake_delegation()!);
    case CSL.CertificateKind.PoolRegistration:
      return poolRegistration(cslCertificate.as_pool_registration()!);
    case CSL.CertificateKind.PoolRetirement:
      return poolRetirement(cslCertificate.as_pool_retirement()!);
    case CSL.CertificateKind.GenesisKeyDelegation:
      return genesisKeyDelegaation(cslCertificate.as_genesis_key_delegation()!);
    case CSL.CertificateKind.MoveInstantaneousRewardsCert:
      throw new NotImplementedError('MIR certificate conversion'); // TODO: support this certificate type
    default:
      throw new SerializationError(SerializationFailure.InvalidType);
  }
};
