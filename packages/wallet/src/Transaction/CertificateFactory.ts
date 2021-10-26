import { NotImplementedError, Cardano, CSL } from '@cardano-sdk/core';
import { KeyManager } from '../KeyManagement';

export type Ed25519KeyHashBech32 = string;
export type VrfKeyHashBech32 = string;
export type AddressBech32 = string;
export type PoolMetadataHashBech32 = string;

interface Ratio {
  numerator: number;
  denominator: number;
}

interface MultiHostNameRelay {
  relayType: 'multihost-name';
  dnsName: string;
}

type SingleHostAddrRelay = {
  relayType: 'singlehost-addr';
  ipv4?: string;
  ipv6?: string;
  port?: number;
};

type SingleHostNameRelay = {
  relayType: 'singlehost-name';
} & Cardano.ByName;

type Relay = MultiHostNameRelay | SingleHostAddrRelay | SingleHostNameRelay;

interface PoolMetadata {
  hash: PoolMetadataHashBech32;
  url: string;
}

interface PoolParameters {
  poolKeyHash: Ed25519KeyHashBech32;
  vrfKeyHash: VrfKeyHashBech32;
  pledge: Cardano.Lovelace;
  cost: Cardano.Lovelace;
  margin: Ratio;
  rewardAddress: AddressBech32;
  owners: Ed25519KeyHashBech32[];
  relays: Relay[];
  poolMetadata?: PoolMetadata;
}

export class CertificateFactory {
  readonly #stakeCredential: CSL.StakeCredential;

  constructor(keyManager: KeyManager) {
    this.#stakeCredential = CSL.StakeCredential.from_keyhash(keyManager.stakeKey.hash());
  }

  stakeKeyRegistration() {
    return CSL.Certificate.new_stake_registration(CSL.StakeRegistration.new(this.#stakeCredential));
  }

  stakeKeyDeregistration() {
    return CSL.Certificate.new_stake_deregistration(CSL.StakeDeregistration.new(this.#stakeCredential));
  }

  poolRegistration({
    poolKeyHash,
    vrfKeyHash,
    pledge,
    cost,
    margin,
    rewardAddress,
    owners,
    relays,
    poolMetadata
  }: PoolParameters) {
    const cslOwners = CSL.Ed25519KeyHashes.new();
    for (const owner of owners) {
      cslOwners.add(CSL.Ed25519KeyHash.from_bech32(owner));
    }
    const cslRelays = this.#createCslRelays(relays);
    const poolParams = CSL.PoolParams.new(
      CSL.Ed25519KeyHash.from_bech32(poolKeyHash),
      CSL.VRFKeyHash.from_bech32(vrfKeyHash),
      CSL.BigNum.from_str(pledge.toString()),
      CSL.BigNum.from_str(cost.toString()),
      CSL.UnitInterval.new(
        CSL.BigNum.from_str(margin.numerator.toString()),
        CSL.BigNum.from_str(margin.denominator.toString())
      ),
      CSL.RewardAddress.from_address(CSL.Address.from_bech32(rewardAddress))!,
      cslOwners,
      cslRelays,
      poolMetadata
        ? CSL.PoolMetadata.new(CSL.URL.new(poolMetadata.url), CSL.PoolMetadataHash.from_bech32(poolMetadata.hash))
        : undefined
    );
    return CSL.Certificate.new_pool_registration(CSL.PoolRegistration.new(poolParams));
  }

  poolRetirement(poolKeyHash: Ed25519KeyHashBech32, epoch: number) {
    return CSL.Certificate.new_pool_retirement(
      CSL.PoolRetirement.new(CSL.Ed25519KeyHash.from_bech32(poolKeyHash), epoch)
    );
  }

  stakeDelegation(delegatee: Ed25519KeyHashBech32) {
    return CSL.Certificate.new_stake_delegation(
      CSL.StakeDelegation.new(this.#stakeCredential, CSL.Ed25519KeyHash.from_bech32(delegatee))
    );
  }

  #createCslRelays(relays: Relay[]) {
    const cslRelays = CSL.Relays.new();
    for (const relay of relays) {
      switch (relay.relayType) {
        case 'singlehost-addr':
          if (relay.ipv6) {
            throw new NotImplementedError('Parse IPv6 to byte array');
          }
          cslRelays.add(
            CSL.Relay.new_single_host_addr(
              CSL.SingleHostAddr.new(
                relay.port,
                relay.ipv4
                  ? CSL.Ipv4.new(new Uint8Array(relay.ipv4.split('.').map((segment) => Number.parseInt(segment))))
                  : undefined
              )
            )
          );
          break;
        case 'singlehost-name':
          cslRelays.add(
            CSL.Relay.new_single_host_name(
              CSL.SingleHostName.new(relay.port || undefined, CSL.DNSRecordAorAAAA.new(relay.hostname))
            )
          );
          break;
        case 'multihost-name':
          cslRelays.add(CSL.Relay.new_multi_host_name(CSL.MultiHostName.new(CSL.DNSRecordSRV.new(relay.dnsName))));
          break;
        default:
          throw new NotImplementedError('Relay type');
      }
    }
    return cslRelays;
  }
}
