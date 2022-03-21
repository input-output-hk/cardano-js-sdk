import { Cardano } from '@cardano-sdk/core';
import { ExtendedStakePoolMetadataFields } from './ExtendedStakePoolMetadataFields';
import { Field, Int, ObjectType } from 'type-graphql';
import { StakePoolMetadata } from './StakePoolMetadata';

@ObjectType()
export class ExtendedStakePoolMetadata implements Cardano.ExtendedStakePoolMetadata {
  [k: string]: unknown;
  @Field(() => Int)
  serial: number;
  @Field(() => ExtendedStakePoolMetadataFields)
  pool: ExtendedStakePoolMetadataFields;
  @Field(() => StakePoolMetadata)
  metadata: StakePoolMetadata;
}
