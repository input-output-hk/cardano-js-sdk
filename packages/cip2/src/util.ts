// TODO: move all of these utils to core package
import { CardanoSerializationLib } from '@cardano-sdk/cardano-serialization-lib';
import { Asset, BigIntMath } from '@cardano-sdk/core';
import {
  AssetName,
  ScriptHash,
  TransactionOutput,
  TransactionOutputs,
  Value
} from '@emurgo/cardano-serialization-lib-nodejs';
import { Value as OgmiosValue } from '@cardano-ogmios/schema';

/**
 * {[assetId]: amount}
 */
export type AssetQuantities = OgmiosValue['assets'];

/**
 * Total quantities of Coin and Assets in a Value.
 * TODO: Use Ogmios Value type after it changes lovelaces to bigint;
 */
export interface ValueQuantities {
  coins: bigint;
  assets?: AssetQuantities;
}

export const transactionOutputsToArray = (outputs: TransactionOutputs): TransactionOutput[] => {
  const result: TransactionOutput[] = [];
  for (let outputIdx = 0; outputIdx < outputs.len(); outputIdx++) {
    const output = outputs.get(outputIdx);
    result.push(output);
  }
  return result;
};

export const createAssetSerializer = (csl: CardanoSerializationLib) => {
  const bech32Prefix = 'b32_';
  const encoder = new TextEncoder();
  const decoder = new TextDecoder();
  return {
    /**
     * Combine script hash and asset name into unique asset identifier.
     * Operation can be reversed with *parse(assetId)*
     */
    createId: (scriptHash: ScriptHash, assetName: AssetName): string =>
      // TODO: I suggest to move this to @cardano-sdk/core so it's together with
      // policyIdFromAssetId and assetNameFromAssetId, because it's
      // relying on bech32 length and it can have different length prefix.
      scriptHash.to_bech32(bech32Prefix) + decoder.decode(assetName.name()),
    /**
     * Get asset scripthash bech32 and asset name
     * from id created by *create(scriptHashBech32, assetName)*.
     */
    parseId: (id: string) => {
      const scriptHashBech32 = Asset.util.policyIdFromAssetId(id);
      const assetName = Asset.util.assetNameFromAssetId(id);
      return {
        scriptHash: csl.ScriptHash.from_bech32(scriptHashBech32),
        assetName: csl.AssetName.new(encoder.encode(assetName))
      };
    }
  };
};

export type AssetSerializer = ReturnType<typeof createAssetSerializer>;

export const createCslUtils = (csl: CardanoSerializationLib, assetSerializer = createAssetSerializer(csl)) => {
  const valueToValueQuantities = (value: Value): ValueQuantities => {
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
          result.assets[assetSerializer.createId(scriptHash, assetName)] = assetAmount;
        }
      }
    }
    return result;
  };

  // Review: This is equivalent to OgmiosToCardanoWasm.value(), so they should be merged.
  // Note that current implementation of OgmiosToCardanoWasm
  // imports nodejs version of CSL, so it cannot be used in browser.
  // Also note that this function needs to know what bech32 prefix was used in order to recreate
  // policy ID and asset name from an asset ID
  const valueQuantitiesToValue = ({ coins, assets }: ValueQuantities): Value => {
    const value = csl.Value.new(csl.BigNum.from_str(coins.toString()));
    if (!assets) {
      return value;
    }
    const assetIds = Object.keys(assets);
    if (assetIds.length > 0) {
      const multiasset = csl.MultiAsset.new();
      for (const id of assetIds) {
        const { scriptHash, assetName } = assetSerializer.parseId(id);
        const assetsObj = csl.Assets.new();
        const amount = csl.BigNum.from_str(assets[id].toString());
        assetsObj.insert(assetName, amount);
        multiasset.insert(scriptHash, assetsObj);
      }
      value.set_multiasset(multiasset);
    }
    return value;
  };

  return { valueToValueQuantities, valueQuantitiesToValue };
};

export type CslUtils = ReturnType<typeof createCslUtils>;

/**
 * Sum asset quantities
 */
const coalesceAssetTotals = (...totals: (AssetQuantities | undefined)[]): AssetQuantities | undefined => {
  const result: AssetQuantities = {};
  for (const assetTotals of totals.filter((quantities) => !!quantities)) {
    for (const assetKey in assetTotals) {
      result[assetKey] = (result[assetKey] || 0n) + assetTotals[assetKey];
    }
  }
  if (Object.keys(result).length === 0) {
    return undefined;
  }
  // eslint-disable-next-line consistent-return
  return result;
};

/**
 * Sum all quantities
 */
export const coalesceValueQuantities = (...quantities: ValueQuantities[]): ValueQuantities => ({
  coins: BigIntMath.sum(quantities.map(({ coins }) => coins)),
  assets: coalesceAssetTotals(...quantities.map(({ assets }) => assets))
});

/**
 * Blockchain restriction for minimum coin quantity in a UTxO
 */
export const computeMinUtxoValue = (coinsPerUtxoWord: bigint): bigint => coinsPerUtxoWord * 29n;
