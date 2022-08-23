/* eslint-disable no-use-before-define */
import { Slot } from '../';

export interface ProtocolVersion {
  major: number;
  minor: number;
  patch?: number;
}
export type CostModels = CostModel[];

export type CostModel = number[];

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

export interface ProtocolParametersBabbage {
  minFeeCoefficient?: number;
  minFeeConstant?: number;
  maxBlockBodySize?: number;
  maxBlockHeaderSize?: number;
  maxTxSize?: number;
  stakeKeyDeposit?: number;
  poolDeposit?: number;
  poolRetirementEpochBound?: number;
  desiredNumberOfPools?: number;
  poolInfluence?: number;
  monetaryExpansion?: number;
  treasuryExpansion?: number;
  minPoolCost?: number;
  coinsPerUtxoByte?: number;
  maxValueSize?: number;
  collateralPercentage?: number;
  maxCollateralInputs?: number;
  protocolVersion?: ProtocolVersion;
  costModels?: CostModels;
  prices?: Prices;
  maxExecutionUnitsPerTransaction?: ExUnits;
  maxExecutionUnitsPerBlock?: ExUnits;
}
