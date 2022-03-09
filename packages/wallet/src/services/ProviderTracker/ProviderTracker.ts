import { BehaviorSubject } from 'rxjs';

export const CLEAN_FN_STATS = { numCalls: 0, numResponses: 0 };

export interface ProviderFnStats {
  numCalls: number;
  numResponses: number;
}

/**
 * Wraps a Provider, tracking # of calls of each function
 */
export abstract class ProviderTracker {
  protected trackedCall<T>(call: () => Promise<T>, tracker: BehaviorSubject<ProviderFnStats>) {
    tracker.next({ ...tracker.value, numCalls: tracker.value.numCalls + 1 });
    return call().then((result: T) => {
      tracker.next({
        ...tracker.value,
        numResponses: tracker.value.numResponses + 1
      });
      return result;
    });
  }
}
