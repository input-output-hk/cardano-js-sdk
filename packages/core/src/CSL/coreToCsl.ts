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
import * as Asset from '../Asset';
import * as Cardano from '../Cardano';

export const value = ({ coins, assets }: Cardano.Value): Value => {
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

export const txIn = (core: Cardano.TxIn): TransactionInput =>
  TransactionInput.new(TransactionHash.from_bytes(Buffer.from(core.txId, 'hex')), core.index);

export const txOut = (core: Cardano.TxOut): TransactionOutput =>
  TransactionOutput.new(Address.from_bech32(core.address), value(core.value));

export const utxo = (core: Cardano.Utxo[]): TransactionUnspentOutput[] =>
  core.map((item) => TransactionUnspentOutput.new(txIn(item[0]), txOut(item[1])));
