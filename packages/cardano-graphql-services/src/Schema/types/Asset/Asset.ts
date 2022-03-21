import { Asset as AssetTypes, Cardano } from '@cardano-sdk/core';
import { Directive, Field, ObjectType } from 'type-graphql';
import { Int64 } from '../util';
import { NftMetadata } from './NftMetadata';
import { Policy } from './Policy';
import { TokenMetadata } from './TokenMetadata';
import { Transaction } from '../Transaction';

@ObjectType()
export class AssetMintOrBurn {
  @Field(() => Int64)
  quantity: number;
  @Field(() => Transaction)
  transaction: Transaction;
}

@ObjectType()
export class Asset {
  @Directive('@id')
  @Directive('@search(by: [exact])')
  @Field(() => String, { description: 'concatenated PolicyId and AssetName, hex-encoded' })
  assetId: Cardano.AssetId;
  @Field(() => String, { description: 'hex-encoded' })
  assetName: Cardano.AssetName;
  @Field(() => String)
  assetNameUTF8: string;
  @Field(() => Policy)
  policy: Policy;
  // this value could be easily computed from history,
  // but is probably good to have for performance reasons:
  // there can be A LOT of mints/burns for an asset,
  // and it is a very relevant piece of data
  @Field(() => Int64)
  totalQuantity: number;
  @Field(() => String, { description: 'Fingerprint of a native asset for human comparison. CIP-0014' })
  fingerprint: Cardano.AssetFingerprint;
  @Field(() => [AssetMintOrBurn])
  history: AssetTypes.AssetMintOrBurn[];
  @Directive('@hasInverse(field: asset)')
  @Field(() => TokenMetadata, { description: 'CIP-0035', nullable: true })
  tokenMetadata?: AssetTypes.TokenMetadata;
  @Directive('@hasInverse(field: asset)')
  @Field(() => NftMetadata, { description: 'CIP-0025', nullable: true })
  nftMetadata?: NftMetadata;
}
