import { Responses } from '@blockfrost/blockfrost-js';
import { Cardano } from '@cardano-sdk/core';
import { BlockfrostToOgmios } from './BlockfrostToOgmios';

export const BlockfrostToCore = {
  addressUtxoContent: (address: string, blockfrost: Responses['address_utxo_content']): Cardano.Utxo[] =>
    blockfrost.map((utxo) => [
      { ...BlockfrostToOgmios.txIn(BlockfrostToOgmios.inputFromUtxo(address, utxo)), address },
      BlockfrostToOgmios.txOut(BlockfrostToOgmios.outputFromUtxo(address, utxo))
    ]),
  transaction: (tx: Responses['tx_content_utxo']) => ({
    inputs: tx.inputs.map((input) => ({
      ...BlockfrostToOgmios.txIn(input),
      address: input.address
    })),
    outputs: tx.outputs.map(BlockfrostToOgmios.txOut),
    hash: tx.hash
  })
};
