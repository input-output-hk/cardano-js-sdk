/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable prefer-spread */
import { Logger } from 'ts-log';
import { Observable, from, switchMap } from 'rxjs';
import {
  PgConnectionConfig,
  TypeormDevOptions,
  TypeormStabilityWindowBuffer,
  WithTypeormContext,
  createDataSource,
  isRecoverableTypeormError,
  typeormTransactionCommit,
  withTypeormTransaction
} from '@cardano-sdk/projection-typeorm';
import { PreparedProjection, ProjectionName, prepareTypeormProjection } from './prepareTypeormProjection';
import { ProjectionEvent, logProjectionProgress, requestNext } from '@cardano-sdk/projection';
import { migrations } from './migrations';
import { shareRetryBackoff } from '@cardano-sdk/util-rxjs';

export interface CreateTypeormProjectionProps {
  projections: ProjectionName[];
  buffer?: TypeormStabilityWindowBuffer;
  projectionSource$: Observable<ProjectionEvent>;
  connectionConfig$: Observable<PgConnectionConfig>;
  devOptions?: TypeormDevOptions;
  logger: Logger;
}

const applyMappers =
  <T = {}>(selectedMappers: PreparedProjection['mappers']) =>
  (evt$: Observable<ProjectionEvent>) =>
    evt$.pipe.apply(evt$, selectedMappers as any) as Observable<ProjectionEvent<T>>;
const applyStores =
  <T extends WithTypeormContext>(selectedStores: PreparedProjection['stores']) =>
  (evt$: Observable<T>) =>
    evt$.pipe.apply(evt$, selectedStores as any) as Observable<T>;

const createProjectionDataSource = ({
  connectionConfig$,
  logger,
  buffer,
  devOptions,
  entities,
  extensions
}: Omit<CreateTypeormProjectionProps, 'projections' | 'projectionSource$'> &
  Pick<PreparedProjection, 'entities' | 'extensions'>) =>
  connectionConfig$.pipe(
    switchMap((connectionConfig) =>
      from(
        (async () => {
          const dataSource = createDataSource({
            connectionConfig,
            devOptions,
            entities,
            extensions,
            logger,
            options: {
              installExtensions: true,
              migrations: migrations.filter(({ entity }) => entities.includes(entity as any)),
              migrationsRun: true
            }
          });
          await dataSource.initialize();
          if (buffer) {
            const queryRunner = dataSource.createQueryRunner('master');
            await buffer.initialize(queryRunner);
            await queryRunner.release();
          }
          return dataSource;
        })()
      )
    )
  );

/**
 * Creates a projection observable that applies a sequence of operators
 * required to project requested `projections` into a postgres database.
 *
 * Uses TypeORM entities and operators defined in 'projection-typeorm' package.
 * Dependencies of each projection are defined in ./prepareTypeormProjection.ts
 */
export const createTypeormProjection = ({
  projections,
  projectionSource$,
  connectionConfig$,
  logger,
  devOptions,
  buffer
}: CreateTypeormProjectionProps) => {
  const { mappers, entities, stores, extensions } = prepareTypeormProjection({ buffer, projections });
  const dataSource$ = createProjectionDataSource({
    buffer,
    connectionConfig$,
    devOptions,
    entities,
    extensions,
    logger
  });
  return projectionSource$.pipe(
    applyMappers(mappers),
    shareRetryBackoff(
      (evt$) =>
        evt$.pipe(
          withTypeormTransaction({ dataSource$, logger }, extensions),
          applyStores(stores),
          typeormTransactionCommit()
        ),
      { shouldRetry: isRecoverableTypeormError }
    ),
    requestNext(),
    logProjectionProgress(logger)
  );
};
