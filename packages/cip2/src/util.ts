// TODO: move these utils to either core package.
// Current impelmentation of OgmiosToCardanoWasm.value() uses number instead of bigint for lovelace.
// These utils should be moved after CSL is updated to use bigint.
import { CardanoSerializationLib, CSL } from '@cardano-sdk/cardano-serialization-lib';
import { Asset, Ogmios } from '@cardano-sdk/core';

export type AssetQuantities = Ogmios.util.AssetQuantities;
export type ValueQuantities = Ogmios.util.ValueQuantities;

export const transactionOutputsToArray = (outputs: CSL.TransactionOutputs): CSL.TransactionOutput[] => {
  const result: CSL.TransactionOutput[] = [];
  for (let outputIdx = 0; outputIdx < outputs.len(); outputIdx++) {
    const output = outputs.get(outputIdx);
    result.push(output);
  }
  return result;
};

export const valueToValueQuantities = (value: CSL.Value): ValueQuantities => {
  const result: ValueQuantities = {
    coins: BigInt(value.coin().to_str())
  };
  const multiasset = value.multiasset();
  if (!multiasset) {
    return result;
  }
  result.assets = {};
  const scriptHashes = multiasset.keys();
  for (let scriptHashIdx = 0; scriptHashIdx < scriptHashes.len(); scriptHashIdx++) {
    const scriptHash = scriptHashes.get(scriptHashIdx);
    const assets = multiasset.get(scriptHash);
    const assetKeys = assets.keys();
    for (let assetIdx = 0; assetIdx < assetKeys.len(); assetIdx++) {
      const assetName = assetKeys.get(assetIdx);
      const assetAmount = BigInt(assets.get(assetName).to_str());
      if (assetAmount > 0n) {
        result.assets[Asset.util.createAssetId(scriptHash, assetName)] = assetAmount;
      }
    }
  }
  return result;
};

// This is equivalent to OgmiosToCardanoWasm.value(), so they should be merged.
// Note that current implementation of OgmiosToCardanoWasm
// imports nodejs version of CSL, so it cannot be used in browser.
export const valueQuantitiesToValue = ({ coins, assets }: ValueQuantities, csl: CardanoSerializationLib): CSL.Value => {
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
};
