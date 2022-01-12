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
  StakeDelegation,
  StakeDeregistration,
  StakeRegistration,
  URL,
  UnitInterval,
  VRFKeyHash
} from '@emurgo/cardano-serialization-lib-nodejs';
import { Cardano, NotImplementedError, SerializationError, SerializationFailure } from '..';
import { CertificateType } from '../Cardano';

export const stakeAddressToCredential = (rewardAccount: Cardano.RewardAccount) => {
  try {
    const rewardAddress = RewardAddress.from_address(Address.from_bech32(rewardAccount.toString()));
    if (!rewardAddress)
      throw new SerializationError(
        SerializationFailure.InvalidAddress,
        `Invalid reward account address: ${rewardAccount}`
      );
    return rewardAddress.payment_cred();
  } catch (error) {
    throw new SerializationError(
      SerializationFailure.InvalidAddress,
      `Invalid reward account address: ${rewardAccount}`,
      error
    );
  }
};

export const stakeKeyRegistration = (rewardAccount: Cardano.RewardAccount) =>
  Certificate.new_stake_registration(StakeRegistration.new(stakeAddressToCredential(rewardAccount)));

export const stakeKeyDeregistration = (rewardAccount: Cardano.RewardAccount) =>
  Certificate.new_stake_deregistration(StakeDeregistration.new(stakeAddressToCredential(rewardAccount)));

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

export const stakeDelegation = (rewardAccount: Cardano.RewardAccount, delegatee: Cardano.PoolId) =>
  Certificate.new_stake_delegation(
    // TODO: add coreToCsl support for genesis pool IDs
    StakeDelegation.new(stakeAddressToCredential(rewardAccount), Ed25519KeyHash.from_bech32(delegatee.toString()))
  );

export const create = (certificate: Cardano.Certificate) => {
  switch (certificate.__typename) {
    case CertificateType.PoolRegistration:
      return poolRegistration(certificate.poolParameters);
    case CertificateType.PoolRetirement:
      return poolRetirement(certificate.poolId, certificate.epoch);
    case CertificateType.StakeDelegation:
      return stakeDelegation(certificate.rewardAccount, certificate.poolId);
    case CertificateType.StakeKeyDeregistration:
      return stakeKeyDeregistration(certificate.rewardAccount);
    case CertificateType.StakeKeyRegistration:
      return stakeKeyRegistration(certificate.rewardAccount);
    default:
      throw new NotImplementedError(`certificate.create ${certificate.__typename}`);
  }
};
