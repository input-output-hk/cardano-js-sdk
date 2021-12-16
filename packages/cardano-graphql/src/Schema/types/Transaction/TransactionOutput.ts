import { Address } from '../Address';
import { Cardano } from '@cardano-sdk/core';
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
  @Field(() => String, { description: 'hex-encoded 32 byte hash', nullable: true })
  datum?: Cardano.Hash32ByteBase16;
}
