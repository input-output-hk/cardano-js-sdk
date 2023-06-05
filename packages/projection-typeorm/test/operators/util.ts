import { BaseProjectionEvent, ProjectionEvent } from '@cardano-sdk/projection';
import { Observable, lastValueFrom, takeWhile } from 'rxjs';
import { logger } from '@cardano-sdk/util-dev';

export const createProjectorTilFirst =
  <T>(project: () => Observable<T>) =>
  async (filter: (evt: T) => boolean) =>
    lastValueFrom(project().pipe(takeWhile((evt) => !filter(evt), true)));

/**
 * Never completes, because withTypeormTransaction is completing when the source completes:
 * it is initializing query runner asynchronously, and doesn't have enough time to emit the value(s).
 */
export const createStubProjectionSource = (events: BaseProjectionEvent[]): Observable<ProjectionEvent<{}>> =>
  new Observable((observer) => {
    const remainingEvents = [...events];
    const next = () => {
      const evt = remainingEvents.shift();
      if (evt) {
        observer.next({
          ...evt,
          requestNext: next
        } as ProjectionEvent<{}>);
      } else {
        logger.debug('No more stub events remaining');
      }
    };
    next();
  });
