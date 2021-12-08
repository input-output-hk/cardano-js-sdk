/* eslint-disable no-use-before-define */
import { Field, Int, ObjectType, createUnionType, registerEnumType } from 'type-graphql';
import { NotImplementedError } from '@cardano-sdk/core';

enum MetadatumStringType {
  other = 'other',
  bytes = 'bytes'
}

enum MetadatumArrayType {
  map = 'array',
  array = 'map'
}

registerEnumType(MetadatumStringType, { name: 'MetadatumStringType' });
registerEnumType(MetadatumArrayType, { name: 'MetadatumArrayType' });

// Review: I think integers will be int32 or int64. We left it as bigint in core types,
// so have to verify and refactor either this or core type
@ObjectType()
class IntegerMetadatum {
  @Field(() => Int)
  value: number;
}

@ObjectType()
class KeyValueMetadatum {
  @Field(() => String)
  key: string;
  @Field(() => Metadatum)
  metadatum: AnyMetadatum;
}

@ObjectType()
class StringMetadatum {
  @Field(() => MetadatumStringType)
  valueType: MetadatumStringType.other;
  @Field(() => String)
  value: string;
}

@ObjectType()
class BytesMetadatum {
  @Field(() => MetadatumStringType)
  valueType: MetadatumStringType.bytes;
  @Field(() => String)
  value: string;
}

@ObjectType()
class MetadatumMap {
  @Field(() => MetadatumArrayType)
  valueType: MetadatumArrayType.map;
  @Field(() => [KeyValueMetadatum])
  value: KeyValueMetadatum[];
}

@ObjectType()
class MetadatumArray {
  @Field(() => MetadatumArrayType)
  valueType: MetadatumArrayType.array;
  // Review: used to be of type JSON, but this type loses information,
  // e.g. bytes are encoded to string, so given a string value we can't really infer type of this metadatum.
  @Field(() => [Metadatum])
  value: AnyMetadatum[];
}

const isArrayMetadatum = (metadatum: AnyMetadatum): metadatum is MetadatumMap | MetadatumArray =>
  Array.isArray(metadatum.value);
const isStringMetadatum = (metadatum: AnyMetadatum): metadatum is StringMetadatum | BytesMetadatum =>
  Array.isArray(metadatum.value);
const isIntegerMetadatum = (metadatum: AnyMetadatum): metadatum is IntegerMetadatum =>
  typeof metadatum.value === 'number';

export const Metadatum = createUnionType({
  name: 'Metadatum',
  resolveType: (metadatum) => {
    if (isStringMetadatum(metadatum)) {
      if (metadatum.valueType === MetadatumStringType.bytes) return BytesMetadatum;
      return StringMetadatum;
    }
    if (isArrayMetadatum(metadatum)) {
      if (metadatum.valueType === MetadatumArrayType.array) return MetadatumArray;
      return MetadatumMap;
    }
    if (isIntegerMetadatum(metadatum)) return IntegerMetadatum;
    throw new NotImplementedError(`Unknown metadatum type: ${typeof metadatum}`);
  },
  // the name of the GraphQL union
  types: () => [MetadatumArray, MetadatumMap, StringMetadatum, BytesMetadatum, IntegerMetadatum] as const
});

export type AnyMetadatum = IntegerMetadatum | MetadatumMap | StringMetadatum | BytesMetadatum | MetadatumArray;
