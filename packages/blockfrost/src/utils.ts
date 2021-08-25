import { Schema as Cardano } from '@cardano-ogmios/client';
import { Tx } from '@cardano-sdk/core';

// Blockfrost types copied from https://github.com/blockfrost/blockfrost-js/blob/master/src/types/OpenApi.ts
// would be better if they were exported by the package

type BlockfrostInput = {
  /** Input address */
  address: string;
  amount: {
    /** The unit of the value */
    unit: string;
    /** The quantity of the unit */
    quantity: string;
  }[];
  /** Hash of the UTXO transaction */
  tx_hash: string;
  /** UTXO index in the transaction */
  output_index: number;
};

const blockfrostToCardanoInputs = (inputs: BlockfrostInput[]): Cardano.TxIn[] =>
  inputs.map<Cardano.TxIn>((input) => ({ txId: input.tx_hash, index: input.output_index /* .output_index ? */ }));

type BlockfrostOutput = {
  /** Output address */
  address: string;
  amount: {
    /** The unit of the value */
    unit: string;
    /** The quantity of the unit */
    quantity: string;
  }[];
};

export const blockfrostOutputToCardanoTxOut = (output: BlockfrostOutput): Cardano.TxOut => {
  const coins: Cardano.Value['coins'] = Number(output.amount.find(({ unit }) => unit === 'lovelace').quantity);
  const assets: Cardano.Value['assets'] = {};

  for (const amount of output.amount) {
    if (amount.unit === 'lovelace') continue;
    assets[amount.unit] = BigInt(amount.quantity);
  }
  const value: Cardano.Value = { coins, assets };

  return { address: output.address, value };
};

const blockfrostToCardanoOutputs = (outputs: BlockfrostOutput[]): Cardano.TxOut[] =>
  outputs.map<Cardano.TxOut>((output) => blockfrostOutputToCardanoTxOut(output));

type tx_content_utxo = {
  /** Transaction hash */
  hash: string;
  inputs: {
    /** Input address */
    address: string;
    amount: {
      /** The unit of the value */
      unit: string;
      /** The quantity of the unit */
      quantity: string;
    }[];
    /** Hash of the UTXO transaction */
    tx_hash: string;
    /** UTXO index in the transaction */
    output_index: number;
  }[];
  outputs: {
    /** Output address */
    address: string;
    amount: {
      /** The unit of the value */
      unit: string;
      /** The quantity of the unit */
      quantity: string;
    }[];
  }[];
};

export const blockfrostTxContentUtxoToCardanoTx = (tx: tx_content_utxo): Tx => ({
  hash: tx.hash,
  inputs: blockfrostToCardanoInputs(tx.inputs),
  outputs: blockfrostToCardanoOutputs(tx.outputs)
});
