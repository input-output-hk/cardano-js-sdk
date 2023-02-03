import * as Crypto from '@cardano-sdk/crypto';
import { EpochNo } from './Block';
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
  stakeKeyHash: Crypto.Ed25519KeyHashHex;
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
  stakeKeyHash: Crypto.Ed25519KeyHashHex;
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
  genesisHash: Crypto.Hash28ByteBase16;
  genesisDelegateHash: Crypto.Hash28ByteBase16;
  vrfKeyHash: Crypto.Hash32ByteBase16;
}

export type Certificate =
  | StakeAddressCertificate
  | PoolRegistrationCertificate
  | PoolRetirementCertificate
  | StakeDelegationCertificate
  | MirCertificate
  | GenesisKeyDelegationCertificate;
