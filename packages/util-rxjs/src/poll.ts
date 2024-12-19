import { Logger } from 'ts-log';
import {
  NEVER,
  Observable,
  concat,
  defer,
  distinctUntilChanged,
  from,
  mergeMap,
  of,
  switchMap,
  takeUntil,
  throwError
} from 'rxjs';
import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';
import { strictEquals } from '@cardano-sdk/util';

const POLL_UNTIL_RETRY = Symbol('POLL_UNTIL_RETRY');

export interface PollProps<T> {
  sample: () => Promise<T>;
  retryBackoffConfig: RetryBackoffConfig;
  trigger$?: Observable<unknown>;
  equals?: (t1: T, t2: T) => boolean;
  combinator?: typeof switchMap;
  cancel$?: Observable<unknown>;
  pollUntil?: (v: T) => boolean;
  logger: Logger;
}

export const poll = <T>({
  sample,
  retryBackoffConfig,
  trigger$ = of(true),
  equals = strictEquals,
  combinator = switchMap,
  cancel$ = NEVER,
  pollUntil = () => true,
  logger
}: PollProps<T>) =>
  trigger$.pipe(
    combinator(() =>
      defer(() =>
        from(sample()).pipe(
          mergeMap((v) =>
            pollUntil(v)
              ? of(v)
              : // Emit value, but also throw error to force retryBackoff to kick in
                concat(
                  of(v),
                  throwError(() => POLL_UNTIL_RETRY)
                )
          )
        )
      ).pipe(
        retryBackoff({
          ...retryBackoffConfig,
          shouldRetry: (error) => {
            if (error === POLL_UNTIL_RETRY) {
              logger.warn('"pollUntil" condition not met, will retry');
              return true;
            }

            logger.error(error);

            if (retryBackoffConfig.shouldRetry) {
              const shouldRetry = retryBackoffConfig.shouldRetry(error);
              logger.debug(`Should retry: ${shouldRetry}`);
              return shouldRetry;
            }

            return true;
          }
        })
      )
    ),
    distinctUntilChanged(equals),
    takeUntil(cancel$)
  );
