import { Seconds } from '@cardano-sdk/core';
import type { EraSummary } from '@cardano-sdk/core';
import type { Schema } from '@cardano-ogmios/client';

export const eraSummary = (ogmiosEraSummary: Schema.EraSummary, systemStart: Date): EraSummary => ({
  parameters: {
    epochLength: ogmiosEraSummary.parameters.epochLength,
    slotLength: Seconds.toMilliseconds(Seconds(ogmiosEraSummary.parameters.slotLength))
  },
  start: {
    slot: ogmiosEraSummary.start.slot,
    time: new Date(systemStart.getTime() + ogmiosEraSummary.start.time * 1000)
  }
});
