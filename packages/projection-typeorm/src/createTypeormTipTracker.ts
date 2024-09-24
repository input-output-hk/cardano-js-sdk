import { BaseProjectionEvent, ChainSyncEventType } from '@cardano-sdk/projection';
import { BlockEntity } from './entity';
import { Observable, ReplaySubject, from, map, of, switchMap, take, tap } from 'rxjs';
import { ReconnectionConfig } from '@cardano-sdk/util-rxjs';
import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';
import { TipOrOrigin } from '@cardano-sdk/core';
import { TypeormConnection } from './createDataSource';
import { isRecoverableTypeormError } from './isRecoverableTypeormError';

export interface CreateTypeormTipTrackerProps {
  connection$: Observable<TypeormConnection>;
  /** Retry strategy for tip query. Tracker will re-subscribe to connection$ on each retry. */
  reconnectionConfig: ReconnectionConfig;
}

export const createTypeormTipTracker = ({ connection$, reconnectionConfig }: CreateTypeormTipTrackerProps) => {
  const retryBackoffConfig: RetryBackoffConfig = {
    ...reconnectionConfig,
    shouldRetry: isRecoverableTypeormError
  };
  const queryLocalTip$ = connection$.pipe(
    switchMap(({ queryRunner }) => {
      const blockRepo = queryRunner.manager.getRepository(BlockEntity);
      return from(
        (async (): Promise<TipOrOrigin> => {
          // findOne fails without `where:`, so using find().
          // It makes 2 queries so is not very efficient,
          // but it should be fine for `initialize` and rollbacks.
          const tipQueryResult = await blockRepo.find({
            order: { slot: 'DESC' },
            take: 1
          });
          if (tipQueryResult.length === 0) {
            return 'origin';
          }
          return {
            blockNo: tipQueryResult[0].height!,
            hash: tipQueryResult[0].hash!,
            slot: tipQueryResult[0].slot!
          };
        })()
      );
    }),
    take(1),
    retryBackoff(retryBackoffConfig)
  );
  const tip$ = new ReplaySubject<TipOrOrigin>(1);
  const trackProjectedTip =
    <T extends BaseProjectionEvent>() =>
    (evt$: Observable<T>) =>
      evt$.pipe(
        switchMap((evt) => {
          if (evt.eventType === ChainSyncEventType.RollForward) {
            tip$.next(evt.block.header);
            return of(evt);
          }
          return queryLocalTip$.pipe(
            tap((tip) => tip$.next(tip)),
            map(() => evt)
          );
        })
      );
  return {
    shutdown: tip$.complete.bind(tip$),
    tip$: (() => {
      let initialized = false;
      return new Observable<TipOrOrigin>((subscriber) => {
        if (!initialized) {
          // Lazily initialize on 1st subscription
          queryLocalTip$.subscribe((next) => tip$.next(next));
          initialized = true;
        }
        return tip$.subscribe(subscriber);
      });
    })(),
    trackProjectedTip
  };
};

export type TypeormTipTracker = ReturnType<typeof createTypeormTipTracker>;
