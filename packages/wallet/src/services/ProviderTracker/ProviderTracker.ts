import type { BehaviorSubject } from 'rxjs';

export interface ProviderFnStats {
  numCalls: number;
  numResponses: number;
  numFailures: number;
  /**
   * Either:
   * - at least 1 response received
   * - was set manually (via setStatInitialized) to indicate that it won't make a request on wallet initialization
   */
  initialized?: boolean;
  didLastRequestFail?: boolean;
}

export const CLEAN_FN_STATS: ProviderFnStats = { numCalls: 0, numFailures: 0, numResponses: 0 };

/** Wraps a Provider, tracking # of calls of each function */
export abstract class ProviderTracker {
  protected async trackedCall<T>(call: () => Promise<T>, tracker: BehaviorSubject<ProviderFnStats>) {
    tracker.next({ ...tracker.value, numCalls: tracker.value.numCalls + 1 });
    try {
      const result = await call();
      const numResponses = tracker.value.numResponses + 1;
      tracker.next({
        ...tracker.value,
        didLastRequestFail: false,
        initialized: true,
        numResponses
      });
      return result;
    } catch (error) {
      tracker.next({
        ...tracker.value,
        didLastRequestFail: true,
        numFailures: tracker.value.numFailures + 1
      });
      throw error;
    }
  }

  setStatInitialized(tracker: BehaviorSubject<ProviderFnStats>) {
    tracker.next({
      ...tracker.value,
      initialized: true
    });
  }
}
