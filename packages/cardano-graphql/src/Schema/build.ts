import { buildSchema } from 'type-graphql';
import { Container } from 'typedi';
import { resolvers } from './resolvers';

export const build = () =>
  buildSchema({
    resolvers,
    container: Container
  });
