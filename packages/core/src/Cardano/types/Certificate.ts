import { Epoch, Hash32ByteBase16, Lovelace, PoolId, PoolParameters, RewardAccount } from '.';

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
  /**
   * Might or might not be present based on source.
   * Not present in serialized tx.
   */
  epoch?: Epoch;
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
  genesisHash: Hash32ByteBase16;
  genesisDelegateHash: Hash32ByteBase16;
  vrfKeyHash: Hash32ByteBase16;
}

export type Certificate =
  | StakeAddressCertificate
  | PoolRegistrationCertificate
  | PoolRetirementCertificate
  | StakeDelegationCertificate
  | MirCertificate
  | GenesisKeyDelegationCertificate;
