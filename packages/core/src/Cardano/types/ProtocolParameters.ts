/* eslint-disable no-use-before-define */
import { Slot } from '../';

export interface ProtocolVersion {
  major: number;
  minor: number;
  patch?: number;
}

export type ModelKey = string;

export type CostModel = {
  [k: ModelKey]: number;
};

export type CostModels = CostModel[];

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

type BabbageProtocolParameters = Omit<AlonzoProtocolParams, 'coinsPerUtxoWord' | 'extraEntropy'> &
  NewProtocolParamsInBabbage;

export type ProtocolParameters = BabbageProtocolParameters;
