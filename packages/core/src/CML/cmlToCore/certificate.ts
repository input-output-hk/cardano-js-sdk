import * as Crypto from '@cardano-sdk/crypto';
import { CML } from '../CML';
import {
  Certificate,
  CertificateType,
  EpochNo,
  GenesisKeyDelegationCertificate,
  PoolId,
  PoolMetadataJson,
  PoolRegistrationCertificate,
  PoolRetirementCertificate,
  Relay,
  StakeAddressCertificate,
  StakeDelegationCertificate,
  VrfVkHex
} from '../../Cardano/types';
import { CredentialType, RewardAccount, RewardAddress } from '../../Cardano';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { NetworkId } from '../../Cardano/ChainId';
import { NotImplementedError, SerializationError, SerializationFailure } from '../../errors';
import { usingAutoFree } from '@cardano-sdk/util';

const stakeRegistration = (certificate: CML.StakeRegistration): StakeAddressCertificate =>
  usingAutoFree((scope) => ({
    __typename: CertificateType.StakeKeyRegistration,
    stakeKeyHash: Crypto.Ed25519KeyHashHex(
      Buffer.from(scope.manage(scope.manage(certificate.stake_credential()).to_keyhash())!.to_bytes()).toString('hex')
    )
  }));

const stakeDeregistration = (certificate: CML.StakeDeregistration): StakeAddressCertificate =>
  usingAutoFree((scope) => ({
    __typename: CertificateType.StakeKeyDeregistration,
    stakeKeyHash: Crypto.Ed25519KeyHashHex(
      Buffer.from(scope.manage(scope.manage(certificate.stake_credential()).to_keyhash())!.to_bytes()).toString('hex')
    )
  }));

const stakeDelegation = (certificate: CML.StakeDelegation): StakeDelegationCertificate =>
  usingAutoFree((scope) => ({
    __typename: CertificateType.StakeDelegation,
    poolId: PoolId(scope.manage(certificate.pool_keyhash()).to_bech32('pool')),
    stakeKeyHash: Crypto.Ed25519KeyHashHex(
      Buffer.from(scope.manage(scope.manage(certificate.stake_credential()).to_keyhash())!.to_bytes()).toString('hex')
    )
  }));

const createCardanoRelays = (relays: CML.Relays): Relay[] =>
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

const createCardanoOwners = (owners: CML.Ed25519KeyHashes, networkId: NetworkId): RewardAccount[] =>
  usingAutoFree((scope) => {
    const result: RewardAccount[] = [];
    for (let i = 0; i < owners.len(); i++) {
      const keyHash = scope.manage(owners.get(i));

      const stakeCredential = { hash: Hash28ByteBase16(keyHash.to_hex()), type: CredentialType.KeyHash };
      const rewardAccount = RewardAddress.fromCredentials(networkId, stakeCredential);

      result.push(RewardAccount(rewardAccount.toAddress().toBech32()));
    }
    return result;
  });

const jsonMetadata = (poolMetadata?: CML.PoolMetadata): PoolMetadataJson | undefined =>
  usingAutoFree((scope) => {
    if (!poolMetadata) return;
    return {
      hash: Crypto.Hash32ByteBase16(
        Buffer.from(scope.manage(poolMetadata.pool_metadata_hash()).to_bytes()).toString('hex')
      ),
      url: scope.manage(poolMetadata.url()).url()
    };
  });

export const poolRegistration = (certificate: CML.PoolRegistration): PoolRegistrationCertificate =>
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

const poolRetirement = (certificate: CML.PoolRetirement): PoolRetirementCertificate =>
  usingAutoFree((scope) => ({
    __typename: CertificateType.PoolRetirement,
    epoch: EpochNo(certificate.epoch()),
    poolId: PoolId(scope.manage(certificate.pool_keyhash()).to_bech32('pool'))
  }));

const genesisKeyDelegation = (certificate: CML.GenesisKeyDelegation): GenesisKeyDelegationCertificate =>
  usingAutoFree((scope) => ({
    __typename: CertificateType.GenesisKeyDelegation,
    genesisDelegateHash: Crypto.Hash28ByteBase16(scope.manage(certificate.genesis_delegate_hash()).to_hex()),
    genesisHash: Crypto.Hash28ByteBase16(scope.manage(certificate.genesishash()).to_hex()),
    vrfKeyHash: Crypto.Hash32ByteBase16(scope.manage(certificate.vrf_keyhash()).to_hex())
  }));

export const createCertificate = (cmlCertificate: CML.Certificate): Certificate =>
  usingAutoFree((scope) => {
    switch (cmlCertificate.kind()) {
      case CML.CertificateKind.StakeRegistration:
        return stakeRegistration(scope.manage(cmlCertificate.as_stake_registration()!));
      case CML.CertificateKind.StakeDeregistration:
        return stakeDeregistration(scope.manage(cmlCertificate.as_stake_deregistration()!));
      case CML.CertificateKind.StakeDelegation:
        return stakeDelegation(scope.manage(cmlCertificate.as_stake_delegation()!));
      case CML.CertificateKind.PoolRegistration:
        return poolRegistration(scope.manage(cmlCertificate.as_pool_registration()!));
      case CML.CertificateKind.PoolRetirement:
        return poolRetirement(scope.manage(cmlCertificate.as_pool_retirement()!));
      case CML.CertificateKind.GenesisKeyDelegation:
        return genesisKeyDelegation(scope.manage(cmlCertificate.as_genesis_key_delegation()!));
      case CML.CertificateKind.MoveInstantaneousRewardsCert:
        throw new NotImplementedError('MIR certificate conversion'); // TODO: support this certificate type
      default:
        throw new SerializationError(SerializationFailure.InvalidType);
    }
  });
