import { Cardano, PointOrOrigin } from '@cardano-sdk/core';
import { Schema } from '@cardano-ogmios/client';

export const pointOrOriginToOgmios = (point: PointOrOrigin) =>
  point === 'origin'
    ? 'origin'
    : {
        id: point.hash,
        slot: point.slot
      };

export const ogmiosToCorePoint = (point: Schema.Point) => ({
  hash: Cardano.BlockId(point.id),
  slot: Cardano.Slot(point.slot)
});

export const ogmiosToCoreTip = (tip: Schema.Tip) => ({
  ...ogmiosToCorePoint(tip),
  blockNo: Cardano.BlockNo(tip.height)
});

export const ogmiosToCoreTipOrOrigin = (tip: Schema.TipOrOrigin) => (tip === 'origin' ? tip : ogmiosToCoreTip(tip));

export const ogmiosToCorePointOrOrigin = (point: Schema.PointOrOrigin) =>
  point === 'origin' ? point : ogmiosToCorePoint(point);
