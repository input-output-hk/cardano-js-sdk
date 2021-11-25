import { Address, Epoch, Hash32ByteBase16, Lovelace, PoolId, PoolParameters, RewardAccount } from '.';

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
