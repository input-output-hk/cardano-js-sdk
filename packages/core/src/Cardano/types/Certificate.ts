import { Address, Epoch, Hash16, Lovelace, PoolId, RewardAccount } from '.';
import { PoolMetadata } from '@cardano-ogmios/schema';

export interface RelayByAddress {
  __typename: 'RelayByAddress';
  ipv4?: string;
  ipv6?: string;
  port?: number;
}
export interface RelayByName {
  __typename: 'RelayByName';
  hostname: string;
  port?: number;
}

export interface RelayByNameMultihost {
  __typename: 'RelayByNameMultihost';
  dnsName: string;
}

export type Relay = RelayByAddress | RelayByName | RelayByNameMultihost;

export interface Fraction {
  numerator: number;
  denominator: number;
}

export interface PoolParameters {
  id: PoolId;
  rewardAccount: RewardAccount;
  /**
   * Declared pledge quantity.
   */
  pledge: Lovelace;
  /**
   * Fixed stake pool running cost
   */
  cost: Lovelace;
  /**
   * Stake pool margin percentage
   */
  margin: Fraction;
  /**
   * Metadata location and hash
   */
  metadataJson?: PoolMetadata; // TODO: replace this type's hash with a safer hash16
  /**
   * Stake pool relays
   */
  relays: Relay[];

  // TODO: verify these types and replace with stricter ones
  owners: Hash16[];
  vrf: Hash16;
}

export enum CertificateType {
  StakeKeyRegistration = 'StakeKeyRegistration',
  StakeKeyDeregistration = 'StakeKeyDeregistration',
  PoolRegistration = 'PoolRegistration',
  PoolRetirement = 'PoolRetirement',
  StakeDelegation = 'StakeDelegation',
  MIR = 'MoveInstantaneousRewards',
  GenesisKeyDelegation = 'GenesisKeyDelegation'
}

export interface StakeAddressCertificate {
  __typename: CertificateType.StakeKeyRegistration | CertificateType.StakeKeyDeregistration;
  rewardAccount: RewardAccount;
}

export interface PoolRegistrationCertificate {
  __typename: CertificateType.PoolRegistration;
  poolId: PoolId;
  epoch: Epoch;
  poolParameters: PoolParameters;
}

export interface PoolRetirementCertificate {
  __typename: CertificateType.PoolRetirement;
  poolId: PoolId;
  epoch: Epoch;
}

export interface StakeDelegationCertificate {
  __typename: CertificateType.StakeDelegation;
  rewardAccount: RewardAccount;
  poolId: PoolId;
  epoch: Epoch;
}

export interface MirCertificate {
  __typename: CertificateType.MIR;
  // Review: need to learn what this cert is and figure out if 'address' is actually an Address or a RewardAccount
  address: Address;
  quantity: Lovelace;
  pot: 'reserve' | 'treasury';
}

export interface GenesisKeyDelegationCertificate {
  __typename: CertificateType.GenesisKeyDelegation;
  // Review: need to find examples of these hashes to figure out type and length
  genesisHash: Hash16;
  genesisDelegateHash: Hash16;
  vrfKeyHash: Hash16;
}

export type Certificate =
  | StakeAddressCertificate
  | PoolRegistrationCertificate
  | PoolRetirementCertificate
  | StakeDelegationCertificate
  | MirCertificate
  | GenesisKeyDelegationCertificate;
