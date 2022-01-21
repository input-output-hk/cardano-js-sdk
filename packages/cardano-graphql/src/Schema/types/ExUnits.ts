import { Field, Int, ObjectType } from 'type-graphql';
import { Ratio } from './Ratio';

@ObjectType()
export class ExecutionUnits {
  @Field(() => Int)
  memory: number;
  @Field(() => Int)
  steps: number;
}
@ObjectType()
export class ExecutionPrices {
  @Field(() => Ratio)
  prSteps: Ratio;
  @Field(() => Ratio)
  prMem: Ratio;
}
