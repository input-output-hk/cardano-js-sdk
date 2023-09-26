import * as Crypto from '@cardano-sdk/crypto';
import { Anchor, DelegateRepresentative } from './Governance';
import { Credential, RewardAccount } from '../Address';
import { EpochNo } from './Block';
import { Lovelace } from './Value';
import { PoolId, PoolParameters } from './StakePool';

export enum CertificateType {
  StakeKeyRegistration = 'StakeKeyRegistrationCertificate',
  StakeKeyDeregistration = 'StakeKeyDeregistrationCertificate',
  PoolRegistration = 'PoolRegistrationCertificate',
  PoolRetirement = 'PoolRetirementCertificate',
  StakeDelegation = 'StakeDelegationCertificate',
  MIR = 'MirCertificate', // deprecated in conway
  GenesisKeyDelegation = 'GenesisKeyDelegationCertificate', // deprecated in conway

  // Conway Era Certs
  Registration = 'RegistrationCertificate', // Replaces StakeKeyRegistration in post-conway era
  Unregistration = 'UnRegistrationCertificate', // Replaces StakeKeyDeregistration in post-conway era
  VoteDelegation = 'VoteDelegationCertificate',
  StakeVoteDelegation = 'StakeVoteDelegationCertificate',
  StakeRegistrationDelegation = 'StakeRegistrationDelegateCertificate', // delegate or delegation??
  VoteRegistrationDelegation = 'VoteRegistrationDelegateCertificate', // same as above
  StakeVoteRegistrationDelegation = 'StakeVoteRegistrationDelegateCertificate',
  AuthorizeCommitteeHot = 'AuthorizeCommitteeHotCertificate',
  ResignCommitteeCold = 'ResignCommitteeColdCertificate',
  RegisterDelegateRepresentative = 'RegisterDelegateRepresentativeCertificate',
  UnregisterDelegateRepresentative = 'UnregisterDelegateRepresentativeCertificate',
  UpdateDelegateRepresentative = 'UpdateDelegateRepresentativeCertificate'
}

// Conway Certificates
export interface NewStakeAddressCertificate {
  __typename: CertificateType.Registration | CertificateType.Unregistration;
  stakeKeyHash: Crypto.Ed25519KeyHashHex;
  deposit: Lovelace;
}

// Delegation
export interface VoteDelegationCertificate {
  __typename: CertificateType.VoteDelegation;
  stakeKeyHash: Crypto.Ed25519KeyHashHex;
  dRep: DelegateRepresentative;
}

export interface StakeVoteDelegationCertificate {
  __typename: CertificateType.StakeVoteDelegation;
  stakeKeyHash: Crypto.Ed25519KeyHashHex;
  poolId: PoolId;
  dRep: DelegateRepresentative;
}

export interface StakeRegistrationDelegationCertificate {
  __typename: CertificateType.StakeRegistrationDelegation;
  stakeKeyHash: Crypto.Ed25519KeyHashHex;
  poolId: PoolId;
  deposit: Lovelace;
}

export interface VoteRegistrationDelegationCertificate {
  __typename: CertificateType.VoteRegistrationDelegation;
  stakeKeyHash: Crypto.Ed25519KeyHashHex;
  dRep: DelegateRepresentative;
  deposit: Lovelace;
}

export interface StakeVoteRegistrationDelegationCertificate {
  __typename: CertificateType.StakeVoteRegistrationDelegation;
  stakeKeyHash: Crypto.Ed25519KeyHashHex;
  poolId: PoolId;
  dRep: DelegateRepresentative;
  deposit: Lovelace;
}

// Governance

export interface AuthorizeCommitteeHotCertificate {
  __typename: CertificateType.AuthorizeCommitteeHot;
  coldCredential: Credential;
  hotCredential: Credential;
}

export interface ResignCommitteeColdCertificate {
  __typename: CertificateType.ResignCommitteeCold;
  coldCredential: Credential;
}

export interface RegisterDelegateRepresentativeCertificate {
  __typename: CertificateType.RegisterDelegateRepresentative;
  dRepCredential: Credential;
  deposit: Lovelace;
  anchor: Anchor | null;
}

export interface UnRegisterDelegateRepresentativeCertificate {
  __typename: CertificateType.UnregisterDelegateRepresentative;
  dRepCredential: Credential;
  deposit: Lovelace;
}

export interface UpdateDelegateRepresentativeCertificate {
  __typename: CertificateType.UpdateDelegateRepresentative;
  dRepCredential: Credential;
  anchor: Anchor | null;
}

/**
 * To be deprecated in the Era after conway
 * replaced by <NewStakeAddressCertificate>
 */
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

export enum MirCertificateKind {
  ToOtherPot = 'toOtherPot',
  ToStakeCreds = 'ToStakeCreds'
}

/** @deprecated in conway */
export interface MirCertificate {
  __typename: CertificateType.MIR;
  kind: MirCertificateKind;
  stakeCredential?: Credential;
  quantity: Lovelace;
  pot: MirCertificatePot;
}

/** @deprecated in conway */
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
  | GenesisKeyDelegationCertificate
  | NewStakeAddressCertificate
  | VoteDelegationCertificate
  | StakeVoteDelegationCertificate
  | StakeRegistrationDelegationCertificate
  | VoteRegistrationDelegationCertificate
  | StakeVoteRegistrationDelegationCertificate
  | AuthorizeCommitteeHotCertificate
  | ResignCommitteeColdCertificate
  | RegisterDelegateRepresentativeCertificate
  | UnRegisterDelegateRepresentativeCertificate
  | UpdateDelegateRepresentativeCertificate;

/**
 * Creates a stake key registration certificate from a given reward account.
 *
 * @param rewardAccount The reward account to be registered.
 */
export const createStakeKeyRegistrationCert = (rewardAccount: RewardAccount): Certificate => ({
  __typename: CertificateType.StakeKeyRegistration,
  stakeKeyHash: RewardAccount.toHash(rewardAccount)
});

/**
 * Creates a stake key de-registration certificate from a given reward account.
 *
 * @param rewardAccount The reward account to be de-registered.
 */
export const createStakeKeyDeregistrationCert = (rewardAccount: RewardAccount): Certificate => ({
  __typename: CertificateType.StakeKeyDeregistration,
  stakeKeyHash: RewardAccount.toHash(rewardAccount)
});

/**
 * Creates a delegation certificate from a given reward account and a pool id.
 *
 * @param rewardAccount The reward account to be registered.
 * @param poolId The id of the pool that we are delegating to.
 */
export const createDelegationCert = (rewardAccount: RewardAccount, poolId: PoolId): Certificate => ({
  __typename: CertificateType.StakeDelegation,
  poolId,
  stakeKeyHash: RewardAccount.toHash(rewardAccount)
});
