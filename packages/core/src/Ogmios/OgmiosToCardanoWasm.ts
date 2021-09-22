import CardanoWasm from '@emurgo/cardano-serialization-lib-nodejs';
import OgmiosSchema from '@cardano-ogmios/schema';
import * as Asset from '../Asset';

export const OgmiosToCardanoWasm = {
  txIn: (ogmios: OgmiosSchema.TxIn): CardanoWasm.TransactionInput =>
    CardanoWasm.TransactionInput.new(
      CardanoWasm.TransactionHash.from_bytes(Buffer.from(ogmios.txId, 'hex')),
      ogmios.index
    ),
  txOut: (ogmios: OgmiosSchema.TxOut): CardanoWasm.TransactionOutput =>
    CardanoWasm.TransactionOutput.new(
      CardanoWasm.Address.from_bech32(ogmios.address),
      OgmiosToCardanoWasm.value(ogmios.value)
    ),
  utxo: (ogmios: OgmiosSchema.Utxo): CardanoWasm.TransactionUnspentOutput[] =>
    ogmios.map((item) =>
      CardanoWasm.TransactionUnspentOutput.new(OgmiosToCardanoWasm.txIn(item[0]), OgmiosToCardanoWasm.txOut(item[1]))
    ),
  value: (ogmios: OgmiosSchema.Value): CardanoWasm.Value => {
    const value = CardanoWasm.Value.new(CardanoWasm.BigNum.from_str(ogmios.coins.toString()));
    const assets = ogmios.assets !== undefined ? Object.entries(ogmios.assets) : [];
    if (assets.length === 0) {
      return value;
    }
    const multiAsset = CardanoWasm.MultiAsset.new();
    const policies = [...new Set(assets.map(([assetId]) => Asset.util.policyIdFromAssetId(assetId)))];
    for (const policy of policies) {
      const policyAssets = assets.filter(([assetId]) => Asset.util.policyIdFromAssetId(assetId) === policy);
      const wasmAssets = CardanoWasm.Assets.new();
      for (const [assetId, assetQuantity] of policyAssets) {
        wasmAssets.insert(
          CardanoWasm.AssetName.new(Buffer.from(Asset.util.assetNameFromAssetId(assetId), 'hex')),
          CardanoWasm.BigNum.from_str(assetQuantity.toString())
        );
      }
      multiAsset.insert(CardanoWasm.ScriptHash.from_bytes(Buffer.from(policy, 'hex')), wasmAssets);
    }
    value.set_multiasset(multiAsset);
    return value;
  }
};
