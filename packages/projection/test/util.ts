import { Cardano } from '@cardano-sdk/core';

export const stubBlockId = (slot: number) =>
  Cardano.BlockId(
    Buffer.from(new Uint8Array([slot]))
      .toString('hex')
      .padStart(64, '0')
  );
