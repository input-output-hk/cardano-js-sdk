import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, ObjectType } from 'type-graphql';
import { ExtendedStakePoolMetadata } from './ExtendedStakePoolMetadata';
import { PoolParameters } from './PoolParameters';

@ObjectType()
export class StakePoolMetadata implements Cardano.StakePoolMetadata {
  @Directive('@search(by: [hash])')
  @Field(() => String)
  stakePoolId: Cardano.PoolId;
  @Directive('@search(by: [fulltext])')
  @Field()
  ticker: string;
  @Directive('@search(by: [fulltext])')
  @Field()
  name: string;
  @Field()
  description: string;
  @Field()
  homepage: string;
  @Field({ nullable: true })
  extDataUrl?: string;
  @Field({ nullable: true })
  extSigUrl?: string;
  @Field(() => String, { nullable: true })
  extVkey?: Cardano.PoolMdVk;
  @Field(() => ExtendedStakePoolMetadata, { nullable: true })
  @Directive('@hasInverse(field: metadata)')
  ext?: ExtendedStakePoolMetadata;
  @Field(() => PoolParameters)
  poolParameters: PoolParameters;
}
