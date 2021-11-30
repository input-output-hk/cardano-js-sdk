import { Block } from '@cardano-graphql/client-ts';
import { Cardano, NotImplementedError, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';

type GraphqlTransaction = {
  hash: Cardano.TransactionId;
  inputs: { txHash: string; sourceTxIndex: number; address: string }[];
  outputs: {
    address: string;
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

export type CardanoGraphqlTxIn = { txHash: string; sourceTxIndex: number; address: string };
export type TransactionsResponse = {
  transactions: {
    hash: string;
    inputs: CardanoGraphqlTxIn[];
    outputs: {
      address: string;
      value: string;
      tokens: { asset: { assetId: string }; quantity: string }[];
    }[];
  }[];
};

const txIn = ({ sourceTxIndex, txHash, address }: GraphqlTransaction['inputs'][0]): Cardano.TxIn => ({
  address: Cardano.Address(address),
  index: sourceTxIndex,
  txId: Cardano.TransactionId(txHash)
});

const txOut = ({ address, tokens, value }: GraphqlTransaction['outputs'][0]) => {
  const assets: Cardano.TokenMap = new Map();
  for (const token of tokens) assets.set(Cardano.AssetId(token.asset.assetId), BigInt(token.quantity));
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
