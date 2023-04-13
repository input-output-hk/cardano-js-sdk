/* eslint-disable func-style */
import { DataSource, QueryRunner } from 'typeorm';
import { DataSourceExtensions } from '../createDataSource';
import { NEVER, Observable, Subject, concat, defer, from, map, mergeMap, switchMap, tap } from 'rxjs';
import {
  Operators,
  ProjectionEvent,
  UnifiedExtChainSyncObservable,
  UnifiedExtChainSyncOperator
} from '@cardano-sdk/projection';
import { PgBossExtension, createPgBossExtension } from '../pgBoss';
import { WithLogger } from '@cardano-sdk/util';
import { finalizeWithLatest } from '@cardano-sdk/util-rxjs';
import omit from 'lodash/omit';

export interface WithTypeormTransactionDependencies extends WithLogger {
  dataSource$: Observable<DataSource>;
}

export interface WithTypeormContext {
  queryRunner: QueryRunner;
  transactionCommitted$: Subject<void>;
}

export interface WithPgBoss {
  pgBoss: PgBossExtension;
}

type TypeormContextProp = keyof (WithTypeormContext & WithPgBoss);
const WithTypeormTransactionProps: Array<TypeormContextProp> = ['queryRunner', 'transactionCommitted$', 'pgBoss'];

export function withTypeormTransaction<Props>(
  dependencies: WithTypeormTransactionDependencies
): UnifiedExtChainSyncOperator<Props, Props & WithTypeormContext>;
export function withTypeormTransaction<Props>(
  dependencies: WithTypeormTransactionDependencies,
  extensions: { pgBoss: true }
): UnifiedExtChainSyncOperator<Props, Props & WithTypeormContext & WithPgBoss>;
/**
 * Start a PostgreSQL transaction for each event.
 *
 * {pgBoss: true} also adds {@link WithPgBoss} context.
 */
export function withTypeormTransaction<Props>(
  { dataSource$, logger }: WithTypeormTransactionDependencies,
  extensions?: DataSourceExtensions
): UnifiedExtChainSyncOperator<Props, Props & WithTypeormContext & Partial<WithPgBoss>> {
  // eslint-disable-next-line sonarjs/cognitive-complexity
  return (evt$: UnifiedExtChainSyncObservable<Props>) =>
    evt$.pipe(
      Operators.withStaticContext(
        defer(() =>
          dataSource$.pipe(
            switchMap((dataSource) =>
              concat(
                from(
                  (async () => {
                    const queryRunner = dataSource.createQueryRunner('master');
                    await queryRunner.connect();
                    if (extensions?.pgBoss) {
                      const pgBoss = createPgBossExtension(queryRunner);
                      return { pgBoss, queryRunner };
                    }
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
              )
            )
          )
        )
      ),
      Operators.withEventContext(({ queryRunner }) =>
        from(
          // - transactionCommitted$.next is called after COMMIT, it is
          //   used by TypeormStabilityWindowBuffer to emit new tip$
          // - might be possible to optimize by setting a different isolation level,
          //   but we're using the safest one until there's a need to optimize
          //   https://www.postgresql.org/docs/current/transaction-iso.html
          queryRunner.startTransaction('SERIALIZABLE').then(() => ({ transactionCommitted$: new Subject<void>() }))
        )
      )
    );
}

/**
 * Commit PostgreSQL transaction, started by {@link withTypeormTransaction}.
 * Sanitize event object (remove TypeORM context)
 */
export const typeormTransactionCommit =
  <T extends WithTypeormContext>() =>
  (evt$: Observable<ProjectionEvent<T>>): Observable<ProjectionEvent<Omit<T, TypeormContextProp>>> =>
    evt$.pipe(
      mergeMap((evt) =>
        from(evt.queryRunner.commitTransaction()).pipe(
          tap(() => evt.transactionCommitted$.next()),
          map(() => {
            // The explicit cast is (probably) needed because typecript can't check that
            // we're not removing any properties overlapping with T
            const result = omit(evt, WithTypeormTransactionProps);
            return result as ProjectionEvent<Omit<T, TypeormContextProp>>;
          })
        )
      )
    );
