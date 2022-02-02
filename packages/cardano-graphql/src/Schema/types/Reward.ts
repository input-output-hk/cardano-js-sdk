import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, Int, ObjectType } from 'type-graphql';
import { Epoch } from './Epoch';
import { Int64 } from './util';
import { RewardAccount } from './Address';
import { StakePool } from './StakePool';

@ObjectType()
export class Reward {
  @Field(() => RewardAccount)
  rewardAccount: RewardAccount;
  @Field(() => Int)
  epochNo: Cardano.Epoch;
  @Field(() => Epoch)
  epoch: Epoch;
  @Field(() => Int)
  spendableAtEpochNo: Cardano.Epoch;
  @Field(() => Int64)
  quantity: Cardano.Lovelace;
  @Directive('@search(by: [exact])')
  @Field(() => String, { description: 'poolMember | poolLeader | treasury | reserves' })
  source: string;
  @Field(() => StakePool, { description: "null when source is 'treasury' or 'reserves'", nullable: true })
  stakePool?: StakePool;
}
