import { Observable, map, mergeMap, take, timer } from 'rxjs';
import type { Logger } from 'ts-log';

export interface LoadTestSchedulerProps<T> {
  /** Time in seconds during which the scheduler calls the `callUnderTest` */
  duration: number;
  /** How many times scheduler will call `callUnderTest` in the given `duration` */
  callsPerDuration: number;
  /** Each call will have a unique incrementing numeric id. This is the start value. */
  idOffset?: number;
  /** Asynchronous call that will be called `callsPerDuration` times, evenly split in `duration` seconds */
  callUnderTest: (id: number) => Observable<T>;
}

export interface LoadTestSchedulerDependencies {
  logger: Logger;
}

/** Use `LoadTestSchedulerProps` to schedule calls to `callUnderTest` */
export const getLoadTestScheduler = <T>(
  { duration, callsPerDuration, idOffset = 0, callUnderTest }: LoadTestSchedulerProps<T>,
  { logger }: LoadTestSchedulerDependencies
): Observable<T> =>
  new Observable<T>((observer) => {
    const callIntervalMs = (duration * 1000) / callsPerDuration;
    logger.info(`Running ${callsPerDuration} calls in ${duration}s, 1 call / ${callIntervalMs}ms`);

    return timer(0, callIntervalMs)
      .pipe(
        map((id) => id + idOffset),
        take(callsPerDuration),
        mergeMap((id) => callUnderTest(id))
      )
      .subscribe(observer);
  });
