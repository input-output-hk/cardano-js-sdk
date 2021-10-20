import { GraphQLScalarType, Kind } from 'graphql';

// Review: not sure if we should do this.
// Might make it difficult to use for other clients?
// Field description is probably the way to go,
// which means we'd need to duplicate it with core type comments.
export const PercentageScalar = new GraphQLScalarType({
  name: 'Percentage',
  description: 'Float in range [0; 1]'
});

export const BigIntScalar = new GraphQLScalarType({
  name: 'BigInt',
  description: 'BigInt scalar type. Serializes to String.',
  serialize(value: unknown): string {
    if (typeof value !== 'bigint') {
      throw new TypeError('BigIntScalar can only serialize "bigint" values');
    }
    return value.toString();
  },
  parseValue(value: unknown): bigint {
    if (typeof value !== 'string') {
      throw new TypeError('BigIntScalar can only parse string values');
    }
    return BigInt(value);
  },
  parseLiteral(ast): bigint {
    if (ast.kind !== Kind.STRING) {
      throw new Error('BigIntScalar can only parse string values');
    }
    return BigInt(ast.value);
  }
});
