import { Address } from '../Address';
import { Field, Int, ObjectType } from 'type-graphql';
import { Redeemer } from './Redeemer';
import { Transaction } from './Transaction';
import { Value } from './Value';

@ObjectType()
export class TransactionInput {
  @Field(() => Address)
  address: Address;
  @Field(() => Redeemer, { nullable: true })
  redeemer?: Redeemer;
  @Field(() => Transaction, { description: 'Output of' })
  sourceTransaction: Transaction;
  @Field(() => Transaction)
  transaction: Transaction;
  @Field(() => Int)
  index: number;
  @Field(() => Value)
  value: Value;
}
