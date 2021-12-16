import { Field, Int, ObjectType } from 'type-graphql';

@ObjectType()
export class Ratio {
  @Field(() => Int)
  numerator: number;
  @Field(() => Int)
  denominator: number;
}
