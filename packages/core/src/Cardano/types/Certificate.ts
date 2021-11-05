import { Address, Epoch, Hash16, Lovelace, PoolId } from '.';
import { PoolParameters as OgmiosPoolParameters, PoolMetadata } from '@cardano-ogmios/schema';

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

export interface PoolParameters
  // TODO: don't omit pledge and cost when Lovelace becomes bigint
  extends Omit<OgmiosPoolParameters, 'pledge' | 'cost' | 'margin' | 'metadata' | 'relays'> {
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
  metadataJson?: PoolMetadata;
  /**
   * Stake pool relays
   */
  relays: Relay[];
}

export enum CertificateType {
  StakeRegistration = 'StakeRegistration',
  StakeDeregistration = 'StakeDeregistration',
  PoolRegistration = 'PoolRegistration',
  PoolRetirement = 'PoolRetirement',
  StakeDelegation = 'StakeDelegation',
  MIR = 'MoveInstantaneousRewards',
  GenesisKeyDelegation = 'GenesisKeyDelegation'
}

export interface StakeAddressCertificate {
  __typename: CertificateType.StakeRegistration | CertificateType.StakeDeregistration;
  address: Address;
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
  address: Address;
  poolId: PoolId;
  epoch: Epoch;
}

export interface MirCertificate {
  __typename: CertificateType.MIR;
  address: Address;
  quantity: Lovelace;
  pot: 'reserve' | 'treasury';
}

export interface GenesisKeyDelegationCertificate {
  __typename: CertificateType.GenesisKeyDelegation;
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
