import { CostModelCoefficient } from './CostModelCoefficient';
import { Field, ObjectType } from 'type-graphql';

@ObjectType()
export class CostModel {
  @Field(() => String)
  language: string;
  @Field(() => [CostModelCoefficient])
  coefficients: CostModelCoefficient[];
}
