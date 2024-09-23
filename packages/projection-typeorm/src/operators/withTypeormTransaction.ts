/* eslint-disable func-style */
import { Observable, Subject, defer, from, map, mergeMap } from 'rxjs';
import { PgBossExtension } from '../pgBoss';
import {
  ProjectionEvent,
  UnifiedExtChainSyncObservable,
  UnifiedExtChainSyncOperator,
  withEventContext,
  withStaticContext
} from '@cardano-sdk/projection';
import { QueryRunner } from 'typeorm';
import { TypeormConnection } from '../createDataSource';
import omit from 'lodash/omit.js';
import type { IsolationLevel } from 'typeorm/driver/types/IsolationLevel';

export interface WithTypeormTransactionDependencies {
  connection$: Observable<TypeormConnection>;
  isolationLevel?: IsolationLevel;
}

export interface WithTypeormContext {
  queryRunner: QueryRunner;
}

export interface WithPgBoss {
  pgBoss: PgBossExtension;
}

type TypeormContextProp = keyof (WithTypeormContext & WithPgBoss);
const WithTypeormTransactionProps: Array<TypeormContextProp> = ['queryRunner', 'pgBoss'];

export function withTypeormTransaction<Props>(
  dependencies: WithTypeormTransactionDependencies & { pgBoss?: false }
): UnifiedExtChainSyncOperator<Props, Props & WithTypeormContext>;

export function withTypeormTransaction<Props>(
  dependencies: WithTypeormTransactionDependencies & { pgBoss: true }
): UnifiedExtChainSyncOperator<Props, Props & WithTypeormContext & WithPgBoss>;

/** Start a PostgreSQL transaction for each event. {pgBoss: true} also adds {@link WithPgBoss} context. */
export function withTypeormTransaction<Props>({
  connection$,
  isolationLevel: transactionType
}: WithTypeormTransactionDependencies & { pgBoss?: boolean }): UnifiedExtChainSyncOperator<
  Props,
  Props & WithTypeormContext & Partial<WithPgBoss>
> {
  // eslint-disable-next-line sonarjs/cognitive-complexity
  return (evt$: UnifiedExtChainSyncObservable<Props>) =>
    evt$.pipe(
      withStaticContext(defer(() => connection$)),
      withEventContext(({ queryRunner }) =>
        from(
          // - transactionCommitted$.next is called after COMMIT, it is
          //   used by TypeormStabilityWindowBuffer to emit new tip$
          // - might be possible to optimize by setting a different isolation level,
          //   but we're using the safest one until there's a need to optimize
          //   https://www.postgresql.org/docs/current/transaction-iso.html
          queryRunner.startTransaction(transactionType).then(() => ({ transactionCommitted$: new Subject<void>() }))
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
          map(() => {
            // The explicit cast is (probably) needed because typecript can't check that
            // we're not removing any properties overlapping with T
            const result = omit(evt, WithTypeormTransactionProps);
            return result as ProjectionEvent<Omit<T, TypeormContextProp>>;
          })
        )
      )
    );
