import {
  Address,
  Assets,
  BigNum,
  MultiAsset,
  TransactionHash,
  TransactionInput,
  TransactionOutput,
  TransactionUnspentOutput,
  Value
} from '@emurgo/cardano-serialization-lib-nodejs';
import OgmiosSchema from '@cardano-ogmios/schema';
import * as Ogmios from '../Ogmios';
import * as Asset from '../Asset';

// TODO: Keep only OgmiosSchema.Value when ogmios updates lovelace type to bigint
export const value = ({ coins, assets }: Ogmios.Value | OgmiosSchema.Value): Value => {
  const result = Value.new(BigNum.from_str(coins.toString()));
  if (!assets) {
    return result;
  }
  const assetIds = Object.keys(assets);
  if (assetIds.length > 0) {
    const multiasset = MultiAsset.new();
    for (const assetId of assetIds) {
      const { scriptHash, assetName } = Asset.util.parseAssetId(assetId);
      const assetsObj = Assets.new();
      const amount = BigNum.from_str(assets[assetId].toString());
      assetsObj.insert(assetName, amount);
      multiasset.insert(scriptHash, assetsObj);
    }
    result.set_multiasset(multiasset);
  }
  return result;
};

export const txIn = (ogmios: OgmiosSchema.TxIn): TransactionInput =>
  TransactionInput.new(TransactionHash.from_bytes(Buffer.from(ogmios.txId, 'hex')), ogmios.index);

export const txOut = (ogmios: OgmiosSchema.TxOut): TransactionOutput =>
  TransactionOutput.new(Address.from_bech32(ogmios.address), value(ogmios.value));

export const utxo = (ogmios: OgmiosSchema.Utxo): TransactionUnspentOutput[] =>
  ogmios.map((item) => TransactionUnspentOutput.new(txIn(item[0]), txOut(item[1])));
