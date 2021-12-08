import { Cardano } from '@cardano-sdk/core';
import { ExecutionUnits } from '../ExUnits';
import { Field, Int, ObjectType } from 'type-graphql';
import { Transaction } from './Transaction';

@ObjectType()
export class Redeemer {
  @Field(() => String)
  fee: Cardano.Lovelace;
  @Field(() => Int)
  index: number;
  @Field(() => String)
  purpose: Cardano.Redeemer['purpose'];
  @Field(() => String)
  scriptHash: Cardano.Hash28ByteBase16;
  @Field(() => Transaction)
  transaction: Transaction;
  @Field(() => ExecutionUnits)
  executionUnits: Cardano.ExUnits;
}
