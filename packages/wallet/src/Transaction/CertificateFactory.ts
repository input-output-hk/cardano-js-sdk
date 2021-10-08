import { Lovelace, ByName } from '@cardano-ogmios/schema';
import { CardanoSerializationLib, CSL, NotImplementedError } from '@cardano-sdk/core';
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
} & ByName;

type Relay = MultiHostNameRelay | SingleHostAddrRelay | SingleHostNameRelay;

interface PoolMetadata {
  hash: PoolMetadataHashBech32;
  url: string;
}

interface PoolParameters {
  poolKeyHash: Ed25519KeyHashBech32;
  vrfKeyHash: VrfKeyHashBech32;
  pledge: Lovelace;
  cost: Lovelace;
  margin: Ratio;
  rewardAddress: AddressBech32;
  owners: Ed25519KeyHashBech32[];
  relays: Relay[];
  poolMetadata?: PoolMetadata;
}

export class CertificateFactory {
  readonly #stakeCredential: CSL.StakeCredential;
  readonly #csl: CardanoSerializationLib;

  constructor(csl: CardanoSerializationLib, keyManager: KeyManager) {
    this.#csl = csl;
    this.#stakeCredential = csl.StakeCredential.from_keyhash(keyManager.stakeKey.hash());
  }

  stakeKeyRegistration() {
    return this.#csl.Certificate.new_stake_registration(this.#csl.StakeRegistration.new(this.#stakeCredential));
  }

  stakeKeyDeregistration() {
    return this.#csl.Certificate.new_stake_deregistration(this.#csl.StakeDeregistration.new(this.#stakeCredential));
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
    const cslOwners = this.#csl.Ed25519KeyHashes.new();
    for (const owner of owners) {
      cslOwners.add(this.#csl.Ed25519KeyHash.from_bech32(owner));
    }
    const cslRelays = this.#createCslRelays(relays);
    const poolParams = this.#csl.PoolParams.new(
      this.#csl.Ed25519KeyHash.from_bech32(poolKeyHash),
      this.#csl.VRFKeyHash.from_bech32(vrfKeyHash),
      this.#csl.BigNum.from_str(pledge.toString()),
      this.#csl.BigNum.from_str(cost.toString()),
      this.#csl.UnitInterval.new(
        this.#csl.BigNum.from_str(margin.numerator.toString()),
        this.#csl.BigNum.from_str(margin.denominator.toString())
      ),
      this.#csl.RewardAddress.from_address(this.#csl.Address.from_bech32(rewardAddress))!,
      cslOwners,
      cslRelays,
      poolMetadata
        ? this.#csl.PoolMetadata.new(
            this.#csl.URL.new(poolMetadata.url),
            this.#csl.PoolMetadataHash.from_bech32(poolMetadata.hash)
          )
        : undefined
    );
    return this.#csl.Certificate.new_pool_registration(this.#csl.PoolRegistration.new(poolParams));
  }

  poolRetirement(poolKeyHash: Ed25519KeyHashBech32, epoch: number) {
    return this.#csl.Certificate.new_pool_retirement(
      this.#csl.PoolRetirement.new(this.#csl.Ed25519KeyHash.from_bech32(poolKeyHash), epoch)
    );
  }

  stakeDelegation(delegatee: Ed25519KeyHashBech32) {
    return this.#csl.Certificate.new_stake_delegation(
      this.#csl.StakeDelegation.new(this.#stakeCredential, this.#csl.Ed25519KeyHash.from_bech32(delegatee))
    );
  }

  #createCslRelays(relays: Relay[]) {
    const cslRelays = this.#csl.Relays.new();
    for (const relay of relays) {
      switch (relay.relayType) {
        case 'singlehost-addr':
          if (relay.ipv6) {
            throw new NotImplementedError('Parse IPv6 to byte array');
          }
          cslRelays.add(
            this.#csl.Relay.new_single_host_addr(
              this.#csl.SingleHostAddr.new(
                relay.port,
                relay.ipv4
                  ? this.#csl.Ipv4.new(new Uint8Array(relay.ipv4.split('.').map((segment) => Number.parseInt(segment))))
                  : undefined
              )
            )
          );
          break;
        case 'singlehost-name':
          cslRelays.add(
            this.#csl.Relay.new_single_host_name(
              this.#csl.SingleHostName.new(relay.port || undefined, this.#csl.DNSRecordAorAAAA.new(relay.hostname))
            )
          );
          break;
        case 'multihost-name':
          cslRelays.add(
            this.#csl.Relay.new_multi_host_name(this.#csl.MultiHostName.new(this.#csl.DNSRecordSRV.new(relay.dnsName)))
          );
          break;
        default:
          throw new NotImplementedError('Relay type');
      }
    }
    return cslRelays;
  }
}
