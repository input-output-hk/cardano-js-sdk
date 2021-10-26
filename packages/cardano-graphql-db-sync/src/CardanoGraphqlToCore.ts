import { ProtocolParametersRequiredByWallet, Cardano, Transaction } from '@cardano-sdk/core';
import { Block } from '@cardano-graphql/client-ts';

type GraphqlTransaction = {
  hash: Cardano.Hash16;
  inputs: { txHash: Cardano.Hash16; sourceTxIndex: number; address: Cardano.Address }[];
  outputs: {
    address: Cardano.Address;
    value: string;
    tokens: { asset: { assetId: string }; quantity: string }[];
  }[];
};

export type GraphqlCurrentWalletProtocolParameters = {
  coinsPerUtxoWord: number;
  maxValSize: string;
  keyDeposit: number;
  maxCollateralInputs: number;
  maxTxSize: number;
  minFeeA: number;
  minFeeB: number;
  minPoolCost: number;
  poolDeposit: number;
  protocolVersion: {
    major: number;
    minor: number;
  };
};

export type CardanoGraphQlTip = Pick<Block, 'hash' | 'number' | 'slotNo'>;

export type CardanoGraphqlTxIn = { txHash: Cardano.Hash16; sourceTxIndex: number; address: Cardano.Address };
export type TransactionsResponse = {
  transactions: {
    hash: Cardano.Hash16;
    inputs: CardanoGraphqlTxIn[];
    outputs: {
      address: Cardano.Address;
      value: string;
      tokens: { asset: { assetId: string }; quantity: string }[];
    }[];
  }[];
};

const txIn = ({ sourceTxIndex, txHash, address }: GraphqlTransaction['inputs'][0]): Cardano.TxIn => ({
  txId: txHash,
  index: sourceTxIndex,
  address
});

const txOut = ({ address, tokens, value }: GraphqlTransaction['outputs'][0]) => {
  const assets: Cardano.Value['assets'] = {};
  for (const token of tokens) assets[token.asset.assetId] = BigInt(token.quantity);
  return { address, value: { coins: BigInt(value), assets } };
};

export const CardanoGraphqlToCore = {
  txIn,
  txOut,

  graphqlTransactionsToCardanoTxs: (transactions: GraphqlTransaction[]): Transaction.Tx[] =>
    transactions.map((tx) => ({
      inputs: tx.inputs.map(txIn),
      outputs: tx.outputs.map(txOut),
      hash: tx.hash
    })),

  currentWalletProtocolParameters: (
    params: GraphqlCurrentWalletProtocolParameters
  ): ProtocolParametersRequiredByWallet => ({
    ...params,
    maxValueSize: Number(params.maxValSize),
    stakeKeyDeposit: params.keyDeposit,
    maxTxSize: params.maxTxSize,
    minFeeCoefficient: params.minFeeA,
    minFeeConstant: params.minFeeB
  }),

  tip: (tip: CardanoGraphQlTip): Cardano.Tip => ({
    blockNo: tip.number!,
    hash: tip.hash,
    slot: tip.slotNo!
  }),

  transactions: (response: TransactionsResponse) =>
    response.transactions.map(({ hash, inputs, outputs }) => ({
      hash,
      inputs: inputs.map(txIn),
      outputs: outputs.map(txOut)
    }))
};
