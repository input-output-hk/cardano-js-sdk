import * as Crypto from '@cardano-sdk/crypto';
import { Credential, CredentialType, RewardAccount } from '../Address';
import { EpochNo, Fraction } from '.';
import { Lovelace } from './Value';
import { ProtocolParametersUpdate } from './ProtocolParameters';

/**
 * Datum hash, this allows to specify a Datum without publicly revealing its value. To spend an output which specifies
 * this type of datum, the actual Datum value must be provided and will be added to the witness set of
 * the transaction.
 */
export type DataHash = Crypto.Hash32ByteBase16;

export type Anchor = {
  url: string;
  dataHash: DataHash;
};

// Actions
export enum GovernanceActionType {
  parameter_change_action = 'parameter_change_action',
  hard_fork_initiation_action = 'hard_fork_initiation_action',
  treasury_withdrawals_action = 'treasury_withdrawals_action',
  no_confidence = 'no_confidence',
  update_committee = 'update_committee',
  new_constitution = 'new_constitution',
  info_action = 'info_action'
}

export type GovernanceActionId = {
  id: Crypto.Hash32ByteBase16;
  actionIndex: number;
};

export type CommitteeMember = {
  coldCredential: Credential;
  epoch: EpochNo;
};

export type Committee = {
  members: [CommitteeMember];
  quorumThreshold: Fraction;
};

export type Constitution = {
  anchor: Anchor;
  scriptHash: DataHash | null;
};

export type ParameterChangeAction = {
  __typename: GovernanceActionType.parameter_change_action;
  governanceActionId: GovernanceActionId | null;
  protocolParamUpdate: ProtocolParametersUpdate;
};

export type HardForkInitiationAction = {
  __typename: GovernanceActionType.hard_fork_initiation_action;
  governanceActionId: GovernanceActionId | null;
  protocolVersion: ProtocolParametersUpdate['protocolVersion'];
};

export type TreasuryWithdrawalsAction = {
  __typename: GovernanceActionType.treasury_withdrawals_action;
  withdrawals: Set<{
    rewardAccount: RewardAccount;
    coin: Lovelace;
  }>;
};

export type NoConfidence = {
  __typename: GovernanceActionType.no_confidence;
  governanceActionId: GovernanceActionId | null;
};

export type UpdateCommittee = {
  __typename: GovernanceActionType.update_committee;
  governanceActionId: GovernanceActionId | null;
  committeeColdCredentials: Set<Credential>;
  committee: Committee;
};

export type NewConstitution = {
  __typename: GovernanceActionType.new_constitution;
  governanceActionId: GovernanceActionId | null;
  constitution: Constitution;
};

export type InfoAction = {
  __typename: GovernanceActionType.info_action;
  message: string;
};

export type GovernanceAction =
  | ParameterChangeAction
  | HardForkInitiationAction
  | TreasuryWithdrawalsAction
  | NoConfidence
  | UpdateCommittee
  | NewConstitution
  | InfoAction;

export enum Vote {
  no = 0,
  yes = 1,
  abstain = 2
}

export type VotingProcedure = {
  vote: Vote;
  anchor: Anchor | null;
};

export enum VoterType {
  ccHotKeyHash = 'ccHotKeyHash',
  ccHotScriptHash = 'ccHotScriptHash',
  dRepKeyHash = 'dRepKeyHash',
  dRepScriptHash = 'dRepScriptHash',
  stakePoolKeyHash = 'stakePoolKeyHash'
}

export type ConstitutionalCommitteeKeyHashVoter = {
  __typename: VoterType.ccHotKeyHash;
  credential: {
    type: CredentialType.KeyHash;
    hash: Credential['hash'];
  };
};

export type ConstitutionalCommitteeScriptHashVoter = {
  __typename: VoterType.ccHotScriptHash;
  credential: {
    type: CredentialType.ScriptHash;
    hash: Credential['hash'];
  };
};

export type DrepKeyHashVoter = {
  __typename: VoterType.dRepKeyHash;
  credential: {
    type: CredentialType.KeyHash;
    hash: Credential['hash'];
  };
};

export type DrepScriptHashVoter = {
  __typename: VoterType.dRepScriptHash;
  credential: {
    type: CredentialType.ScriptHash;
    hash: Credential['hash'];
  };
};

export type StakePoolKeyHashVoter = {
  __typename: VoterType.stakePoolKeyHash;
  credential: {
    type: CredentialType.KeyHash;
    hash: Credential['hash'];
  };
};

export type Voter =
  | ConstitutionalCommitteeKeyHashVoter
  | ConstitutionalCommitteeScriptHashVoter
  | DrepKeyHashVoter
  | DrepScriptHashVoter
  | StakePoolKeyHashVoter;

export type VotingProcedures = Map<Voter, Map<GovernanceAction, VotingProcedure>>;

export type ProposalProcedure = {
  deposit: Lovelace;
  rewardAccount: RewardAccount;
  governanceAction: GovernanceAction;
  anchor: Anchor;
};

export type AlwaysAbstain = {
  __typename: 'AlwaysAbstain';
};

export type AlwaysNoConfidence = {
  __typename: 'AlwaysNoConfidence';
};

export type DelegateRepresentative = Credential | AlwaysAbstain | AlwaysNoConfidence;
