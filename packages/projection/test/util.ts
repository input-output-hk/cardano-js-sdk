import { Cardano, Milliseconds } from '@cardano-sdk/core';

export const stubBlockId = (slot: number) =>
  Cardano.BlockId(
    Buffer.from(new Uint8Array([slot]))
      .toString('hex')
      .padStart(64, '0')
  );

export const stubEraSummaries = [
  {
    parameters: { epochLength: 432_000, slotLength: Milliseconds(1000) },
    start: { slot: 0, time: new Date(1_595_967_616_000) }
  }
];
