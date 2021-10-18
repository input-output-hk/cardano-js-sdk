import OgmiosSchema from '@cardano-ogmios/schema';
import { Buffer } from 'buffer';
import { CSL } from '../CSL';
import * as Asset from '../Asset';
import { Value } from './types';

// TODO: Keep only OgmiosSchema.Value when ogmios updates lovelace type to bigint
export const value = ({ coins, assets }: Value | OgmiosSchema.Value): CSL.Value => {
  const result = CSL.Value.new(CSL.BigNum.from_str(coins.toString()));
  if (!assets) {
    return result;
  }
  const assetIds = Object.keys(assets);
  if (assetIds.length > 0) {
    const multiasset = CSL.MultiAsset.new();
    for (const assetId of assetIds) {
      const { scriptHash, assetName } = Asset.util.parseAssetId(assetId);
      const assetsObj = CSL.Assets.new();
      const amount = CSL.BigNum.from_str(assets[assetId].toString());
      assetsObj.insert(assetName, amount);
      multiasset.insert(scriptHash, assetsObj);
    }
    result.set_multiasset(multiasset);
  }
  return result;
};

export const txIn = (ogmios: OgmiosSchema.TxIn): CSL.TransactionInput =>
  CSL.TransactionInput.new(CSL.TransactionHash.from_bytes(Buffer.from(ogmios.txId, 'hex')), ogmios.index);

export const txOut = (ogmios: OgmiosSchema.TxOut): CSL.TransactionOutput =>
  CSL.TransactionOutput.new(CSL.Address.from_bech32(ogmios.address), value(ogmios.value));

export const utxo = (ogmios: OgmiosSchema.Utxo): CSL.TransactionUnspentOutput[] =>
  ogmios.map((item) => CSL.TransactionUnspentOutput.new(txIn(item[0]), txOut(item[1])));
