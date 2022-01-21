import { Field, Int, ObjectType } from 'type-graphql';

@ObjectType()
export class CostModelCoefficient {
  @Field(() => String)
  key: string;
  @Field(() => Int)
  coefficient: number;
}
