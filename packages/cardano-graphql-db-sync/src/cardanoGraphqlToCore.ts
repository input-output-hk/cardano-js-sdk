import { Hash16 } from '@cardano-ogmios/schema';
import { Cardano } from '@cardano-sdk/core';
import { CardanoGraphqlToOgmios } from './CardanoGraphqlToOgmios';

export type CardanoGraphqlTxIn = { txHash: Hash16; sourceTxIndex: number; address: Cardano.Address };
export type TransactionsResponse = {
  transactions: {
    hash: Hash16;
    inputs: CardanoGraphqlTxIn[];
    outputs: {
      address: Cardano.Address;
      value: string;
      tokens: { asset: { assetId: string }; quantity: string }[];
    }[];
  }[];
};

export const CardanoGraphqlToCore = {
  transactions: (response: TransactionsResponse) =>
    response.transactions.map(({ hash, inputs, outputs }) => ({
      hash,
      inputs: inputs.map(CardanoGraphqlToCore.txIn),
      outputs: outputs.map(CardanoGraphqlToOgmios.txOut)
    })),
  txIn: (input: CardanoGraphqlTxIn) => ({
    ...CardanoGraphqlToOgmios.txIn(input),
    address: input.address
  })
};
