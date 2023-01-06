import { Cardano, EraSummary } from '@cardano-sdk/core';

export const genesisToEraSummary = ({ systemStart, epochLength, slotLength }: Cardano.CompactGenesis): EraSummary => ({
  parameters: {
    epochLength,
    slotLength
  },
  start: {
    slot: 0,
    time: systemStart
  }
});
