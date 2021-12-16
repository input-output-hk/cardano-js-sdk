/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable no-use-before-define */
import { Block } from '../Block';
import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, Float, Int, ObjectType, registerEnumType } from 'type-graphql';
import { Int64, percentageDescription } from '../util';
import { PoolParameters } from './PoolParameters';
import { PoolRegistrationCertificate, PoolRetirementCertificate } from '../Transaction/Certificate';

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
  live: number;
  @Field({ description: percentageDescription })
  // @Field()
  active: number;
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
  @Field(() => StakePoolMetrics)
  metrics: StakePoolMetrics;
  @Directive('@hasInverse(field: stakePool)')
  @Field(() => [PoolRetirementCertificate])
  poolRetirementCertificates: PoolRegistrationCertificate[];
}
