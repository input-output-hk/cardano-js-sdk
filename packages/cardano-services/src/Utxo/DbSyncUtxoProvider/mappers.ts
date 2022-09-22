import { Cardano, createUtxoId } from '@cardano-sdk/core';
import { UtxoModel } from './types';
import { generateAssetId } from './util';

/**
 * Transform DB results into indexed core UTxO
 *
 * @param {UtxoModel[]} utxosModels  UTxO query rows
 * @returns {Cardano.Utxo[]} an array of core UTxO objects
 */
export const utxosToCore = (utxosModels: UtxoModel[]): Cardano.Utxo[] => {
  const utxosMap = utxosModels.reduce((utxos, current) => {
    const utxoId = createUtxoId(current.tx_id, current.index);
    const utxo = utxos.get(utxoId);
    if (utxo) {
      const txIn = utxo[0];
      const txOut = utxo[1];
      if (current.asset_name && current.asset_policy && current.asset_quantity) {
        const newAssets = txOut.value.assets || new Map<Cardano.AssetId, bigint>();
        newAssets.set(generateAssetId(current.asset_policy, current.asset_name), BigInt(current.asset_quantity));
        txOut.value.assets = newAssets;
      }
      utxos.set(utxoId, [txIn, txOut]);
    } else {
      const address = Cardano.Address(current.address);
      const txOut: Cardano.TxOut = {
        address,
        value: {
          coins: BigInt(current.coins)
        }
      };
      if (current.data_hash) txOut.datum = Cardano.util.Hash32ByteBase16(current.data_hash);
      if (current.asset_name && current.asset_policy && current.asset_quantity) {
        txOut.value.assets = new Map<Cardano.AssetId, bigint>([
          [generateAssetId(current.asset_policy, current.asset_name), BigInt(current.asset_quantity)]
        ]);
      }
      utxos.set(utxoId, [
        {
          address,
          index: current.index,
          txId: Cardano.TransactionId(current.tx_id)
        },
        txOut
      ]);
    }
    return utxos;
  }, new Map<string, Cardano.Utxo>());
  return [...utxosMap.values()];
};
