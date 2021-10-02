import { CardanoSerializationLib, CSL } from '../CSL';
import OgmiosSchema from '@cardano-ogmios/schema';
import { Buffer } from 'buffer';
import * as Asset from '../Asset';

export const ogmiosToCsl = (csl: CardanoSerializationLib) => ({
  txIn: (ogmios: OgmiosSchema.TxIn): CSL.TransactionInput =>
    csl.TransactionInput.new(csl.TransactionHash.from_bytes(Buffer.from(ogmios.txId, 'hex')), ogmios.index),
  txOut: (ogmios: OgmiosSchema.TxOut): CSL.TransactionOutput =>
    csl.TransactionOutput.new(csl.Address.from_bech32(ogmios.address), ogmiosToCsl(csl).value(ogmios.value)),
  utxo: (ogmios: OgmiosSchema.Utxo): CSL.TransactionUnspentOutput[] =>
    ogmios.map((item) =>
      csl.TransactionUnspentOutput.new(ogmiosToCsl(csl).txIn(item[0]), ogmiosToCsl(csl).txOut(item[1]))
    ),
  value: (ogmios: OgmiosSchema.Value): CSL.Value => {
    const value = csl.Value.new(csl.BigNum.from_str(ogmios.coins.toString()));
    const assets = ogmios.assets !== undefined ? Object.entries(ogmios.assets) : [];
    if (assets.length === 0) {
      return value;
    }
    const multiAsset = csl.MultiAsset.new();
    const policies = [...new Set(assets.map(([assetId]) => Asset.util.policyIdFromAssetId(assetId)))];
    for (const policy of policies) {
      const policyAssets = assets.filter(([assetId]) => Asset.util.policyIdFromAssetId(assetId) === policy);
      const wasmAssets = csl.Assets.new();
      for (const [assetId, assetQuantity] of policyAssets) {
        wasmAssets.insert(
          csl.AssetName.new(Buffer.from(Asset.util.assetNameFromAssetId(assetId), 'hex')),
          csl.BigNum.from_str(assetQuantity.toString())
        );
      }
      multiAsset.insert(csl.ScriptHash.from_bytes(Buffer.from(policy, 'hex')), wasmAssets);
    }
    value.set_multiasset(multiAsset);
    return value;
  }
});
