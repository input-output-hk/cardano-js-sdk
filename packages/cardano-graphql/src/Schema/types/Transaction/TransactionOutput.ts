import { Address } from '../Address';
import { Field, Int, ObjectType } from 'type-graphql';
import { Transaction } from './Transaction';
import { Value } from './Value';

@ObjectType()
export class TransactionOutput {
  @Field(() => Address)
  address: Address;
  @Field(() => Int)
  index: number;
  @Field(() => Transaction)
  transaction: Transaction;
  @Field(() => Value)
  value: Value;
}
