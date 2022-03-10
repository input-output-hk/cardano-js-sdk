import { Cardano, ProviderError, ProviderFailure, WalletProvider } from '@cardano-sdk/core';
import {
  CardanoGraphQlTip,
  CardanoGraphqlToCore,
  GraphqlCurrentWalletProtocolParameters,
  TransactionsResponse
} from './CardanoGraphqlToCore';
import { GraphQLClient, gql } from 'graphql-request';

/**
 * Connect to a [cardano-graphql (cardano-db-sync) service](https://github.com/input-output-hk/cardano-graphql)
 * ```typescript
 * const provider = cardanoGraphqlDbSyncProvider(uri: 'http://localhost:3100');
 * ```
 */

export const cardanoGraphqlDbSyncProvider = (uri: string): WalletProvider => {
  const client = new GraphQLClient(uri);

  const ledgerTip: WalletProvider['ledgerTip'] = async () => {
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

    return CardanoGraphqlToCore.tip(response.cardano.tip);
  };

  const networkInfo: WalletProvider['networkInfo'] = async () => {
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

  const stakePoolStats: WalletProvider['stakePoolStats'] = async () => {
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

  // eslint-disable-next-line unicorn/consistent-function-scoping
  const utxoDelegationAndRewards: WalletProvider['utxoDelegationAndRewards'] = async () => {
    throw new ProviderError(ProviderFailure.NotImplemented);
  };

  // eslint-disable-next-line unicorn/consistent-function-scoping
  const rewardsHistory: WalletProvider['rewardsHistory'] = async () => {
    throw new ProviderError(ProviderFailure.NotImplemented);
  };

  // eslint-disable-next-line unicorn/consistent-function-scoping
  const genesisParameters: WalletProvider['genesisParameters'] = async () => {
    throw new ProviderError(ProviderFailure.NotImplemented);
  };

  // eslint-disable-next-line unicorn/consistent-function-scoping
  const queryBlocksByHashes: WalletProvider['queryBlocksByHashes'] = async () => {
    throw new ProviderError(ProviderFailure.NotImplemented);
  };

  const queryTransactionsByAddresses: WalletProvider['queryTransactionsByAddresses'] = async (addresses) => {
    const query = gql`
      query ($addresses: [String]!) {
        transactions(
          where: { _or: [{ inputs: { address: { _in: $addresses } } }, { outputs: { address: { _in: $addresses } } }] }
        ) {
          hash
          inputs {
            address
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

    type Variables = { addresses: Cardano.Address[] };

    const response = await client.request<TransactionsResponse, Variables>(query, { addresses });

    return CardanoGraphqlToCore.graphqlTransactionsToCardanoTxs(response);
  };

  const queryTransactionsByHashes: WalletProvider['queryTransactionsByHashes'] = async (hashes) => {
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

    type Variables = { hashes: Cardano.TransactionId[] };

    const response = await client.request<TransactionsResponse, Variables>(query, { hashes });

    return CardanoGraphqlToCore.graphqlTransactionsToCardanoTxs(response);
  };

  const currentWalletProtocolParameters: WalletProvider['currentWalletProtocolParameters'] = async () => {
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

    return CardanoGraphqlToCore.currentWalletProtocolParameters(response.cardano.currentEpoch.protocolParams);
  };

  return {
    currentWalletProtocolParameters,
    genesisParameters,
    ledgerTip,
    networkInfo,
    queryBlocksByHashes,
    queryTransactionsByAddresses,
    queryTransactionsByHashes,
    rewardsHistory,
    stakePoolStats,
    utxoDelegationAndRewards
  };
};
