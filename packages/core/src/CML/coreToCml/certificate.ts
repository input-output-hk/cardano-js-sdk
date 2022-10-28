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
} from '@dcspark/cardano-multiplatform-lib-nodejs';
import { ManagedFreeableScope } from '@cardano-sdk/util';
import { NotImplementedError } from '../../errors';

export const stakeKeyRegistration = (scope: ManagedFreeableScope, stakeKeyHash: Cardano.Ed25519KeyHash) =>
  scope.manage(
    Certificate.new_stake_registration(
      scope.manage(
        StakeRegistration.new(
          scope.manage(
            StakeCredential.from_keyhash(
              scope.manage(Ed25519KeyHash.from_bytes(Buffer.from(stakeKeyHash.toString(), 'hex')))
            )
          )
        )
      )
    )
  );

export const stakeKeyDeregistration = (scope: ManagedFreeableScope, stakeKeyHash: Cardano.Ed25519KeyHash) =>
  scope.manage(
    Certificate.new_stake_deregistration(
      scope.manage(
        StakeDeregistration.new(
          scope.manage(
            StakeCredential.from_keyhash(
              scope.manage(Ed25519KeyHash.from_bytes(Buffer.from(stakeKeyHash.toString(), 'hex')))
            )
          )
        )
      )
    )
  );

const createCslRelays = (scope: ManagedFreeableScope, relays: Cardano.Relay[]) => {
  const cslRelays = scope.manage(Relays.new());
  for (const relay of relays) {
    switch (relay.__typename) {
      case 'RelayByAddress':
        if (relay.ipv6) {
          throw new NotImplementedError('Parse IPv6 to byte array');
        }
        cslRelays.add(
          scope.manage(
            Relay.new_single_host_addr(
              scope.manage(
                SingleHostAddr.new(
                  relay.port,
                  relay.ipv4
                    ? scope.manage(
                        Ipv4.new(new Uint8Array(relay.ipv4.split('.').map((segment) => Number.parseInt(segment))))
                      )
                    : undefined
                )
              )
            )
          )
        );
        break;
      case 'RelayByName':
        cslRelays.add(
          scope.manage(
            Relay.new_single_host_name(
              scope.manage(
                SingleHostName.new(relay.port || undefined, scope.manage(DNSRecordAorAAAA.new(relay.hostname)))
              )
            )
          )
        );
        break;
      case 'RelayByNameMultihost':
        cslRelays.add(
          scope.manage(
            Relay.new_multi_host_name(scope.manage(MultiHostName.new(scope.manage(DNSRecordSRV.new(relay.dnsName)))))
          )
        );
        break;
      default:
        throw new NotImplementedError('Relay type');
    }
  }
  return cslRelays;
};

export const poolRegistration = (
  scope: ManagedFreeableScope,
  { id, vrf, pledge, cost, margin, rewardAccount, owners, relays, metadataJson }: Cardano.PoolParameters
) => {
  const cslOwners = scope.manage(Ed25519KeyHashes.new());
  for (const owner of owners) {
    const hash = scope.manage(
      scope
        .manage(
          scope.manage(RewardAddress.from_address(scope.manage(Address.from_bech32(owner.toString()))))!.payment_cred()
        )
        .to_keyhash()
    )!;
    cslOwners.add(hash);
  }
  const cslRelays = createCslRelays(scope, relays);
  const poolParams = scope.manage(
    PoolParams.new(
      scope.manage(Ed25519KeyHash.from_bech32(id.toString())),
      scope.manage(VRFKeyHash.from_bytes(Buffer.from(vrf, 'hex'))),
      scope.manage(BigNum.from_str(pledge.toString())),
      scope.manage(BigNum.from_str(cost.toString())),
      scope.manage(
        UnitInterval.new(
          scope.manage(BigNum.from_str(margin.numerator.toString())),
          scope.manage(BigNum.from_str(margin.denominator.toString()))
        )
      ),
      scope.manage(RewardAddress.from_address(scope.manage(Address.from_bech32(rewardAccount.toString())))!),
      cslOwners,
      cslRelays,
      metadataJson
        ? scope.manage(
            PoolMetadata.new(
              scope.manage(URL.new(metadataJson.url)),
              scope.manage(PoolMetadataHash.from_bytes(Buffer.from(metadataJson.hash, 'hex')))
            )
          )
        : undefined
    )
  );
  return scope.manage(Certificate.new_pool_registration(scope.manage(PoolRegistration.new(poolParams))));
};

export const poolRetirement = (scope: ManagedFreeableScope, poolId: Cardano.PoolId, epoch: number) =>
  scope.manage(
    Certificate.new_pool_retirement(
      scope.manage(PoolRetirement.new(scope.manage(Ed25519KeyHash.from_bech32(poolId.toString())), epoch))
    )
  );

export const stakeDelegation = (
  scope: ManagedFreeableScope,
  stakeKeyHash: Cardano.Ed25519KeyHash,
  delegatee: Cardano.PoolId
) =>
  scope.manage(
    Certificate.new_stake_delegation(
      // TODO: add coreToCsl support for genesis pool IDs
      scope.manage(
        StakeDelegation.new(
          scope.manage(
            StakeCredential.from_keyhash(
              scope.manage(Ed25519KeyHash.from_bytes(Buffer.from(stakeKeyHash.toString(), 'hex')))
            )
          ),
          scope.manage(Ed25519KeyHash.from_bech32(delegatee.toString()))
        )
      )
    )
  );

export const create = (scope: ManagedFreeableScope, certificate: Cardano.Certificate) => {
  switch (certificate.__typename) {
    case Cardano.CertificateType.PoolRegistration:
      return poolRegistration(scope, certificate.poolParameters);
    case Cardano.CertificateType.PoolRetirement:
      return poolRetirement(scope, certificate.poolId, certificate.epoch);
    case Cardano.CertificateType.StakeDelegation:
      return stakeDelegation(scope, certificate.stakeKeyHash, certificate.poolId);
    case Cardano.CertificateType.StakeKeyDeregistration:
      return stakeKeyDeregistration(scope, certificate.stakeKeyHash);
    case Cardano.CertificateType.StakeKeyRegistration:
      return stakeKeyRegistration(scope, certificate.stakeKeyHash);
    default:
      throw new NotImplementedError(`certificate.create ${certificate.__typename}`);
  }
};
