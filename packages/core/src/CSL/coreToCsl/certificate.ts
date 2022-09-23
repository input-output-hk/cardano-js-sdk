import * as Cardano from '../../Cardano/types';
import {
  Address,
  BigNum,
  Certificate,
  DNSRecordAorAAAA,
  DNSRecordSRV,
  Ed25519KeyHash,
  Ed25519KeyHashes,
  Ipv4,
  MultiHostName,
  PoolMetadata,
  PoolMetadataHash,
  PoolParams,
  PoolRegistration,
  PoolRetirement,
  Relay,
  Relays,
  RewardAddress,
  SingleHostAddr,
  SingleHostName,
  StakeCredential,
  StakeDelegation,
  StakeDeregistration,
  StakeRegistration,
  URL,
  UnitInterval,
  VRFKeyHash
} from '@emurgo/cardano-serialization-lib-nodejs';
import { NotImplementedError } from '../../errors';

export const stakeKeyRegistration = (stakeKeyHash: Cardano.Ed25519KeyHash) =>
  Certificate.new_stake_registration(
    StakeRegistration.new(
      StakeCredential.from_keyhash(Ed25519KeyHash.from_bytes(Buffer.from(stakeKeyHash.toString(), 'hex')))
    )
  );

export const stakeKeyDeregistration = (stakeKeyHash: Cardano.Ed25519KeyHash) =>
  Certificate.new_stake_deregistration(
    StakeDeregistration.new(
      StakeCredential.from_keyhash(Ed25519KeyHash.from_bytes(Buffer.from(stakeKeyHash.toString(), 'hex')))
    )
  );

const createCslRelays = (relays: Cardano.Relay[]) => {
  const cslRelays = Relays.new();
  for (const relay of relays) {
    switch (relay.__typename) {
      case 'RelayByAddress':
        if (relay.ipv6) {
          throw new NotImplementedError('Parse IPv6 to byte array');
        }
        cslRelays.add(
          Relay.new_single_host_addr(
            SingleHostAddr.new(
              relay.port,
              relay.ipv4
                ? Ipv4.new(new Uint8Array(relay.ipv4.split('.').map((segment) => Number.parseInt(segment))))
                : undefined
            )
          )
        );
        break;
      case 'RelayByName':
        cslRelays.add(
          Relay.new_single_host_name(SingleHostName.new(relay.port || undefined, DNSRecordAorAAAA.new(relay.hostname)))
        );
        break;
      case 'RelayByNameMultihost':
        cslRelays.add(Relay.new_multi_host_name(MultiHostName.new(DNSRecordSRV.new(relay.dnsName))));
        break;
      default:
        throw new NotImplementedError('Relay type');
    }
  }
  return cslRelays;
};

export const poolRegistration = ({
  id,
  vrf,
  pledge,
  cost,
  margin,
  rewardAccount,
  owners,
  relays,
  metadataJson
}: Cardano.PoolParameters) => {
  const cslOwners = Ed25519KeyHashes.new();
  for (const owner of owners) {
    const hash = RewardAddress.from_address(Address.from_bech32(owner.toString()))!.payment_cred().to_keyhash()!;
    cslOwners.add(hash);
  }
  const cslRelays = createCslRelays(relays);
  const poolParams = PoolParams.new(
    Ed25519KeyHash.from_bech32(id.toString()),
    VRFKeyHash.from_bytes(Buffer.from(vrf, 'hex')),
    BigNum.from_str(pledge.toString()),
    BigNum.from_str(cost.toString()),
    UnitInterval.new(BigNum.from_str(margin.numerator.toString()), BigNum.from_str(margin.denominator.toString())),
    RewardAddress.from_address(Address.from_bech32(rewardAccount.toString()))!,
    cslOwners,
    cslRelays,
    metadataJson
      ? PoolMetadata.new(URL.new(metadataJson.url), PoolMetadataHash.from_bytes(Buffer.from(metadataJson.hash, 'hex')))
      : undefined
  );
  return Certificate.new_pool_registration(PoolRegistration.new(poolParams));
};

export const poolRetirement = (poolId: Cardano.PoolId, epoch: number) =>
  Certificate.new_pool_retirement(PoolRetirement.new(Ed25519KeyHash.from_bech32(poolId.toString()), epoch));

export const stakeDelegation = (stakeKeyHash: Cardano.Ed25519KeyHash, delegatee: Cardano.PoolId) =>
  Certificate.new_stake_delegation(
    // TODO: add coreToCsl support for genesis pool IDs
    StakeDelegation.new(
      StakeCredential.from_keyhash(Ed25519KeyHash.from_bytes(Buffer.from(stakeKeyHash.toString(), 'hex'))),
      Ed25519KeyHash.from_bech32(delegatee.toString())
    )
  );

export const create = (certificate: Cardano.Certificate) => {
  switch (certificate.__typename) {
    case Cardano.CertificateType.PoolRegistration:
      return poolRegistration(certificate.poolParameters);
    case Cardano.CertificateType.PoolRetirement:
      return poolRetirement(certificate.poolId, certificate.epoch);
    case Cardano.CertificateType.StakeDelegation:
      return stakeDelegation(certificate.stakeKeyHash, certificate.poolId);
    case Cardano.CertificateType.StakeKeyDeregistration:
      return stakeKeyDeregistration(certificate.stakeKeyHash);
    case Cardano.CertificateType.StakeKeyRegistration:
      return stakeKeyRegistration(certificate.stakeKeyHash);
    default:
      throw new NotImplementedError(`certificate.create ${certificate.__typename}`);
  }
};
