import 'reflect-metadata';
import * as supportedSinks from './sinks';
import { BlockEntity } from './entity/Block.entity';
import { ChainSyncEventType } from '@cardano-sdk/core';
import { DataSource } from 'typeorm';
import { Logger } from 'ts-log';
import {
  NEVER,
  Observable,
  ReplaySubject,
  Subject,
  concat,
  concatMap,
  finalize,
  from,
  map,
  share,
  switchMap,
  tap,
  timer
} from 'rxjs';
import {
  Operators,
  ProjectionSinks,
  Projections,
  Sinks,
  UnifiedProjectorEvent,
  UnifiedProjectorObservable
} from '@cardano-sdk/projection';
import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';
import { TypeormStabilityWindowBuffer, TypeormStabilityWindowBufferProps } from './TypeormStabilityWindowBuffer';
import { WithLogger } from '@cardano-sdk/util';
import { WithTypeormContext } from './types';
import { finalizeWithLatest } from '@cardano-sdk/util-rxjs';
import { isRecoverableTypeormError } from './util';
import omit from 'lodash/omit';

export type ReconnectionConfig = Omit<RetryBackoffConfig, 'shouldRetry'>;
const defaultReconnectionConfig: ReconnectionConfig = { initialInterval: 10, maxInterval: 5000 };

export interface TypeormSinksProps extends TypeormStabilityWindowBufferProps, WithLogger {
  /**
   * Re-subscribes to dataSource$ on connection error
   */
  dataSource$: Observable<DataSource>;
  reconnectionConfig?: ReconnectionConfig;
}

const TypeormContextProps: Array<keyof WithTypeormContext> = ['blockEntity', 'queryRunner', 'transactionCommitted$'];

export type SupportedProjections = Pick<Projections.AllProjections, keyof typeof supportedSinks>;

const withQueryRunner = (dataSource: DataSource, buffer: TypeormStabilityWindowBuffer, logger: Logger) =>
  concat(
    from(
      (async () => {
        const queryRunner = dataSource.createQueryRunner('master');
        await queryRunner.connect();
        // buffer has to emit tip$ and tail$ for projectIntoSink
        // to find intersection before emitting any events
        await buffer.initialize(queryRunner);
        return { queryRunner };
      })()
    ),
    NEVER
  ).pipe(
    finalizeWithLatest(async (evt) => {
      if (!evt) return;
      if (evt.queryRunner.isTransactionActive) {
        try {
          await evt.queryRunner.rollbackTransaction();
        } catch (error) {
          logger.error('Failed to rollback transaction', error);
        }
      }
      if (!evt.queryRunner.isReleased) {
        try {
          await evt.queryRunner.release();
        } catch (error) {
          logger.error('Failed to "release" query runner', error);
        }
      }
    })
  );

export const createSinks = ({
  dataSource$,
  reconnectionConfig,
  logger,
  compactBufferEveryNBlocks,
  allowNonSequentialBlockHeights
}: TypeormSinksProps): Sinks<SupportedProjections> => {
  const buffer = new TypeormStabilityWindowBuffer(
    { allowNonSequentialBlockHeights, compactBufferEveryNBlocks },
    { logger }
  );
  return {
    after: (evt$: Observable<UnifiedProjectorEvent<WithTypeormContext>>) =>
      evt$.pipe(
        concatMap((evt) =>
          from(evt.queryRunner.commitTransaction()).pipe(
            tap(() => evt.transactionCommitted$.next()),
            map(() => omit(evt, TypeormContextProps))
          )
        ),
        // This will re-subscribe all the way up to 'before' hook's shareReplay,
        // which will re-emit the last event without re-subscribing to chain sync event source,
        // but re-run the entire TypeormSinks initialization, including re-subscribing to connectionConfig$
        retryBackoff({
          ...reconnectionConfig,
          ...defaultReconnectionConfig,
          shouldRetry: (error) => isRecoverableTypeormError(error)
        }),
        finalize(() => buffer.shutdown())
      ),
    before: (evt$: UnifiedProjectorObservable<{}>): Observable<WithTypeormContext> =>
      evt$.pipe(
        // {refCount: true} combined with retryBackoff() re-subscribes to source,
        // because retryBackoff unsubscribes the source before re-subscribing.
        // A proper solution here would be to change how retryBackoff works,
        // because without {refCount: true} it will keep subscription to source forever.
        // ADP-2808: need to eliminate the race when reconnecting - it is unsubscribed as soon as the error happens
        // and it can take any amount of time to get a new datasource
        share({
          connector: () => new ReplaySubject(1),
          resetOnComplete: false,
          resetOnError: true,
          resetOnRefCountZero: () => timer(3000)
        }),
        Operators.withStaticContext(
          dataSource$.pipe(switchMap((dataSource) => withQueryRunner(dataSource, buffer, logger)))
        ),
        Operators.withEventContext(
          ({ queryRunner }): Observable<Pick<WithTypeormContext, 'transactionCommitted$'>> =>
            from(
              // - transactionCommitted$.next is called in 'after' hook, it is
              //   used by TypeormStabilityWindowBuffer to emit new tip$
              // - might be possible to optimize by setting a different isolation level,
              //   but we're using the safest one until there's a need to optimize
              //   https://www.postgresql.org/docs/current/transaction-iso.html
              queryRunner.startTransaction('SERIALIZABLE').then(() => ({ transactionCommitted$: new Subject<void>() }))
            )
        ),
        Operators.withEventContext(({ block, queryRunner, eventType }) => {
          const repository = queryRunner.manager.getRepository(BlockEntity);
          const blockEntity = repository.create({
            hash: block.header.hash,
            height: block.header.blockNo,
            slot: block.header.slot
          });
          return from(
            eventType === ChainSyncEventType.RollForward
              ? repository.insert(blockEntity)
              : repository.delete({
                  hash: blockEntity.hash
                })
          ).pipe(map(() => ({ blockEntity })));
        })
      ),
    buffer,
    // `as unknown` is required because TypeormSink event has additional TypeormContext.
    // We're adding this context in `before` hook, but TypeScript doesn't know that.
    // Should be possible to improve the types to infer the added properties from the `before` hook,
    // But it's probably not worth the effort.
    projectionSinks: supportedSinks as unknown as ProjectionSinks<SupportedProjections>
  };
};

export const createSinksFactory = (props: TypeormSinksProps) => () => createSinks(props);

export type TypeormSinks = ReturnType<typeof createSinks>;

export type TypeormSinksFactory = () => TypeormSinks;
