import { Responses } from '@blockfrost/blockfrost-js';
import * as OgmiosSchema from '@cardano-ogmios/schema';
import { Tx } from '@cardano-sdk/core';

type Unpacked<T> = T extends (infer U)[] ? U : T;
type BlockfrostAddressUtxoContent = Responses['address_utxo_content'];
type BlockfrostInputs = Responses['tx_content_utxo']['inputs'];
type BlockfrostInput = Unpacked<BlockfrostInputs>;
type BlockfrostOutputs = Responses['tx_content_utxo']['outputs'];
type BlockfrostOutput = Unpacked<BlockfrostOutputs>;
type BlockfrostUtxo = Unpacked<BlockfrostAddressUtxoContent>;

export const BlockfrostToOgmios = {
  addressUtxoContent: (address: string, blockfrost: Responses['address_utxo_content']): OgmiosSchema.Utxo =>
    blockfrost.map((utxo) => [
      BlockfrostToOgmios.txIn(BlockfrostToOgmios.inputFromUtxo(address, utxo)),
      BlockfrostToOgmios.txOut(BlockfrostToOgmios.outputFromUtxo(address, utxo))
    ]) as OgmiosSchema.Utxo,
  // without `as Cardano.Utxo` above TS thinks the return value is (Cardano.TxIn | Cardano.TxOut)[][]
  inputFromUtxo: (address: string, utxo: BlockfrostUtxo): BlockfrostInput => ({
    address,
    amount: utxo.amount,
    output_index: utxo.output_index,
    tx_hash: utxo.tx_hash
  }),
  inputs: (inputs: BlockfrostInputs): OgmiosSchema.TxIn[] => inputs.map((input) => BlockfrostToOgmios.txIn(input)),
  outputFromUtxo: (address: string, utxo: BlockfrostUtxo): BlockfrostOutput => ({
    address,
    amount: utxo.amount
  }),
  outputs: (outputs: BlockfrostOutputs): OgmiosSchema.TxOut[] =>
    outputs.map((output) => BlockfrostToOgmios.txOut(output)),
  txContentUtxo: (blockfrost: Responses['tx_content_utxo']): Tx => ({
    hash: blockfrost.hash,
    inputs: BlockfrostToOgmios.inputs(blockfrost.inputs),
    outputs: BlockfrostToOgmios.outputs(blockfrost.outputs)
  }),
  txIn: (blockfrost: BlockfrostInput): OgmiosSchema.TxIn => ({
    txId: blockfrost.tx_hash,
    index: blockfrost.output_index
  }),
  txOut: (blockfrost: BlockfrostOutput): OgmiosSchema.TxOut => {
    const assets: OgmiosSchema.Value['assets'] = {};
    for (const amount of blockfrost.amount) {
      if (amount.unit === 'lovelace') continue;
      assets[amount.unit] = BigInt(amount.quantity);
    }
    return {
      address: blockfrost.address,
      value: {
        coins: Number(blockfrost.amount.find(({ unit }) => unit === 'lovelace').quantity),
        assets
      }
    };
  }
};
