import { NEVER, Observable, distinctUntilChanged, fromEvent, map, merge, shareReplay, startWith } from 'rxjs';
import { isBackgroundProcess } from '@cardano-sdk/util';

export enum ConnectionStatus {
  down = 0,
  up
}

export type ConnectionStatusTracker = Observable<ConnectionStatus>;

export interface ConnectionStatusTrackerInternals {
  isNodeEnv?: boolean;
  online$?: Observable<unknown>;
  offline$?: Observable<unknown>;
  initialStatus?: boolean;
}

/**
 * Returns an observable that emits the online status of the browser.
 * When running in Node, it always emits 'up'
 *
 * @returns {ConnectionStatusTracker} ConnectionStatusTracker
 */
export const createSimpleConnectionStatusTracker = ({
  isNodeEnv = isBackgroundProcess(),
  online$ = isNodeEnv ? NEVER : fromEvent(window, 'online'),
  offline$ = isNodeEnv ? NEVER : fromEvent(window, 'offline'),
  initialStatus = isNodeEnv ? true : navigator.onLine
}: ConnectionStatusTrackerInternals = {}): ConnectionStatusTracker =>
  merge(online$.pipe(map(() => true)), offline$.pipe(map(() => false))).pipe(
    startWith(initialStatus),
    map((onLine) => (onLine ? ConnectionStatus.up : ConnectionStatus.down)),
    distinctUntilChanged(),
    shareReplay(1)
  );
