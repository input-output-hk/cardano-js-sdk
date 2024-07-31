import { Cardano } from '@cardano-sdk/core';
import { CostModelsParamModel } from '../../NetworkInfo/DbSyncNetworkInfoProvider/types';

export type TransactionDataMap<T> = Map<Cardano.TransactionId, T>;
export type TxOutTokenMap = Map<string, Cardano.TokenMap>;
export type TxTokenMap = TransactionDataMap<Cardano.TokenMap>;
export type TxOutScriptMap = Map<string, Cardano.Script>;

export interface BlockModel {
  block_no: number;
  epoch_no: number;
  epoch_slot_no: number;
  hash: Buffer;
  next_block: Buffer | null;
  previous_block: Buffer | null;
  size: number;
  slot_leader_hash: Buffer;
  slot_leader_pool: string | null;
  slot_no: string;
  time: string;
  tx_count: string;
  vrf: string;
}

export interface BlockOutputModel {
  fees: string;
  output: string;
  hash: Buffer;
}

export interface TipModel {
  block_no: number;
  hash: Buffer;
  slot_no: number;
}

export interface TxModel {
  id: Buffer;
  index: number;
  size: number;
  fee: string;
  valid_contract: boolean;
  invalid_before: string | null;
  invalid_hereafter: string | null;
  block_no: number;
  block_hash: Buffer;
  block_slot_no: number;
}

export interface TxInputModel {
  address: string;
  id: string;
  index: number;
  tx_input_id: Buffer;
  tx_source_id: Buffer;
}

export interface TxInput {
  address: Cardano.PaymentAddress;
  id: string;
  index: number;
  txInputId: Cardano.TransactionId;
  txSourceId: Cardano.TransactionId;
}

export interface TxOutputModel {
  address: string;
  coin_value: string;
  datum?: Buffer | null;
  id: string;
  index: number;
  reference_script_id: number | null;
  tx_id: Buffer;
}

export interface TxOutput extends Cardano.TxOut {
  txId: Cardano.TransactionId;
  index: number;
}

export interface MultiAssetModel {
  asset_name: Buffer;
  fingerprint: string;
  policy_id: Buffer;
  quantity: string;
  tx_id: Buffer;
}

export interface TxOutMultiAssetModel extends MultiAssetModel {
  tx_out_id: string;
}

export interface ScriptModel {
  type: 'timelock' | 'plutusV1' | 'plutusV2' | 'plutusV3';
  bytes: Buffer;
  hash: Buffer;
  serialised_size: number;
}

export interface WithdrawalModel {
  quantity: string;
  tx_id: Buffer;
  stake_address: string;
}

export interface RedeemerModel {
  index: number;
  purpose: 'cert' | 'mint' | 'spend' | 'reward' | 'voting' | 'proposing';
  script_hash: Buffer;
  unit_mem: string;
  unit_steps: string;
  tx_id: Buffer;
}

type VoterRole = 'ConstitutionalCommittee' | 'DRep' | 'SPO';

export interface VotingProceduresModel {
  tx_id: Buffer;
  voter_role: VoterRole;
  drep_voter: Buffer | null;
  committee_voter: Buffer | null;
  committee_has_script: boolean;
  pool_voter: Buffer | null;
  governance_action_tx_id: Buffer;
  governance_action_index: number;
  drep_hash_raw: string;
  drep_has_script: boolean;
  pool_hash_hash_raw: string;
  vote: Cardano.Vote;
  url: string;
  data_hash: Buffer | null;
}

export interface ProposalProcedureModel {
  data_hash: Buffer;
  deposit: string;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  description: any;
  tx_id: Buffer;
  type: string;
  url: string;
  view: string;
  // LW-9675
  numerator?: string;
  denominator?: string;
}

export interface CertificateModel {
  cert_index: number;
  tx_id: Buffer;
}
export type WithCertIndex<T extends Cardano.Certificate> = T & { cert_index: number };
export type WithCertType<T extends CertificateModel> = T & {
  type:
    | 'retire'
    | 'register'
    | 'mir'
    | 'stake'
    | 'delegation'
    | 'registration'
    | 'unregistration'
    | 'voteDelegation'
    | 'stakeVoteDelegation'
    | 'stakeRegistrationDelegation'
    | 'voteRegistrationDelegation'
    | 'stakeVoteRegistrationDelegation'
    | 'registerDrep'
    | 'unregisterDrep'
    | 'updateDrep'
    | 'authorizeCommitteeHot'
    | 'resignCommitteeCold';
};

export interface PoolRetireCertModel extends CertificateModel {
  retiring_epoch: number;
  pool_id: string;
}

export interface PoolRegisterCertModel extends CertificateModel {
  pool_id: string;
  deposit: string;
}

export interface MirCertModel extends CertificateModel {
  amount: string;
  pot: 'reserve' | 'treasury';
  address: string;
}

export interface StakeCertModel extends CertificateModel {
  address: string;
  deposit: string;
  registration: boolean;
}

export interface DelegationCertModel extends CertificateModel {
  address: string;
  pool_id: string;
}

export interface DrepCertModel extends CertificateModel {
  has_script: boolean;
  drep_hash: Buffer;
  url: string | null;
  data_hash: Buffer | null;
  deposit: string;
}

export interface VoteDelegationCertModel extends CertificateModel {
  has_script: boolean;
  drep_hash: Buffer;
  address: string;
}

export type StakeVoteDelegationCertModel = DelegationCertModel & VoteDelegationCertModel;
export type StakeRegistrationDelegationCertModel = StakeCertModel & DelegationCertModel;
export type VoteRegistrationDelegationCertModel = StakeCertModel & VoteDelegationCertModel;
export type StakeVoteRegistrationDelegationCertModel = StakeCertModel & DelegationCertModel & VoteDelegationCertModel;

export interface AuthorizeCommitteeHotCertModel extends CertificateModel {
  cold_key: Buffer;
  cold_key_has_script: boolean;
  hot_key: Buffer;
  hot_key_has_script: boolean;
}

export interface ResignCommitteeColdCertModel extends CertificateModel {
  cold_key: Buffer;
  cold_key_has_script: boolean;
  url: string;
  data_hash: string;
}

export interface TxIdModel {
  tx_id: string;
}

export type ProtocolParametersUpdateModel = Partial<{
  maxTxSize: number;
  costModels: CostModelsParamModel | null;
  txFeeFixed: number;
  dRepDeposit: number;
  minPoolCost: number;
  treasuryCut: Cardano.Fraction | number;
  dRepActivity: number;
  maxValueSize: number;
  txFeePerByte: number;
  utxoCostPerByte: number;
  committeeMinSize: number;
  govActionDeposit: number;
  maxBlockBodySize: number;
  stakePoolDeposit: number;
  govActionLifetime: number;
  monetaryExpansion: Cardano.Fraction | number;
  maxBlockHeaderSize: number;
  poolRetireMaxEpoch: number;
  stakePoolTargetNum: number;
  executionUnitPrices: {
    priceSteps: Cardano.Fraction | number;
    priceMemory: Cardano.Fraction | number;
  };
  maxCollateralInputs: number;
  maxTxExecutionUnits: { steps: number; memory: number };
  poolPledgeInfluence: Cardano.Fraction | number;
  stakeAddressDeposit: number;
  collateralPercentage: number;
  dRepVotingThresholds: {
    ppGovGroup: Cardano.Fraction | number;
    ppNetworkGroup: Cardano.Fraction | number;
    committeeNormal: Cardano.Fraction | number;
    ppEconomicGroup: Cardano.Fraction | number;
    ppTechnicalGroup: Cardano.Fraction | number;
    hardForkInitiation: Cardano.Fraction | number;
    motionNoConfidence: Cardano.Fraction | number;
    treasuryWithdrawal: Cardano.Fraction | number;
    updateToConstitution: Cardano.Fraction | number;
    committeeNoConfidence: Cardano.Fraction | number;
  };
  poolVotingThresholds: {
    committeeNormal: Cardano.Fraction | number;
    ppSecurityGroup: Cardano.Fraction | number;
    hardForkInitiation: Cardano.Fraction | number;
    motionNoConfidence: Cardano.Fraction | number;
    committeeNoConfidence: Cardano.Fraction | number;
  };
  committeeMaxTermLength: number;
  maxBlockExecutionUnits: { steps: number; memory: number };
  minFeeRefScriptCostPerByte: Cardano.Fraction | number;
}>;
