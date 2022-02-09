import { GraphQLClient } from 'graphql-request';
import { RequestInit } from 'graphql-request/dist/types.dom';
import { getSdk } from './sdk';
import { jsonSerializer } from './util';

export const createSDK = (url: string, options?: Omit<RequestInit, 'jsonSerializer'>) => {
  const client = new GraphQLClient(url, {
    ...options,
    jsonSerializer
  });
  return getSdk(client);
};
