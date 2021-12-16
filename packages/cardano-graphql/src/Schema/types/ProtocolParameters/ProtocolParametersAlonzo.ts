import { CostModel } from './CostModel';
import { ExecutionPrices, ExecutionUnits } from '../ExUnits';
import { Field, Int, ObjectType } from 'type-graphql';
import { ProtocolParametersShelley } from './ProtocolParametersShelley';

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
