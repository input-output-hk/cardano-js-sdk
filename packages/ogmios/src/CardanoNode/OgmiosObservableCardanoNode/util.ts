import { Cardano } from '@cardano-sdk/core';
import type { PointOrOrigin } from '@cardano-sdk/core';
import type { Schema } from '@cardano-ogmios/client';

export const pointOrOriginToOgmios = (point: PointOrOrigin) =>
  point === 'origin'
    ? 'origin'
    : {
        hash: point.hash,
        slot: point.slot
      };

export const ogmiosToCorePoint = (point: Schema.Point) => ({
  hash: Cardano.BlockId(point.hash),
  slot: Cardano.Slot(point.slot)
});

export const ogmiosToCoreTip = (tip: Schema.Tip) => ({
  ...ogmiosToCorePoint(tip),
  blockNo: Cardano.BlockNo(tip.blockNo)
});

export const ogmiosToCoreTipOrOrigin = (tip: Schema.TipOrOrigin) => (tip === 'origin' ? tip : ogmiosToCoreTip(tip));

export const ogmiosToCorePointOrOrigin = (point: Schema.PointOrOrigin) =>
  point === 'origin' ? point : ogmiosToCorePoint(point);
