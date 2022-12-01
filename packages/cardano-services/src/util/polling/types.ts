export type Disposer = () => void;

export interface EpochMonitor {
  onEpoch(currentEpoch: number): void;
  onEpochRollover(callback: () => void): Disposer;
}
