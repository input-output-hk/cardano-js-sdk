import { Ed25519KeyHash } from './Key';
import { EpochNo } from './Block';
import { Hash28ByteBase16, Hash32ByteBase16 } from '@cardano-sdk/util';
import { Lovelace } from './Value';
import { PoolId, PoolParameters } from './StakePool';
import { RewardAccount } from './RewardAccount';

export enum CertificateType {
  StakeKeyRegistration = 'StakeKeyRegistrationCertificate',
  StakeKeyDeregistration = 'StakeKeyDeregistrationCertificate',
  PoolRegistration = 'PoolRegistrationCertificate',
  PoolRetirement = 'PoolRetirementCertificate',
  StakeDelegation = 'StakeDelegationCertificate',
  MIR = 'MirCertificate',
  GenesisKeyDelegation = 'GenesisKeyDelegationCertificate'
}

export interface StakeAddressCertificate {
  __typename: CertificateType.StakeKeyRegistration | CertificateType.StakeKeyDeregistration;
  stakeKeyHash: Ed25519KeyHash;
}

export interface PoolRegistrationCertificate {
  __typename: CertificateType.PoolRegistration;
  poolParameters: PoolParameters;
}

export interface PoolRetirementCertificate {
  __typename: CertificateType.PoolRetirement;
  poolId: PoolId;
  epoch: EpochNo;
}

export interface StakeDelegationCertificate {
  __typename: CertificateType.StakeDelegation;
  stakeKeyHash: Ed25519KeyHash;
  poolId: PoolId;
}

export enum MirCertificatePot {
  Reserves = 'reserve',
  Treasury = 'treasury'
}

export interface MirCertificate {
  __typename: CertificateType.MIR;
  rewardAccount: RewardAccount;
  quantity: Lovelace;
  pot: MirCertificatePot;
}

export interface GenesisKeyDelegationCertificate {
  __typename: CertificateType.GenesisKeyDelegation;
  genesisHash: Hash28ByteBase16;
  genesisDelegateHash: Hash28ByteBase16;
  vrfKeyHash: Hash32ByteBase16;
}

export type Certificate =
  | StakeAddressCertificate
  | PoolRegistrationCertificate
  | PoolRetirementCertificate
  | StakeDelegationCertificate
  | MirCertificate
  | GenesisKeyDelegationCertificate;
