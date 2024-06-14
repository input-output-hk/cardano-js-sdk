import { EraSummary, Milliseconds, Seconds } from '@cardano-sdk/core';
import { Schema } from '@cardano-ogmios/client';

export const eraSummary = (ogmiosEraSummary: Schema.EraSummary, systemStart: Date): EraSummary => ({
  parameters: {
    epochLength: ogmiosEraSummary.parameters.epochLength,
    slotLength: Milliseconds(Number(ogmiosEraSummary.parameters.slotLength.milliseconds))
  },
  start: {
    slot: ogmiosEraSummary.start.slot,
    time: new Date(systemStart.getTime() + Seconds.toMilliseconds(Seconds(Number(ogmiosEraSummary.start.time.seconds))))
  }
});
