/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable prefer-spread */
import { Cardano } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Observable, takeWhile } from 'rxjs';
import {
  PgConnectionConfig,
  TypeormDevOptions,
  TypeormStabilityWindowBuffer,
  WithTypeormContext,
  createObservableConnection,
  isRecoverableTypeormError,
  typeormTransactionCommit,
  withTypeormTransaction
} from '@cardano-sdk/projection-typeorm';
import {
  PreparedProjection,
  ProjectionName,
  ProjectionOptions,
  prepareTypeormProjection
} from './prepareTypeormProjection';
import { ProjectionEvent, logProjectionProgress, requestNext } from '@cardano-sdk/projection';
import { migrations } from './migrations';
import { passthrough, shareRetryBackoff } from '@cardano-sdk/util-rxjs';

export interface CreateTypeormProjectionProps {
  projections: ProjectionName[];
  blocksBufferLength: number;
  buffer?: TypeormStabilityWindowBuffer;
  projectionSource$: Observable<ProjectionEvent>;
  connectionConfig$: Observable<PgConnectionConfig>;
  devOptions?: TypeormDevOptions;
  exitAtBlockNo?: Cardano.BlockNo;
  logger: Logger;
  projectionOptions?: ProjectionOptions;
}

const applyMappers =
  <T = {}>(selectedMappers: PreparedProjection['mappers']) =>
  (evt$: Observable<ProjectionEvent>) =>
    evt$.pipe.apply(evt$, selectedMappers as any) as Observable<ProjectionEvent<T>>;
const applyStores =
  <T extends WithTypeormContext>(selectedStores: PreparedProjection['stores']) =>
  (evt$: Observable<T>) =>
    evt$.pipe.apply(evt$, selectedStores as any) as Observable<T>;

/**
 * Creates a projection observable that applies a sequence of operators
 * required to project requested `projections` into a postgres database.
 *
 * Uses TypeORM entities and operators defined in 'projection-typeorm' package.
 * Dependencies of each projection are defined in ./prepareTypeormProjection.ts
 */
export const createTypeormProjection = ({
  blocksBufferLength,
  projections,
  projectionSource$,
  connectionConfig$,
  logger,
  devOptions,
  exitAtBlockNo,
  buffer,
  projectionOptions
}: CreateTypeormProjectionProps) => {
  const { handlePolicyIds } = { handlePolicyIds: [], ...projectionOptions };

  logger.debug(`Creating projection with policyIds ${JSON.stringify(handlePolicyIds)}`);
  logger.debug(`Using a ${blocksBufferLength} blocks buffer`);

  const { mappers, entities, stores, extensions } = prepareTypeormProjection(
    {
      buffer,
      options: projectionOptions,
      projections
    },
    { logger }
  );
  const connection$ = createObservableConnection({
    connectionConfig$,
    devOptions,
    entities,
    extensions,
    logger,
    options: {
      installExtensions: true,
      migrations: migrations.filter(({ entity }) => entities.includes(entity as any)),
      migrationsRun: !devOptions?.synchronize
    }
  });
  return projectionSource$.pipe(
    applyMappers(mappers),
    shareRetryBackoff(
      (evt$) => evt$.pipe(withTypeormTransaction({ connection$ }), applyStores(stores), typeormTransactionCommit()),
      { shouldRetry: isRecoverableTypeormError }
    ),
    requestNext(),
    logProjectionProgress(logger),
    exitAtBlockNo ? takeWhile((event) => event.block.header.blockNo < exitAtBlockNo) : passthrough()
  );
};
