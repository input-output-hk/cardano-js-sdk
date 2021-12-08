import { Cardano } from '@cardano-sdk/core';
import { Epoch } from './Epoch';
import { Field, ObjectType } from 'type-graphql';
import { StakePool } from './StakePool';

@ObjectType()
export class ActiveStake {
  @Field(() => String)
  address: Cardano.RewardAccount;
  @Field(() => String)
  quantity: Cardano.Lovelace;
  @Field(() => Epoch)
  epoch: Epoch;
  @Field(() => StakePool)
  stakePool: StakePool;
}
