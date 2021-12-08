import { Cardano } from '@cardano-sdk/core';
import { Field, ObjectType } from 'type-graphql';
import { Redeemer } from './Redeemer';
import { Transaction } from './Transaction';

@ObjectType()
export class Withdrawal {
  @Field(() => String)
  rewardAccount: Cardano.RewardAccount;
  @Field(() => String)
  quantity: Cardano.Lovelace;
  @Field(() => String, { nullable: true })
  redeemer?: Redeemer;
  @Field(() => Transaction)
  transaction: Transaction;
}
