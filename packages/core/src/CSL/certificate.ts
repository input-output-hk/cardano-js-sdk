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
import { Cardano, NotImplementedError } from '..';
import { CertificateType } from '../Cardano';

export const stakeAddressToCredential = (address: Cardano.Address) =>
  StakeCredential.from_keyhash(Ed25519KeyHash.from_bech32(address));

export const stakeKeyRegistration = (address: Cardano.Address) =>
  Certificate.new_stake_registration(StakeRegistration.new(stakeAddressToCredential(address)));

export const stakeKeyDeregistration = (address: Cardano.Address) =>
  Certificate.new_stake_deregistration(StakeDeregistration.new(stakeAddressToCredential(address)));

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
    cslOwners.add(Ed25519KeyHash.from_bech32(owner));
  }
  const cslRelays = createCslRelays(relays);
  const poolParams = PoolParams.new(
    Ed25519KeyHash.from_bech32(id),
    VRFKeyHash.from_bytes(Buffer.from(vrf, 'hex')),
    BigNum.from_str(pledge.toString()),
    BigNum.from_str(cost.toString()),
    UnitInterval.new(BigNum.from_str(margin.numerator.toString()), BigNum.from_str(margin.denominator.toString())),
    RewardAddress.from_address(Address.from_bech32(rewardAccount))!,
    cslOwners,
    cslRelays,
    metadataJson
      ? PoolMetadata.new(URL.new(metadataJson.url), PoolMetadataHash.from_bech32(metadataJson.hash))
      : undefined
  );
  return Certificate.new_pool_registration(PoolRegistration.new(poolParams));
};

export const poolRetirement = (poolKeyHash: Cardano.Ed25519KeyHashBech32, epoch: number) =>
  Certificate.new_pool_retirement(PoolRetirement.new(Ed25519KeyHash.from_bech32(poolKeyHash), epoch));

export const stakeDelegation = (address: Cardano.Address, delegatee: Cardano.Ed25519KeyHashBech32) =>
  Certificate.new_stake_delegation(
    StakeDelegation.new(stakeAddressToCredential(address), Ed25519KeyHash.from_bech32(delegatee))
  );

export const create = (certificate: Cardano.Certificate) => {
  switch (certificate.__typename) {
    case CertificateType.PoolRegistration:
      return poolRegistration(certificate.poolParameters);
    case CertificateType.PoolRetirement:
      return poolRetirement(certificate.poolId, certificate.epoch);
    case CertificateType.StakeDelegation:
      return stakeDelegation(certificate.address, certificate.poolId);
    case CertificateType.StakeDeregistration:
      return stakeKeyDeregistration(certificate.address);
    case CertificateType.StakeRegistration:
      return stakeKeyRegistration(certificate.address);
    default:
      throw new NotImplementedError(`certificate.create ${certificate.__typename}`);
  }
};
