import { Cardano } from '@cardano-sdk/core';
import { computeCompactTxId } from './util';
import { unifiedProjectorOperator } from '../utils';

export interface Mint {
  assetId: Cardano.AssetId;
  quantity: bigint;
  compactTxId: number;
}

export interface WithMint {
  mint: Mint[];
}

export const withMint = unifiedProjectorOperator<{}, WithMint>((evt) => ({
  ...evt,
  mint: evt.block.body.flatMap(({ body: { mint } }, txIndex) =>
    [...(mint?.entries() || [])].map(
      ([assetId, quantity]): Mint => ({
        assetId,
        compactTxId: computeCompactTxId(evt.block.header.blockNo, txIndex),
        quantity
      })
    )
  )
}));
