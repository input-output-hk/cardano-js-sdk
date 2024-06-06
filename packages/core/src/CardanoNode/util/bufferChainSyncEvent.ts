import { Observable } from 'rxjs';
import type { RequestNext, WithRequestNext } from '../types/index.js';

export const bufferChainSyncEvent =
  <T extends WithRequestNext>(length: number) =>
  // eslint-disable-next-line sonarjs/cognitive-complexity
  (source$: Observable<T>) =>
    new Observable<T>((subscriber) => {
      const buffer: WithRequestNext[] = [];
      let lastPull: RequestNext | undefined;
      let unsubscribed = false;
      let subscriberReady = true;
      let sourceCompleted = false;
      let sourceError: unknown | undefined;

      const next = () => {
        if (unsubscribed) return;

        if (buffer.length < length && lastPull) {
          lastPull();
          lastPull = undefined;
        }

        if (!subscriberReady) return;

        if (buffer.length === 0) {
          if (sourceCompleted) return subscriber.complete();
          if (sourceError) return subscriber.error(sourceError);

          return;
        }

        const value = buffer.shift()!;

        subscriberReady = false;
        subscriber.next({
          ...value,
          requestNext: () => {
            subscriberReady = true;
            next();
          }
        } as T);
      };

      const subscription = source$.subscribe({
        complete: () => {
          sourceCompleted = true;
          next();
        },
        error: (error) => {
          sourceError = error;
          next();
        },
        next: (value) => {
          lastPull = value.requestNext;
          buffer.push(value);
          next();
        }
      });

      return () => {
        subscription.unsubscribe();
        unsubscribed = true;
      };
    });
