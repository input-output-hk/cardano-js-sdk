import { Buffer } from 'buffer';
import { GraphQLClient, gql } from 'graphql-request';
import { ProviderError, ProviderFailure, TxSubmitProvider } from '@cardano-sdk/core';
import { TransactionSubmitResponse } from '@cardano-graphql/client-ts';

/**
 * Connect to a [cardano-graphql (cardano-db-sync) service](https://github.com/input-output-hk/cardano-graphql)
 * ```typescript
 * const provider = cardanoGraphqlDbSyncTxSubmitProvider(uri: 'http://localhost:3100');
 * ```
 */

export const cardanoGraphqlDbSyncTxSubmitProvider = (uri: string): TxSubmitProvider => {
  const client = new GraphQLClient(uri);

  const submitTx: TxSubmitProvider['submitTx'] = async (signedTransaction) => {
    try {
      const mutation = gql`
        mutation ($transaction: String!) {
          submitTransaction(transaction: $transaction) {
            hash
          }
        }
      `;

      type Response = TransactionSubmitResponse;
      type Variables = { transaction: string };

      const response = await client.request<Response, Variables>(mutation, {
        transaction: Buffer.from(signedTransaction).toString('hex')
      });

      if (!response.hash) {
        throw new Error('No "hash" in graphql response');
      }
    } catch (error) {
      throw new ProviderError(ProviderFailure.Unknown, error);
    }
  };

  return {
    submitTx
  };
};
