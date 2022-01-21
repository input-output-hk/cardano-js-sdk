import { Cardano } from '@cardano-sdk/core';
import { Field, Int, ObjectType } from 'type-graphql';

@ObjectType()
export class Asset {
  @Field(() => String)
  assetId: Cardano.AssetId;
  @Field(() => String)
  assetName: Cardano.AssetName;
  @Field(() => Int)
  decimals: number;
  @Field(() => String)
  description: string;
  @Field(() => String)
  fingerprint: Cardano.AssetFingerprint;
  // TODO: add missing fields, refer to Core types
}
