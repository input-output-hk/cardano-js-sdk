import { CardanoProvider } from '@cardano-sdk/core';
import { gql, GraphQLClient } from 'graphql-request';
import { TransactionSubmitResponse } from '@cardano-graphql/client-ts';
import { Schema as Cardano } from '@cardano-ogmios/client';
import {
  CardanoGraphqlToOgmios,
  GraphqlCurrentWalletProtocolParameters,
  CardanoGraphQlTip
} from './CardanoGraphqlToOgmios';

/**
 * Connect to a [cardano-graphql (cardano-db-sync) service](https://github.com/input-output-hk/cardano-graphql)
 * ```typescript
 * const provider = cardanoGraphqlDbSyncProvider(uri: 'http://localhost:3100');
 * ```
 */

export const cardanoGraphqlDbSyncProvider = (uri: string): CardanoProvider => {
  const client = new GraphQLClient(uri);

  const ledgerTip: CardanoProvider['ledgerTip'] = async () => {
    const query = gql`
      query {
        cardano {
          tip {
            hash
            number
            slotNo
          }
        }
      }
    `;

    type Response = {
      cardano: {
        tip: CardanoGraphQlTip;
      };
    };

    const response = await client.request<Response>(query);

    return CardanoGraphqlToOgmios.tip(response.cardano.tip);
  };

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

      const response = await client.request<Response, Variables>(mutation, {
        transaction: Buffer.from(signedTransaction.to_bytes()).toString('hex')
      });

      return !!response.hash;
    } catch {
      return false;
    }
  };

  // eslint-disable-next-line unicorn/consistent-function-scoping
  const utxoDelegationAndRewards: CardanoProvider['utxoDelegationAndRewards'] = async () => {
    throw new Error('Not implemented yet.');
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

    return CardanoGraphqlToOgmios.graphqlTransactionsToCardanoTxs(response.transactions);
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

    return CardanoGraphqlToOgmios.graphqlTransactionsToCardanoTxs(response.transactions);
  };

  const currentWalletProtocolParameters: CardanoProvider['currentWalletProtocolParameters'] = async () => {
    const query = gql`
      query {
        cardano {
          currentEpoch {
            protocolParams {
              coinsPerUtxoWord
              maxTxSize
              maxValSize
              keyDeposit
              maxCollateralInputs
              minFeeA
              minFeeB
              minPoolCost
              poolDeposit
              protocolVersion
            }
          }
        }
      }
    `;

    type Response = {
      cardano: {
        currentEpoch: {
          protocolParams: GraphqlCurrentWalletProtocolParameters;
        };
      };
    };

    const response = await client.request<Response>(query);

    return CardanoGraphqlToOgmios.currentWalletProtocolParameters(response.cardano.currentEpoch.protocolParams);
  };

  return {
    ledgerTip,
    submitTx,
    utxoDelegationAndRewards,
    queryTransactionsByAddresses,
    queryTransactionsByHashes,
    currentWalletProtocolParameters
  };
};
