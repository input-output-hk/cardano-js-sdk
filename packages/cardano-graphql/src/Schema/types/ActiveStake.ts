import { Cardano } from '@cardano-sdk/core';
import { Epoch } from './Epoch';
import { Field, ObjectType } from 'type-graphql';
import { RewardAccount } from './Address';
import { StakePool } from './StakePool';

@ObjectType()
export class ActiveStake {
  @Field(() => RewardAccount)
  rewardAccount: RewardAccount;
  @Field(() => String)
  quantity: Cardano.Lovelace;
  @Field(() => Epoch)
  epoch: Epoch;
  @Field(() => StakePool)
  stakePool: StakePool;
}
