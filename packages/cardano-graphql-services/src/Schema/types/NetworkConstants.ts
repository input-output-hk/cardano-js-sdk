import { Field, Float, Int, ObjectType } from 'type-graphql';

@ObjectType()
export class NetworkConstants {
  @Field(() => Int, { description: "same as 'systemStart'" })
  timestamp: number;
  @Field()
  systemStart: Date;
  @Field(() => Int)
  networkMagic: number;
  @Field(() => Float)
  activeSlotsCoefficient: number;
  @Field(() => Int)
  securityParameter: number;
  @Field(() => Int)
  slotsPerKESPeriod: number;
  @Field(() => Int)
  maxKESEvolutions: number;
  @Field(() => Int)
  updateQuorum: number;
}
