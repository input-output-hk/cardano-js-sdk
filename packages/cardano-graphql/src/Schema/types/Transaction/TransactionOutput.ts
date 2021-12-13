import { Cardano } from '@cardano-sdk/core';
import { Field, Int, ObjectType } from 'type-graphql';
import { Transaction } from './Transaction';
import { Value } from './Value';

@ObjectType()
export class TransactionOutput {
  @Field(() => String)
  address: Cardano.Address;
  @Field(() => Int)
  index: number;
  @Field(() => Transaction)
  transaction: Transaction;
  @Field(() => Value)
  value: Value;
}
