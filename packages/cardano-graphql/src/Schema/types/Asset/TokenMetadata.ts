import { Asset } from './Asset';
import { Asset as AssetTypes } from '@cardano-sdk/core';
import { Field, Int, ObjectType } from 'type-graphql';

@ObjectType()
export class TokenMetadataSizedIcon {
  @Field(() => Int, { description: 'Most likely one of 16, 32, 64, 96, 128' })
  size: number;
  @Field(() => String, { description: 'https only url that refers to metadata stored offchain.' })
  icon: string;
}

@ObjectType({ description: 'CIP-0035' })
export class TokenMetadata {
  @Field(() => String)
  name?: string;
  @Field(() => String, {
    description: 'when present, field and overrides default ticker which is the asset name',
    nullable: true
  })
  ticker?: string;
  @Field(() => String, {
    description: 'MUST be either https, ipfs, or data.  icon MUST be a browser supported image format.',
    nullable: true
  })
  icon?: string; // Could also be coming from deprecated 'logo' or 'image' fields
  @Field(() => String, {
    description: 'https only url that refers to metadata stored offchain.',
    nullable: true
  })
  url?: string;
  @Field(() => String, {
    description: 'additional description that defines the usage of the token',
    nullable: true
  })
  desc?: string;
  @Field(() => Int, {
    description:
      'how many decimal places should the token support? For ADA, this would be 6 e.g. 1 ADA is 10^6 Lovelace',
    nullable: true
  })
  decimals?: number;
  @Field(() => String, {
    description: 'https only url that holds the metadata in the onchain format.',
    nullable: true
  })
  ref?: string;
  @Field(() => String, { defaultValue: '1.0' })
  version: string;
  @Field(() => [TokenMetadataSizedIcon])
  sizedIcons: AssetTypes.TokenMetadataSizedIcon[];
  @Field(() => Asset)
  asset: Asset;
}
