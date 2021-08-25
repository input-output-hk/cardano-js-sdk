import { Schema as Cardano } from '@cardano-ogmios/client';
import { Tx } from '@cardano-sdk/core';

type GraphqlTransaction = {
  hash: Cardano.Hash16;
  inputs: { txHash: Cardano.Hash16; sourceTxIndex: number }[];
  outputs: {
    address: Cardano.Address;
    value: string;
    tokens: { asset: { assetId: string }; quantity: string }[];
  }[];
};
export const graphqlTransactionsToCardanoTxs = (transactions: GraphqlTransaction[]): Tx[] =>
  transactions.map((tx) => ({
    hash: tx.hash,
    inputs: tx.inputs.map((index) => ({ txId: index.txHash, index: index.sourceTxIndex })),
    outputs: tx.outputs.map((output) => {
      const assets: Cardano.Value['assets'] = {};

      for (const token of output.tokens) assets[token.asset.assetId] = BigInt(token.quantity);

      return { address: output.address, value: { coins: Number(output.value), assets } };
    })
  }));
