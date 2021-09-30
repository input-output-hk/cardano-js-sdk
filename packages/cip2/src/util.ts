// TODO: move these utils to either core package.
// Current implementation of ogmiosToCsl.value() uses number instead of bigint for lovelace.
// These utils should be moved after CSL is updated to use bigint.
import { CardanoSerializationLib, CSL, Asset, Ogmios } from '@cardano-sdk/core';

export type TokenMap = Ogmios.util.TokenMap;
export type OgmiosValue = Ogmios.util.OgmiosValue;

export const MAX_U64 = 18_446_744_073_709_551_615n;
export const maxBigNum = (csl: CardanoSerializationLib) => csl.BigNum.from_str(MAX_U64.toString());

export const valueToValueQuantities = (value: CSL.Value): OgmiosValue => {
  const result: OgmiosValue = {
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

// This is equivalent to ogmiosToCsl.value(), so they should be merged.
export const ogmiosValueToCslValue = ({ coins, assets }: OgmiosValue, csl: CardanoSerializationLib): CSL.Value => {
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
