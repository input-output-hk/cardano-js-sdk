import { Asset, Cardano, Handle } from '@cardano-sdk/core';
import { Logger } from 'ts-log';

/** Up to 100k transactions per block. Fits in 64-bit signed integer. */
export const computeCompactTxId = (blockHeight: number, txIndex: number) => blockHeight * 100_000 + txIndex;

export const assetNameToUTF8Handle = (assetName: Cardano.AssetName, logger: Logger): Handle | null => {
  const handle = Cardano.AssetName.toUTF8(assetName);
  if (!Asset.util.isValidHandle(handle)) {
    logger.warn(`Invalid handle: '${handle}' / '${assetName}'`);
    return null;
  }
  return handle;
};
