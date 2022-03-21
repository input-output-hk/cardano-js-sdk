/* eslint-disable no-use-before-define */
import { Directive, Field, Int, ObjectType, createUnionType } from 'type-graphql';
import { NotImplementedError } from '@cardano-sdk/core';

@ObjectType()
class IntegerMetadatum {
  @Field(() => Int)
  int: number;
}

@ObjectType()
export class KeyValueMetadatum {
  @Directive('@search(by: [exact,fulltext])')
  @Field(() => String)
  label: string;
  @Field(() => Metadatum)
  metadatum: AnyMetadatum;
}

@ObjectType()
class StringMetadatum {
  @Directive('@search(by: [exact,fulltext])')
  @Field(() => String)
  string: string;
}

@ObjectType()
class BytesMetadatum {
  @Directive('@search(by: [hash])')
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
