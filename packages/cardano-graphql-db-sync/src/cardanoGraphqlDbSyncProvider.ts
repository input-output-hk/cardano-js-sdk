import { CardanoProvider } from '@cardano-sdk/core';
import { gql, GraphQLClient } from 'graphql-request';
import { TransactionSubmitResponse } from '@cardano-graphql/client-ts';
import { Schema as Cardano } from '@cardano-ogmios/client';
import { graphqlTransactionsToCardanoTxs } from './utils';

/**
 * Connect to a [cardano-graphql (cardano-db-sync) service](https://github.com/input-output-hk/cardano-graphql)
 * ```typescript
 * const provider = cardanoGraphqlDbSyncProvider(uri: 'http://localhost:3100');
 * ```
 */

export const cardanoGraphqlDbSyncProvider = (uri: string): CardanoProvider => {
  const client = new GraphQLClient(uri);

  const submitTx: CardanoProvider['submitTx'] = async (signedTransaction) => {
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

      const response = await client.request<Response, Variables>(mutation, { transaction: signedTransaction });

      return !!response.hash;
    } catch {
      return false;
    }
  };

  const utxo: CardanoProvider['utxo'] = async (addresses) => {
    const query = gql`
      query ($addresses: [String]!) {
        utxos(where: { address: { _in: $addresses } }) {
          transaction {
            hash
          }
          index
          address
          value # coins
          tokens {
            asset {
              assetId # asset key
            }
            quantity
          }
        }
      }
    `;

    type Utxo = {
      transaction: { hash: Cardano.Hash16 };
      index: number;
      address: Cardano.Address;
      value: string;
      tokens: {
        asset: {
          assetId: string;
        };
        quantity: string;
      }[];
    };
    type Response = { utxos: Utxo[] };
    type Variables = { addresses: string[] };

    const response = await client.request<Response, Variables>(query, { addresses });

    return response.utxos.map((uxto) => {
      const assets: Cardano.Value['assets'] = {};

      for (const t of uxto.tokens) assets[t.asset.assetId] = BigInt(t.quantity);

      return [
        { txId: uxto.transaction.hash, index: uxto.index },
        { address: uxto.address, value: { coins: Number(uxto.value), assets } }
      ];
    });
  };

  const queryTransactionsByAddresses: CardanoProvider['queryTransactionsByAddresses'] = async (addresses) => {
    const query = gql`
      query ($addresses: [String]!) {
        transactions(
          where: { _or: [{ inputs: { address: { _in: $addresses } } }, { outputs: { address: { _in: $addresses } } }] }
        ) {
          hash
          inputs {
            txHash
            sourceTxIndex
          }
          outputs {
            address
            value
            tokens {
              asset {
                assetId
              }
              quantity
            }
          }
        }
      }
    `;

    type Response = {
      transactions: {
        hash: Cardano.Hash16;
        inputs: { txHash: Cardano.Hash16; sourceTxIndex: number }[];
        outputs: {
          address: Cardano.Address;
          value: string;
          tokens: { asset: { assetId: string }; quantity: string }[];
        }[];
      }[];
    };
    type Variables = { addresses: string[] };

    const response = await client.request<Response, Variables>(query, { addresses });

    return graphqlTransactionsToCardanoTxs(response.transactions);
  };

  const queryTransactionsByHashes: CardanoProvider['queryTransactionsByHashes'] = async (hashes) => {
    const query = gql`
      query ($hashes: [Hash32Hex]!) {
        transactions(where: { hash: { _in: $hashes } }) {
          hash
          inputs {
            txHash
            sourceTxIndex
          }
          outputs {
            address
            value
            tokens {
              asset {
                assetId
              }
              quantity
            }
          }
        }
      }
    `;

    type Response = {
      transactions: {
        hash: Cardano.Hash16;
        inputs: { txHash: Cardano.Hash16; sourceTxIndex: number }[];
        outputs: {
          address: Cardano.Address;
          value: string;
          tokens: { asset: { assetId: string }; quantity: string }[];
        }[];
      }[];
    };
    type Variables = { hashes: string[] };

    const response = await client.request<Response, Variables>(query, { hashes });

    return graphqlTransactionsToCardanoTxs(response.transactions);
  };

  return {
    submitTx,
    utxo,
    queryTransactionsByAddresses,
    queryTransactionsByHashes
  };
};
