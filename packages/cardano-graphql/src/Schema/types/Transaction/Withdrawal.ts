import { Cardano } from '@cardano-sdk/core';
import { Field, ObjectType } from 'type-graphql';
import { Int64 } from '../util';
import { Redeemer } from './Witness/Redeemer';
import { RewardAccount } from '../Address';
import { Transaction } from './Transaction';

@ObjectType()
export class Withdrawal {
  @Field(() => RewardAccount)
  rewardAccount: RewardAccount;
  @Field(() => Int64)
  quantity: Cardano.Lovelace;
  @Field(() => String, { nullable: true })
  redeemer?: Redeemer;
  @Field(() => Transaction)
  transaction: Transaction;
}
