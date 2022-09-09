export type ModuleState = null | 'initializing' | 'initialized';

export interface Runnable {
  start?(): Promise<void>;
  shutdown?(): Promise<void>;
}
