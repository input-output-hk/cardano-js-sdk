import { Cardano } from '@cardano-sdk/core';
import { Field, Int, ObjectType } from 'type-graphql';
import { Redeemer } from './Redeemer';
import { Transaction } from './Transaction';
import { Value } from './Value';

@ObjectType()
export class TransactionInput {
  @Field(() => String)
  address: Cardano.Address;
  @Field(() => Redeemer, { nullable: true })
  redeemer?: Redeemer;
  // Review: what is the difference between 'transaction' and 'sourceTransaction'?
  // Is one of them an inverse for Transaction.collateral? If so, should probably be nullable?
  // @Field(() => Transaction)
  // sourceTransaction: Transaction;
  @Field(() => Transaction)
  transaction: Transaction;
  @Field(() => Int)
  index: number;
  @Field(() => Value)
  value: Value;
}
