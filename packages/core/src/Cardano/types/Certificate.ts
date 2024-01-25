import * as Crypto from '@cardano-sdk/crypto';
import { Anchor, DelegateRepresentative } from './Governance';
import { Credential, CredentialType, RewardAccount } from '../Address';
import { EpochNo } from './Block';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { Lovelace } from './Value';
import { PoolId, PoolParameters } from './StakePool';

export enum CertificateType {
  StakeRegistration = 'StakeRegistrationCertificate',
  StakeDeregistration = 'StakeDeregistrationCertificate',
  PoolRegistration = 'PoolRegistrationCertificate',
  PoolRetirement = 'PoolRetirementCertificate',
  StakeDelegation = 'StakeDelegationCertificate',
  MIR = 'MirCertificate', // deprecated in conway
  GenesisKeyDelegation = 'GenesisKeyDelegationCertificate', // deprecated in conway

  // Conway Era Certs
  Registration = 'RegistrationCertificate', // Replaces StakeRegistration in post-conway era
  Unregistration = 'UnRegistrationCertificate', // Replaces StakeDeregistration in post-conway era
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
  stakeCredential: Credential;
  deposit: Lovelace;
}

// Delegation
export interface VoteDelegationCertificate {
  __typename: CertificateType.VoteDelegation;
  stakeCredential: Credential;
  dRep: DelegateRepresentative;
}

export interface StakeVoteDelegationCertificate {
  __typename: CertificateType.StakeVoteDelegation;
  stakeCredential: Credential;
  poolId: PoolId;
  dRep: DelegateRepresentative;
}

export interface StakeRegistrationDelegationCertificate {
  __typename: CertificateType.StakeRegistrationDelegation;
  stakeCredential: Credential;
  poolId: PoolId;
  deposit: Lovelace;
}

export interface VoteRegistrationDelegationCertificate {
  __typename: CertificateType.VoteRegistrationDelegation;
  stakeCredential: Credential;
  dRep: DelegateRepresentative;
  deposit: Lovelace;
}

export interface StakeVoteRegistrationDelegationCertificate {
  __typename: CertificateType.StakeVoteRegistrationDelegation;
  stakeCredential: Credential;
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
  anchor: Anchor | null;
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

/** To be deprecated in the Era after conway replaced by <NewStakeAddressCertificate> */
export interface StakeAddressCertificate {
  __typename: CertificateType.StakeRegistration | CertificateType.StakeDeregistration;
  stakeCredential: Credential;
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
  stakeCredential: Credential;
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

export type CertificatePostConway =
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

export type Certificate = CertificatePostConway | StakeAddressCertificate;

/**
 * Creates a stake key registration certificate from a given reward account.
 *
 * @param rewardAccount The reward account to be registered.
 */
export const createStakeRegistrationCert = (rewardAccount: RewardAccount): Certificate => ({
  __typename: CertificateType.StakeRegistration,
  stakeCredential: {
    hash: Hash28ByteBase16.fromEd25519KeyHashHex(RewardAccount.toHash(rewardAccount)),
    type: CredentialType.KeyHash
  }
});

/**
 * Creates a stake key de-registration certificate from a given reward account.
 *
 * @param rewardAccount The reward account to be de-registered.
 */
export const createStakeDeregistrationCert = (rewardAccount: RewardAccount, deposit?: Lovelace): Certificate =>
  deposit === undefined
    ? {
        __typename: CertificateType.StakeDeregistration,
        stakeCredential: {
          hash: Hash28ByteBase16.fromEd25519KeyHashHex(RewardAccount.toHash(rewardAccount)),
          type: CredentialType.KeyHash
        }
      }
    : {
        __typename: CertificateType.Unregistration,
        deposit,
        stakeCredential: {
          hash: Hash28ByteBase16.fromEd25519KeyHashHex(RewardAccount.toHash(rewardAccount)),
          type: CredentialType.KeyHash
        }
      };

/**
 * Creates a delegation certificate from a given reward account and a pool id.
 *
 * @param rewardAccount The reward account to be registered.
 * @param poolId The id of the pool that we are delegating to.
 */
export const createDelegationCert = (rewardAccount: RewardAccount, poolId: PoolId): Certificate => ({
  __typename: CertificateType.StakeDelegation,
  poolId,
  stakeCredential: {
    hash: Hash28ByteBase16.fromEd25519KeyHashHex(RewardAccount.toHash(rewardAccount)),
    type: CredentialType.KeyHash
  }
});
