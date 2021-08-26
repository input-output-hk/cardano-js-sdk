import { Schema as Cardano } from '@cardano-ogmios/client';
import { Responses } from '@blockfrost/blockfrost-js';
import { Tx } from '@cardano-sdk/core';

type Unpacked<T> = T extends (infer U)[] ? U : T;
type BlockfrostOutput = Unpacked<Responses['tx_content_utxo']['outputs']>;

const blockfrostToCardanoInputs = (inputs: Responses['tx_content_utxo']['inputs']): Cardano.TxIn[] =>
  inputs.map<Cardano.TxIn>((input) => ({ txId: input.tx_hash, index: input.output_index /* .output_index ? */ }));

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

export const blockfrostTxContentUtxoToCardanoTx = (tx: Responses['tx_content_utxo']): Tx => ({
  hash: tx.hash,
  inputs: blockfrostToCardanoInputs(tx.inputs),
  outputs: blockfrostToCardanoOutputs(tx.outputs)
});
