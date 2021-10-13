import { CardanoSerializationLib, CSL } from '../CSL';
import OgmiosSchema from '@cardano-ogmios/schema';
import { Buffer } from 'buffer';
import * as Asset from '../Asset';
import { Value } from './types';

export const ogmiosToCsl = (csl: CardanoSerializationLib) => ({
  txIn: (ogmios: OgmiosSchema.TxIn): CSL.TransactionInput =>
    csl.TransactionInput.new(csl.TransactionHash.from_bytes(Buffer.from(ogmios.txId, 'hex')), ogmios.index),
  txOut: (ogmios: OgmiosSchema.TxOut): CSL.TransactionOutput =>
    csl.TransactionOutput.new(csl.Address.from_bech32(ogmios.address), ogmiosToCsl(csl).value(ogmios.value)),
  utxo: (ogmios: OgmiosSchema.Utxo): CSL.TransactionUnspentOutput[] =>
    ogmios.map((item) =>
      csl.TransactionUnspentOutput.new(ogmiosToCsl(csl).txIn(item[0]), ogmiosToCsl(csl).txOut(item[1]))
    ),
  // TODO: Keep only OgmiosSchema.Value when ogmios updates lovelace type to bigint
  value: ({ coins, assets }: Value | OgmiosSchema.Value): CSL.Value => {
    const value = csl.Value.new(csl.BigNum.from_str(coins.toString()));
    if (!assets) {
      return value;
    }
    const assetIds = Object.keys(assets);
    if (assetIds.length > 0) {
      const multiasset = csl.MultiAsset.new();
      for (const assetId of assetIds) {
        const { scriptHash, assetName } = Asset.util.parseAssetId(assetId, csl);
        const assetsObj = csl.Assets.new();
        const amount = csl.BigNum.from_str(assets[assetId].toString());
        assetsObj.insert(assetName, amount);
        multiasset.insert(scriptHash, assetsObj);
      }
      value.set_multiasset(multiasset);
    }
    return value;
  }
});

export type OgmiosToCsl = ReturnType<typeof ogmiosToCsl>;
