import type { PointOrOrigin } from '@cardano-sdk/core';

export const pointDescription = (point: PointOrOrigin) =>
  point === 'origin' ? 'origin' : `slot ${point.slot}, block ${point.hash}`;
