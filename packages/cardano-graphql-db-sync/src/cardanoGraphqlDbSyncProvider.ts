import { CardanoProvider } from '@cardano-sdk/core';
import { gql, GraphQLClient } from 'graphql-request';
import { TransactionSubmitResponse } from '@cardano-graphql/client-ts';
import { Schema as Cardano } from '@cardano-ogmios/client';
import { Buffer } from 'buffer';
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

  const networkInfo: CardanoProvider['networkInfo'] = async () => {
    const query = gql`
      query {
        activeStake_aggregate {
          aggregate {
            sum {
              amount
            }
          }
        }
        ada {
          supply {
            circulating
            max
            total
          }
        }
        cardano {
          currentEpoch {
            lastBlockTime
            number
            startedAt
          }
        }
      }
    `;

    type Response = {
      activeStake_aggregate: {
        aggregate: {
          sum: {
            amount: string;
          };
        };
      };
      ada: {
        supply: {
          circulating: string;
          max: string;
          total: string;
        };
      };
      cardano: {
        currentEpoch: {
          lastBlockTime: string;
          number: number;
          startedAt: string;
        };
      };
    };

    const response = await client.request<Response>(query);
    return {
      currentEpoch: {
        end: {
          date: new Date(response.cardano.currentEpoch.lastBlockTime)
        },
        number: response.cardano.currentEpoch.number,
        start: {
          date: new Date(response.cardano.currentEpoch.startedAt)
        }
      },
      lovelaceSupply: {
        circulating: BigInt(response.ada.supply.circulating),
        max: BigInt(response.ada.supply.max),
        total: BigInt(response.ada.supply.total)
      },
      stake: {
        active: BigInt(response.activeStake_aggregate.aggregate.sum.amount),
        // Todo: This value cannot be provided by this service yet
        live: BigInt(0)
      }
    };
  };

  const stakePoolStats: CardanoProvider['stakePoolStats'] = async () => {
    const currentEpochResponse = await client.request<{
      cardano: {
        currentEpoch: {
          number: number;
        };
      };
    }>(gql`
      query {
        cardano {
          currentEpoch {
            number
          }
        }
      }
    `);

    const currentEpochNo = currentEpochResponse.cardano.currentEpoch.number;

    // It's not possible to alias the fields, so multiple requests are needed:
    // See https://github.com/input-output-hk/cardano-graphql/issues/164

    type Response = {
      stakePool_aggregate: {
        aggregate: {
          count: string;
        };
      };
    };

    const activeResponse = await client.request<Response>(
      gql`
        query ActiveStakePoolsCount {
          active: stakePools_aggregate(where: { _not: { retirements: { announcedIn: {} } } }) {
            aggregate {
              count
            }
          }
        }
      `
    );

    const retiredResponse = await client.request<Response>(
      gql`
        query RetiredStakePoolsCount($currentEpochNo: Int) {
          stakePools_aggregate(where: { retirements: { _and: { inEffectFrom: { _lte: $currentEpochNo } } } }) {
            aggregate {
              count
            }
          }
        }
      `,
      {
        currentEpochNo
      }
    );

    const retiringResponse = await client.request<Response>(
      gql`
        query RetiringStakePoolsCount($currentEpochNo: Int) {
          stakePools_aggregate(
            where: {
              retirements: {
                _and: {
                  announcedIn: { block: { epoch: { number: { _lte: $currentEpochNo } } } }
                  inEffectFrom: { _gt: $currentEpochNo }
                }
              }
            }
          ) {
            aggregate {
              count
            }
          }
        }
      `,
      {
        currentEpochNo
      }
    );
    return {
      qty: {
        active: Number(activeResponse.stakePool_aggregate.aggregate.count),
        retired: Number(retiredResponse.stakePool_aggregate.aggregate.count),
        retiring: Number(retiringResponse.stakePool_aggregate.aggregate.count)
      }
    };
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
    networkInfo,
    stakePoolStats,
    submitTx,
    utxoDelegationAndRewards,
    queryTransactionsByAddresses,
    queryTransactionsByHashes,
    currentWalletProtocolParameters
  };
};
