import { GraphQLSchema } from 'graphql';
import { buildSchema } from 'type-graphql';
import { Container } from 'typedi';
import { resolvers } from './resolvers';

export const build = (): Promise<GraphQLSchema> =>
  buildSchema({
    resolvers,
    container: Container
  });
