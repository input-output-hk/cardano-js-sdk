import { Cardano } from '@cardano-sdk/core';
import { Field, ObjectType } from 'type-graphql';
import { Token } from './Token';

@ObjectType()
export class Value {
  @Field(() => [Token], { nullable: true })
  assets?: Token[];
  @Field(() => String)
  coin: Cardano.Lovelace;
}
