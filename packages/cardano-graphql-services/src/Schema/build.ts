import { Block } from './types';
import { Field, ObjectType, Query, Resolver, buildSchema } from 'type-graphql';
import { GraphQLSchema } from 'graphql';

@ObjectType()
class Nothing {
  @Field()
  nothing: string;
}
@Resolver()
export class NothingResolver {
  @Query(() => [Nothing], { description: 'Do not use this' })
  async nothing() {
    return [{ nothing: 'nothing' }];
  }
}

export const build = async (): Promise<GraphQLSchema> => {
  const schema = await buildSchema({
    // Resolves any referenced objects automatically
    orphanedTypes: [Block],
    resolvers: [NothingResolver]
  });
  const config = schema.toConfig();
  config.types = config.types.filter(({ name }) => !['Query', 'Nothing'].includes(name));
  delete config.query;
  return new GraphQLSchema(config);
};
