import { Address } from '../Address';
import { Field, Int, ObjectType } from 'type-graphql';
import { Redeemer } from './Witness/Redeemer';
import { Transaction } from './Transaction';
import { Value } from './Value';

@ObjectType()
export class TransactionInput {
  // TODO: Probably it has to remain nullable since at first transaction there werent any address
  // Perhaps a nullable reference to TransactionOutput would be better
  // instead of having {address,value} directly on this object
  @Field(() => Address, { nullable: true })
  address: Address;
  // TODO: Probably it has to remain nullable
  @Field(() => Value, { nullable: true })
  value: Value;
  @Field(() => Redeemer, { nullable: true })
  redeemer?: Redeemer;
  @Field(() => Transaction, { description: 'Output of' })
  sourceTransaction: Transaction;
  @Field(() => Transaction)
  transaction: Transaction;
  @Field(() => Int)
  index: number;
}
