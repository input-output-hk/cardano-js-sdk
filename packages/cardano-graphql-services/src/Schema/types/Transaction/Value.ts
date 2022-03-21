import { Cardano } from '@cardano-sdk/core';
import { Field, ObjectType } from 'type-graphql';
import { Int64 } from '../util';
import { Token } from './Token';

@ObjectType()
export class Value {
  @Field(() => [Token], { nullable: true })
  assets?: Token[];
  @Field(() => Int64)
  coin: Cardano.Lovelace;
}
