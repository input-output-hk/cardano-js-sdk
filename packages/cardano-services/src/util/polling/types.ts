export type Disposer = () => void;

export interface EpochMonitor {
  onEpochRollover(callback: () => void): Disposer;
}
