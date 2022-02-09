import { createSDK } from '../src';
import { jsonSerializer } from '../src/util';

jest.mock('graphql-request');
const { GraphQLClient } = jest.requireMock('graphql-request');

describe('createSDK', () => {
  it('uses custom jsonSerializer', () => {
    createSDK('url');
    expect(GraphQLClient).toBeCalledWith('url', { jsonSerializer });
  });
});
