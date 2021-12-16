import { Cardano } from '@cardano-sdk/core';
import { Epoch } from './Epoch';
import { Field, ObjectType } from 'type-graphql';
import { Int64 } from './util';
import { RewardAccount } from './Address';
import { StakePool } from './StakePool/StakePool';

@ObjectType()
export class ActiveStake {
  @Field(() => RewardAccount)
  rewardAccount: RewardAccount;
  @Field(() => Int64)
  quantity: Cardano.Lovelace;
  @Field(() => Epoch)
  epoch: Epoch;
  @Field(() => StakePool)
  stakePool: StakePool;
}
