import * as Crypto from '@cardano-sdk/crypto';
import { EpochNo, Slot } from './Block';
import { Fraction } from '.';
import { PlutusLanguageVersion } from './Script';

/* eslint-disable no-use-before-define */
export interface ProtocolVersion {
  major: number;
  minor: number;
  patch?: number;
}

/**
 * Cost models are a way to provide predictable pricing for script execution by specifying
 * how much each OP costs in terms of memory and CPU steps.
 */
export type CostModel = Array<number>;

/**
 * Each language version can have a different set of OP costs. CostModels is a map of
 * plutus language version to its defined cost.
 */
export type CostModels = Map<PlutusLanguageVersion, CostModel>;

export interface Prices {
  memory: number;
  steps: number;
}
export interface ExUnits {
  memory: number;
  steps: number;
}

export interface ValidityInterval {
  invalidBefore?: Slot;
  invalidHereafter?: Slot;
}

export interface TxFeePolicy {
  coefficient: string;
  constant: number;
}

export interface SoftforkRule {
  initThreshold: string;
  minThreshold: string;
  decrementThreshold: string;
}

type ProtocolParametersByron = {
  heavyDlgThreshold: string;
  maxBlockSize: number;
  maxHeaderSize: number;
  maxProposalSize: number;
  maxTxSize: number;
  mpcThreshold: string;
  scriptVersion: number;
  slotDuration: number;
  unlockStakeEpoch: number;
  updateProposalThreshold: string;
  updateProposalTimeToLive: number;
  updateVoteThreshold: string;
  txFeePolicy: TxFeePolicy;
  softforkRule: SoftforkRule;
};

type NewProtocolParamsInShelley = {
  minFeeCoefficient: number;
  minFeeConstant: number;
  maxBlockBodySize: number;
  maxBlockHeaderSize: number;
  stakeKeyDeposit: number;
  poolDeposit: number | null;
  poolRetirementEpochBound: number;
  desiredNumberOfPools: number;
  poolInfluence: string;
  monetaryExpansion: string;
  treasuryExpansion: string;
  decentralizationParameter: string;
  minUtxoValue: number;
  minPoolCost: number;
  extraEntropy: 'neutral' | string;
  protocolVersion: ProtocolVersion;
};

type ShelleyProtocolParams = Pick<ProtocolParametersByron, 'maxTxSize'> & NewProtocolParamsInShelley;

type NewProtocolParamsInAlonzo = {
  coinsPerUtxoWord: number;
  maxValueSize: number;
  collateralPercentage: number;
  maxCollateralInputs: number;
  costModels: CostModels;
  prices: Prices;
  maxExecutionUnitsPerTransaction: ExUnits;
  maxExecutionUnitsPerBlock: ExUnits;
};

type AlonzoProtocolParams = Omit<ShelleyProtocolParams, 'minUtxoValue'> & NewProtocolParamsInAlonzo;

type NewProtocolParamsInBabbage = {
  coinsPerUtxoByte: number;
};

// coinsPerUtxoWord was replaced by coinsPerUtxoByte and extraEntropy was deprecated.
type BabbageProtocolParameters = Omit<AlonzoProtocolParams, 'coinsPerUtxoWord' | 'extraEntropy'> &
  NewProtocolParamsInBabbage;

// Voting thresholds
export interface PoolVotingThresholds {
  motionNoConfidence: Fraction;
  committeeNormal: Fraction;
  committeeNoConfidence: Fraction;
  hardForkInitiation: Fraction;
}

export interface DelegateRepresentativeThresholds extends PoolVotingThresholds {
  updateConstitution: Fraction;
  ppNetworkGroup: Fraction;
  ppEconomicGroup: Fraction;
  ppTechnicalGroup: Fraction;
  ppGovernanceGroup: Fraction;
  treasuryWithdrawal: Fraction;
}

type NewProtocolParamsInConway = {
  poolVotingThresholds: PoolVotingThresholds;
  dRepVotingThresholds: DelegateRepresentativeThresholds;
  minCommitteeSize: number;
  committeeTermLimit: number;
  governanceActionValidityPeriod: EpochNo;
  governanceActionDeposit: number;
  dRepDeposit: number;
  dRepInactivityPeriod: EpochNo;
};

type ConwayProtocolParameters = BabbageProtocolParameters & NewProtocolParamsInConway;

export type ProtocolParameters = ConwayProtocolParameters;

// Even tho extraEntropy was deprecated on babbage era, it is still present in the ProtocolParametersUpdate structure
// since this structure is backward compatible with all eras.
export type ProtocolParametersUpdate = Partial<ProtocolParameters & Pick<AlonzoProtocolParams, 'extraEntropy'>>;

export type GenesisDelegateKeyHash = Crypto.Hash28ByteBase16;
export type ProposedProtocolParameterUpdates = Map<GenesisDelegateKeyHash, ProtocolParametersUpdate>;

export type Update = {
  epoch: EpochNo;
  proposedProtocolParameterUpdates: ProposedProtocolParameterUpdates;
};
