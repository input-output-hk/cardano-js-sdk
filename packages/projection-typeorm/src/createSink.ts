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
  defer,
  from,
  map,
  mergeMap,
  of,
  share,
  switchMap,
  tap,
  timer
} from 'rxjs';
import { Operators, Sink } from '@cardano-sdk/projection';
import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';
import { SupportedProjections, applySinks, isRecoverableTypeormError, shouldEnablePgBossExtension } from './util';
import { TypeormStabilityWindowBuffer } from './TypeormStabilityWindowBuffer';
import { WithLogger } from '@cardano-sdk/util';
import { WithTypeormContext } from './types';
import { createPgBossExtension } from './pgBoss';
import { finalizeWithLatest } from '@cardano-sdk/util-rxjs';
import omit from 'lodash/omit';

export type ReconnectionConfig = Omit<RetryBackoffConfig, 'shouldRetry'>;
const defaultReconnectionConfig: ReconnectionConfig = { initialInterval: 10, maxInterval: 5000 };

export interface TypeormSinksProps extends WithLogger {
  /**
   * Re-subscribes to dataSource$ on connection error
   */
  dataSource$: Observable<DataSource>;
  /**
   * Calls initialize() and handleEvents() to write blocks.
   * Does **not** shutdown the buffer when unsubscribed.
   */
  buffer: TypeormStabilityWindowBuffer;
  reconnectionConfig?: ReconnectionConfig;
}

const TypeormContextProps: Array<keyof WithTypeormContext> = [
  'blockEntity',
  'queryRunner',
  'transactionCommitted$',
  'extensions'
];

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

export const createSink =
  ({ dataSource$, reconnectionConfig, logger, buffer }: TypeormSinksProps): Sink<SupportedProjections> =>
  (projections) =>
  (evt$) =>
    defer(() =>
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
          dataSource$.pipe(
            switchMap((dataSource) => withQueryRunner(dataSource, buffer, logger)),
            switchMap(({ queryRunner }): Observable<Pick<WithTypeormContext, 'queryRunner' | 'extensions'>> => {
              if (shouldEnablePgBossExtension(projections)) {
                return from(
                  (async () => {
                    const pgBoss = createPgBossExtension(queryRunner);
                    return { extensions: { pgBoss }, queryRunner };
                  })()
                );
              }
              return of({ extensions: {}, queryRunner });
            })
          )
        ),
        // Transactions must be done sequentially
        concatMap((evt) =>
          of(evt).pipe(
            Operators.withEventContext(
              ({ queryRunner }): Observable<Pick<WithTypeormContext, 'transactionCommitted$'>> =>
                from(
                  // - transactionCommitted$.next is called after COMMIT, it is
                  //   used by TypeormStabilityWindowBuffer to emit new tip$
                  // - might be possible to optimize by setting a different isolation level,
                  //   but we're using the safest one until there's a need to optimize
                  //   https://www.postgresql.org/docs/current/transaction-iso.html
                  queryRunner
                    .startTransaction('SERIALIZABLE')
                    .then(() => ({ transactionCommitted$: new Subject<void>() }))
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
            }),
            applySinks(projections),
            buffer.handleEvents(),
            mergeMap((sinkEvt) =>
              from(sinkEvt.queryRunner.commitTransaction()).pipe(
                tap(() => sinkEvt.transactionCommitted$.next()),
                // The explicit cast is needed because typecript can't check that
                // we're not removing any properties overlapping with 'projections'
                map(() => omit(sinkEvt, TypeormContextProps) as typeof evt)
              )
            )
          )
        ),
        // This will re-subscribe all the way up to 'before' hook's shareReplay,
        // which will re-emit the last event without re-subscribing to chain sync event source,
        // but re-run the entire TypeormSinks initialization, including re-subscribing to connectionConfig$
        retryBackoff({
          ...reconnectionConfig,
          ...defaultReconnectionConfig,
          shouldRetry: (error) => isRecoverableTypeormError(error)
        })
      )
    );

export type TypeormSinks = ReturnType<typeof createSink>;
