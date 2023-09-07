import { Asset, Cardano, Handle } from '@cardano-sdk/core';
import { InvalidStringError } from '@cardano-sdk/util';

/**
 * Up to 100k transactions per block.
 * Fits in 64-bit signed integer.
 */
export const computeCompactTxId = (blockHeight: number, txIndex: number) => blockHeight * 100_000 + txIndex;

export const assetNameToUTF8Handle = (assetName: Cardano.AssetName): Handle => {
  const handle = Cardano.AssetName.toUTF8(assetName);
  if (!Asset.util.isValidHandle(handle)) throw new InvalidStringError(`Invalid handle ${handle}`);
  return handle;
};
