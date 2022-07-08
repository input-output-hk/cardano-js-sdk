import { EraSummary } from '@cardano-sdk/core';
import { Schema } from '@cardano-ogmios/client';

export const mapEraSummary = (eraSummary: Schema.EraSummary, systemStart: Date): EraSummary => ({
  parameters: {
    epochLength: eraSummary.parameters.epochLength,
    slotLength: eraSummary.parameters.slotLength
  },
  start: {
    slot: eraSummary.start.slot,
    time: new Date(systemStart.getTime() + eraSummary.start.time * 1000)
  }
});
