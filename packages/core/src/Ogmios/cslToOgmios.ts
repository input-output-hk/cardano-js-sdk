import { TxIn } from '@cardano-ogmios/schema';
import { Asset } from '..';
import { CSL } from '../CSL';
import { OgmiosValue } from './util';

/**
 * OgmiosValue is currently incompatible with Ogmios.Value due to 'coins' type (bigint vs number).
 * TODO: Use Ogmios.Value when ogmios updates lovelace type to bigint
 */
export const value = (cslValue: CSL.Value): OgmiosValue => {
  const result: OgmiosValue = {
    coins: BigInt(cslValue.coin().to_str())
  };
  const multiasset = cslValue.multiasset();
  if (!multiasset) {
    return result;
  }
  result.assets = {};
  const scriptHashes = multiasset.keys();
  for (let scriptHashIdx = 0; scriptHashIdx < scriptHashes.len(); scriptHashIdx++) {
    const scriptHash = scriptHashes.get(scriptHashIdx);
    const assets = multiasset.get(scriptHash)!;
    const assetKeys = assets.keys();
    for (let assetIdx = 0; assetIdx < assetKeys.len(); assetIdx++) {
      const assetName = assetKeys.get(assetIdx);
      const assetAmount = BigInt(assets.get(assetName)!.to_str());
      if (assetAmount > 0n) {
        result.assets[Asset.util.createAssetId(scriptHash, assetName)] = assetAmount;
      }
    }
  }
  return result;
};

export const txIn = (input: CSL.TransactionInput): TxIn => ({
  txId: Buffer.from(input.transaction_id().to_bytes()).toString('hex'),
  index: input.index()
});
