import { Cardano } from '@cardano-sdk/core';
import { Directive, Field, ObjectType, registerEnumType } from 'type-graphql';

enum ExtendedPoolStatus {
  active = 'active',
  retired = 'retired',
  offline = 'offline',
  experimental = 'experimental',
  private = 'private'
}

registerEnumType(ExtendedPoolStatus, { name: 'ExtendedPoolStatus' });

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
  @Directive('@id')
  @Field(() => String)
  id: Cardano.PoolIdHex;
  @Field({ nullable: true })
  country?: string;
  @Field(() => ExtendedPoolStatus, {
    description: 'active | retired | offline | experimental | private',
    nullable: true
  })
  status?: Cardano.ExtendedPoolStatus;
  @Field(() => PoolContactData, { nullable: true })
  contact?: Cardano.PoolContactData;
  @Field(() => ThePoolsMediaAssets, { nullable: true })
  media_assets?: Cardano.ThePoolsMediaAssets;
  @Field(() => ITNVerification, { nullable: true })
  itn?: Cardano.ITNVerification;
}
