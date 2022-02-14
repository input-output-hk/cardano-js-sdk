import { Asset } from './Asset';
import { Field, ObjectType } from 'type-graphql';

@ObjectType()
export class NftMetadataFile {
  @Field(() => String)
  name: string;
  @Field(() => String)
  mediaType: string;
  @Field(() => [String])
  src: string[];
  // Not saving 'other properties' in the db,
  // We could only save them as blobs as we don't know the type
}

@ObjectType({ description: 'CIP-0025' })
export class NftMetadata {
  @Field(() => String)
  name: string;
  @Field(() => [String])
  images: string[];
  @Field(() => String)
  version: string;
  @Field(() => String, { nullable: true })
  mediaType?: string;
  @Field(() => [NftMetadataFile])
  files: NftMetadataFile[];
  @Field(() => [String])
  descriptions: string[];
  @Field(() => Asset)
  asset: Asset;
  // Not saving 'other properties' in the db,
  // We could only save them as blobs as we don't know the type
}
