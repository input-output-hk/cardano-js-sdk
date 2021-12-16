/* eslint-disable no-use-before-define */
import { Field, Int, ObjectType, createUnionType } from 'type-graphql';
import { NotImplementedError } from '@cardano-sdk/core';

// Review: I think integers will be int32 or int64. We left it as bigint in core types,
// so have to verify and refactor either this or core type
@ObjectType()
class IntegerMetadatum {
  @Field(() => Int)
  int: number;
}

@ObjectType()
export class KeyValueMetadatum {
  @Field(() => String)
  key: string;
  @Field(() => Metadatum)
  metadatum: AnyMetadatum;
}

@ObjectType()
class StringMetadatum {
  @Field(() => String)
  string: string;
}

@ObjectType()
class BytesMetadatum {
  @Field(() => String)
  bytes: string;
}

@ObjectType()
class MetadatumMap {
  @Field(() => [KeyValueMetadatum])
  map: KeyValueMetadatum[];
}

@ObjectType()
class MetadatumArray {
  // Review: used to be of type JSON, but this type loses information,
  // e.g. bytes are encoded to string, so given a string value we can't really infer type of this metadatum.
  @Field(() => [Metadatum])
  array: AnyMetadatum[];
}

export const Metadatum = createUnionType({
  name: 'Metadatum',
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  resolveType: (metadatum: any) => {
    if (metadatum.bytes) return BytesMetadatum;
    if (metadatum.string) return StringMetadatum;
    if (metadatum.array) return MetadatumArray;
    if (metadatum.map) return MetadatumMap;
    if (metadatum.int) return IntegerMetadatum;
    throw new NotImplementedError(`Unknown metadatum type: ${typeof metadatum}`);
  },
  // the name of the GraphQL union
  types: () => [MetadatumArray, MetadatumMap, StringMetadatum, BytesMetadatum, IntegerMetadatum] as const
});

export type AnyMetadatum = IntegerMetadatum | MetadatumMap | StringMetadatum | BytesMetadatum | MetadatumArray;
