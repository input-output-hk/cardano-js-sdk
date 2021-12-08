import { Field, Int, ObjectType } from 'type-graphql';

@ObjectType()
export class ExecutionUnits {
  @Field(() => Int)
  memory: number;
  @Field(() => Int)
  steps: number;
}

@ObjectType()
export class ExecutionPrice {
  @Field(() => Int)
  numerator: number;
  @Field(() => Int)
  denominator: number;
}

@ObjectType()
export class ExecutionPrices {
  @Field(() => ExecutionPrice)
  prSteps: ExecutionPrice;
  @Field(() => ExecutionPrice)
  prMem: ExecutionPrice;
}
