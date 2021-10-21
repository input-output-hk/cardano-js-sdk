import { GraphQLSchema } from 'graphql';
import { Field, ObjectType, Query, Resolver, buildSchema } from 'type-graphql';
import * as types from './types';

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
    resolvers: [NothingResolver],
    orphanedTypes: Object.values(types)
  });
  const config = schema.toConfig();
  config.types = config.types.filter(({ name }) => !['Query', 'Nothing'].includes(name));
  delete config.query;
  return new GraphQLSchema(config);
};
