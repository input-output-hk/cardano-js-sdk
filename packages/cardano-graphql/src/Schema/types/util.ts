import { GraphQLScalarType, Kind } from 'graphql';
import { SerializationError, SerializationFailure } from '@cardano-sdk/core';

export const percentageDescription = 'Percentage in range [0; 1]';

export type BigIntsAsStrings<T> = bigint extends T
  ? string // Note: Add interfaces here of all GraphQL scalars that will be transformed into an object
  : T extends Date
  ? T
  : {
      [K in keyof T]: T[K] extends (infer U)[] ? BigIntsAsStrings<U>[] : BigIntsAsStrings<T[K]>;
    };

export type Json = string;

export const Int64 = new GraphQLScalarType({
  name: 'Int64',
  parseLiteral(ast): bigint {
    if (ast.kind !== Kind.STRING) {
      throw new SerializationError(SerializationFailure.InvalidType);
    }
    return BigInt(ast.value);
  },
  parseValue(value: unknown): bigint {
    if (typeof value !== 'bigint' || typeof value !== 'number') {
      throw new SerializationError(SerializationFailure.InvalidType);
    }
    return BigInt(value);
  },
  serialize(value: unknown): bigint {
    if (typeof value !== 'bigint' && typeof value !== 'number') {
      throw new SerializationError(SerializationFailure.InvalidType);
    }
    if (value > 9_223_372_036_854_775_807n || value < -9_223_372_036_854_775_808n) {
      throw new SerializationError(SerializationFailure.Overflow);
    }
    return BigInt(value);
  }
});
