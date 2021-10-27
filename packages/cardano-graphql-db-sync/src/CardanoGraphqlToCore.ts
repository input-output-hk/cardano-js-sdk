import { Block } from '@cardano-graphql/client-ts';
import { Cardano, NotImplementedError, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';

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
  address,
  index: sourceTxIndex,
  txId: txHash
});

const txOut = ({ address, tokens, value }: GraphqlTransaction['outputs'][0]) => {
  const assets: Cardano.Value['assets'] = {};
  for (const token of tokens) assets[token.asset.assetId] = BigInt(token.quantity);
  return { address, value: { assets, coins: BigInt(value) } };
};

export const CardanoGraphqlToCore = {
  currentWalletProtocolParameters: (
    params: GraphqlCurrentWalletProtocolParameters
  ): ProtocolParametersRequiredByWallet => ({
    ...params,
    maxTxSize: params.maxTxSize,
    maxValueSize: Number(params.maxValSize),
    minFeeCoefficient: params.minFeeA,
    minFeeConstant: params.minFeeB,
    stakeKeyDeposit: params.keyDeposit
  }),
  graphqlTransactionsToCardanoTxs: (_transactions: TransactionsResponse): Cardano.TxAlonzo[] => {
    // transactions.map((tx) => ({
    //   inputs: tx.inputs.map(txIn),
    //   outputs: tx.outputs.map(txOut),
    //   hash: tx.hash
    // })),
    throw new NotImplementedError('Need to query more data to support this');
  },

  tip: (tip: CardanoGraphQlTip): Cardano.Tip => ({
    blockNo: tip.number!,
    hash: tip.hash,
    slot: tip.slotNo!
  }),

  txIn,

  txOut
};
