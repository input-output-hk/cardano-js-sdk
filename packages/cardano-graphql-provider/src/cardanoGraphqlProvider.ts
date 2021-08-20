import { CardanoProvider } from '@cardano-sdk/core';
import { gql, GraphQLClient } from 'graphql-request';
import { TransactionSubmitResponse } from '@cardano-graphql/client-ts';
import { Schema as Cardano } from '@cardano-ogmios/client';

export const cardanoGraphqlProvider = (uri: string): CardanoProvider => {
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
      value: Cardano.Lovelace;
      tokens: {
        asset: {
          assetId: string;
        };
        quantity: Cardano.AssetQuantity;
      }[];
    };
    type Response = { utxos: Utxo[] };
    type Variables = { addresses: string[] };

    const response = await client.request<Response, Variables>(query, { addresses });

    return response.utxos.map((uxto) => {
      const assets: Cardano.Value['assets'] = {};

      for (const t of uxto.tokens) assets[t.asset.assetId] = t.quantity;

      return [
        { txId: uxto.transaction.hash, index: uxto.index },
        { address: uxto.address, value: { coins: uxto.value, assets } }
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
          }
        }
      }
    `;

    type Response = {
      transactions: {
        hash: Cardano.Hash16;
        inputs: { txHash: Cardano.Hash16; sourceTxIndex: number }[];
        outputs: Cardano.TxOut[];
      }[];
    };
    type Variables = { addresses: string[] };

    const response = await client.request<Response, Variables>(query, { addresses });

    return response.transactions.map((t) => ({
      ...t,
      inputs: t.inputs.map((index) => ({ txId: index.txHash, index: index.sourceTxIndex }))
    }));
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
          }
        }
      }
    `;

    type Response = {
      transactions: {
        hash: Cardano.Hash16;
        inputs: { txHash: Cardano.Hash16; sourceTxIndex: number }[];
        outputs: Cardano.TxOut[];
      }[];
    };
    type Variables = { hashes: string[] };

    const response = await client.request<Response, Variables>(query, { hashes });

    return response.transactions.map((t) => ({
      ...t,
      inputs: t.inputs.map((index) => ({ txId: index.txHash, index: index.sourceTxIndex }))
    }));
  };

  return {
    submitTx,
    utxo,
    queryTransactionsByAddresses,
    queryTransactionsByHashes
  };
};
