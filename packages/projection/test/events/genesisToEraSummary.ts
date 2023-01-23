import { Cardano, EraSummary, Seconds } from '@cardano-sdk/core';

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
