import { Cardano } from '@cardano-sdk/core';
import { Field, Int, ObjectType, registerEnumType } from 'type-graphql';

registerEnumType(Cardano.PoolStatus, { name: 'PoolStatus' });

@ObjectType()
export class ITNVerification implements Cardano.ITNVerification {
  [k: string]: unknown;
  @Field()
  owner: string;
  @Field()
  witness: string;
}

@ObjectType()
export class PoolContactData implements Cardano.PoolContactData {
  [k: string]: unknown;
  @Field()
  primary: string;
  @Field({ nullable: true })
  email?: string;
  @Field({ nullable: true })
  facebook?: string;
  @Field({ nullable: true })
  github?: string;
  @Field({ nullable: true })
  feed?: string;
  @Field({ nullable: true })
  telegram?: string;
  @Field({ nullable: true })
  twitter?: string;
}

@ObjectType()
export class ThePoolsMediaAssets implements Cardano.ThePoolsMediaAssets {
  [k: string]: unknown;
  @Field()
  icon_png_64x64: string;
  @Field({ nullable: true })
  logo_png?: string;
  @Field({ nullable: true })
  logo_svg?: string;
  @Field({ nullable: true })
  color_fg?: string;
  @Field({ nullable: true })
  color_bg?: string;
}

@ObjectType()
export class ExtendedStakePoolMetadataFields implements Cardano.ExtendedStakePoolMetadataFields {
  [k: string]: unknown;
  @Field()
  id: string;
  @Field({ nullable: true })
  country?: string;
  @Field(() => Cardano.PoolStatus, { nullable: true })
  status?: Cardano.PoolStatus;
  @Field(() => PoolContactData, { nullable: true })
  contact?: Cardano.PoolContactData;
  @Field(() => ThePoolsMediaAssets, { nullable: true })
  media_assets?: Cardano.ThePoolsMediaAssets;
  @Field(() => ITNVerification, { nullable: true })
  itn?: Cardano.ITNVerification;
}

@ObjectType()
export class ExtendedStakePoolMetadata implements Cardano.ExtendedStakePoolMetadata {
  [k: string]: unknown;
  @Field(() => Int)
  serial: number;
  @Field(() => ExtendedStakePoolMetadataFields)
  pool: Cardano.ExtendedStakePoolMetadataFields;
}
