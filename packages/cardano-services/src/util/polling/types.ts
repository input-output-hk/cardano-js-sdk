import type { Cardano } from '@cardano-sdk/core';

export type Disposer = () => void;

export interface EpochMonitor {
  onEpoch(currentEpoch: Cardano.EpochNo): void;
  onEpochRollover(callback: () => void): Disposer;
}
