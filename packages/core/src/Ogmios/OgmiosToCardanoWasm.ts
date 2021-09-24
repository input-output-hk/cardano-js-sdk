import { CSL } from '@cardano-sdk/cardano-serialization-lib';
import OgmiosSchema from '@cardano-ogmios/schema';
import * as Asset from '../Asset';

export const OgmiosToCardanoWasm = {
  txIn: (ogmios: OgmiosSchema.TxIn): CSL.TransactionInput =>
    CSL.TransactionInput.new(CSL.TransactionHash.from_bytes(Buffer.from(ogmios.txId, 'hex')), ogmios.index),
  txOut: (ogmios: OgmiosSchema.TxOut): CSL.TransactionOutput =>
    CSL.TransactionOutput.new(CSL.Address.from_bech32(ogmios.address), OgmiosToCardanoWasm.value(ogmios.value)),
  utxo: (ogmios: OgmiosSchema.Utxo): CSL.TransactionUnspentOutput[] =>
    ogmios.map((item) =>
      CSL.TransactionUnspentOutput.new(OgmiosToCardanoWasm.txIn(item[0]), OgmiosToCardanoWasm.txOut(item[1]))
    ),
  value: (ogmios: OgmiosSchema.Value): CSL.Value => {
    const value = CSL.Value.new(CSL.BigNum.from_str(ogmios.coins.toString()));
    const assets = ogmios.assets !== undefined ? Object.entries(ogmios.assets) : [];
    if (assets.length === 0) {
      return value;
    }
    const multiAsset = CSL.MultiAsset.new();
    const policies = [...new Set(assets.map(([assetId]) => Asset.util.policyIdFromAssetId(assetId)))];
    for (const policy of policies) {
      const policyAssets = assets.filter(([assetId]) => Asset.util.policyIdFromAssetId(assetId) === policy);
      const wasmAssets = CSL.Assets.new();
      for (const [assetId, assetQuantity] of policyAssets) {
        wasmAssets.insert(
          CSL.AssetName.new(Buffer.from(Asset.util.assetNameFromAssetId(assetId), 'hex')),
          CSL.BigNum.from_str(assetQuantity.toString())
        );
      }
      multiAsset.insert(CSL.ScriptHash.from_bytes(Buffer.from(policy, 'hex')), wasmAssets);
    }
    value.set_multiasset(multiAsset);
    return value;
  }
};
