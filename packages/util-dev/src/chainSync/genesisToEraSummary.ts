import { Seconds } from '@cardano-sdk/core';
import type { Cardano, EraSummary } from '@cardano-sdk/core';

export const genesisToEraSummary = ({ systemStart, epochLength, slotLength }: Cardano.CompactGenesis): EraSummary => ({
  parameters: {
    epochLength,
    slotLength: Seconds.toMilliseconds(slotLength)
  },
  start: {
    slot: 0,
    time: systemStart
  }
});
