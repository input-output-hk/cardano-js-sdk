import { Milliseconds } from '@cardano-sdk/core';
import type { EraSummary } from '@cardano-sdk/core';

/** Valid at 2022-05-28 */

export const testnetEraSummaries: EraSummary[] = [
  {
    parameters: { epochLength: 21_600, slotLength: Milliseconds(20_000) },
    start: { slot: 0, time: new Date(1_563_999_616_000) }
  },
  {
    parameters: { epochLength: 432_000, slotLength: Milliseconds(1000) },
    start: { slot: 1_598_400, time: new Date(1_595_967_616_000) }
  }
];
