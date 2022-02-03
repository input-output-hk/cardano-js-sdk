/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable no-use-before-define */
import { Block } from '../Block';
import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, Float, Int, ObjectType, registerEnumType } from 'type-graphql';
import { Epoch } from '../Epoch';
import { Int64, percentageDescription } from '../util';
import { PoolParameters } from './PoolParameters';
import { PoolRetirementCertificate } from '../Transaction/Certificate';

enum StakePoolStatus {
  activating = 'activating',
  active = 'active',
  retired = 'retired',
  retiring = 'retiring'
}

registerEnumType(StakePoolStatus, { name: 'StakePoolStatus' });

@ObjectType()
export class StakePoolMetricsStake implements Cardano.StakePoolMetricsStake {
  @Field(() => Int64)
  live: Cardano.Lovelace;
  @Field(() => Int64)
  active: Cardano.Lovelace;
}

@ObjectType()
export class StakePoolMetricsSize implements Cardano.StakePoolMetricsSize {
  @Field({ description: percentageDescription })
  live: Cardano.Percent;
  @Field({ description: percentageDescription })
  active: Cardano.Percent;
}

@ObjectType()
export class StakePoolMetrics implements Cardano.StakePoolMetrics {
  @Field(() => Block)
  block: Block;
  @Field(() => Int)
  blockNo: number;
  @Field(() => Int)
  blocksCreated: number;
  @Field(() => Int64)
  livePledge: Cardano.Lovelace;
  @Field(() => StakePoolMetricsStake)
  stake: StakePoolMetricsStake;
  @Field(() => StakePoolMetricsSize)
  size: StakePoolMetricsSize;
  @Field(() => Float)
  saturation: number;
  @Field(() => Int)
  delegators: number;
}

@ObjectType({ description: 'Stake pool performance per epoch, taken at epoch rollover' })
export class StakePoolEpochRewards {
  @Field(() => Epoch)
  epoch: Epoch;
  @Field(() => Int)
  epochNo: number;
  @Field(() => Int)
  epochLength: number;
  @Field(() => Int64)
  activeStake: Cardano.Lovelace;
  @Field(() => Int64)
  operatorFees: Cardano.Lovelace;
  @Field(() => Int64, { description: 'Total rewards for the epoch' })
  totalRewards: Cardano.Lovelace;
  @Field(() => Float, { description: 'rewards/activeStake, not annualized' })
  memberROI: Cardano.Percent;
}

@ObjectType()
export class StakePool {
  @Directive('@search(by: [fulltext])')
  @Directive('@id')
  @Field(() => String)
  id: Cardano.PoolId;
  @Field()
  hexId: string;
  @Directive('@hasInverse(field: stakePool)')
  @Field(() => [PoolParameters])
  poolParameters: PoolParameters[];
  @Field(() => StakePoolStatus, {
    description: 'active | retired | retiring'
  })
  status: Cardano.StakePoolStatus;
  @Field(() => [StakePoolMetrics])
  metrics: StakePoolMetrics[];
  @Directive('@hasInverse(field: stakePool)')
  @Field(() => [PoolRetirementCertificate])
  poolRetirementCertificates: PoolRetirementCertificate[];
  @Field(() => [StakePoolEpochRewards])
  epochRewards: StakePoolEpochRewards[];
}
