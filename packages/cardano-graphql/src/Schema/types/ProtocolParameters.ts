// Review: do we want to keep protocol parameter types per era?

import { Epoch } from './Epoch';
import { ExecutionPrices, ExecutionUnits } from './ExUnits';
import { Field, Int, ObjectType } from 'type-graphql';
import { Ratio } from './Ratio';

@ObjectType()
export class ProtocolVersion {
  @Field(() => Int)
  major: number;
  @Field(() => Int)
  minor: number;
  @Field(() => Int, { nullable: true })
  patch?: number;
}

@ObjectType()
export class CostModelCoefficient {
  @Field(() => String)
  key: string;
  @Field(() => Int)
  coefficient: number;
}

@ObjectType()
export class CostModel {
  @Field(() => String)
  language: string;
  @Field(() => [CostModelCoefficient])
  coefficients: CostModelCoefficient[];
}

@ObjectType()
export class ProtocolParametersShelley {
  @Field(() => Int, { description: 'minfee A' })
  minFeeCoefficient: number;
  @Field(() => Int, { description: 'minfee B' })
  minFeeConstant: number;
  @Field(() => Int)
  maxBlockBodySize: number;
  @Field(() => Int)
  maxBlockHeaderSize: number;
  @Field(() => Int)
  maxTxSize: number;
  @Field(() => Int)
  stakeKeyDeposit: number;
  @Field(() => Int)
  poolDeposit: number;
  @Field(() => Epoch, { description: 'maximum epoch' })
  poolRetirementEpochBound: Epoch;
  @Field(() => Int, { description: 'n_opt' })
  desiredNumberOfPools: number;
  @Field(() => Ratio, { description: 'pool pledge influence' })
  poolInfluence: Ratio;
  @Field(() => Ratio, { description: 'expansion rate' })
  monetaryExpansion: Ratio;
  @Field(() => Ratio, { description: 'treasury growth rate' })
  treasuryExpansion: Ratio;
  @Field(() => Ratio, { description: 'd. decentralization constant' })
  decentralizationParameter: Ratio;
  @Field(() => String, { description: 'hex-encoded, null if neutral', nullable: true })
  extraEntropy?: string;
  @Field(() => ProtocolVersion)
  protocolVersion: ProtocolVersion;
  @Field(() => Int, { description: 'to be used for order in queries' })
  flatProtocolVersion: number;
  @Field(() => Int)
  minUtxoValue: number;
}

@ObjectType()
export class ProtocolParametersAlonzo extends ProtocolParametersShelley {
  @Field(() => Int)
  minPoolCost: number;
  @Field(() => Int)
  coinsPerUtxoWord: number;
  @Field(() => Int)
  maxValueSize: number;
  @Field(() => ExecutionPrices)
  executionPrices: ExecutionPrices;
  @Field(() => [CostModel])
  costModels: CostModel[];
  @Field(() => ExecutionUnits)
  maxExecutionUnitsPerTransaction: ExecutionUnits;
  @Field(() => ExecutionUnits)
  maxExecutionUnitsPerBlock: ExecutionUnits;
  @Field(() => Int)
  collateralPercentage: number;
  @Field(() => Int)
  maxCollateralInputs: number;
}
