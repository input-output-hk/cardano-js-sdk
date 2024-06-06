/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable prefer-spread */
import { Bootstrap, logProjectionProgress, requestNext } from '@cardano-sdk/projection';
import {
  TypeormStabilityWindowBuffer,
  createObservableConnection,
  createTypeormTipTracker,
  isRecoverableTypeormError,
  typeormTransactionCommit,
  withTypeormTransaction
} from '@cardano-sdk/projection-typeorm';
import { concat, defer, groupBy, mergeMap, take, takeWhile } from 'rxjs';
import { migrations } from './migrations/index.js';
import { passthrough, shareRetryBackoff, toEmpty } from '@cardano-sdk/util-rxjs';
import { prepareTypeormProjection } from './prepareTypeormProjection.js';
import type { Cardano, ObservableCardanoNode } from '@cardano-sdk/core';
import type { Logger } from 'ts-log';
import type { Observable } from 'rxjs';
import type {
  PgConnectionConfig,
  TypeormDevOptions,
  TypeormOptions,
  WithTypeormContext
} from '@cardano-sdk/projection-typeorm';
import type { PreparedProjection, ProjectionName, ProjectionOptions } from './prepareTypeormProjection.js';
import type { ProjectionEvent } from '@cardano-sdk/projection';
import type { ReconnectionConfig } from '@cardano-sdk/util-rxjs';

const reconnectionConfig: ReconnectionConfig = {
  initialInterval: 50,
  maxInterval: 5000
};

export interface CreateTypeormProjectionProps {
  projections: ProjectionName[];
  blocksBufferLength: number;
  connectionConfig$: Observable<PgConnectionConfig>;
  devOptions?: TypeormDevOptions;
  exitAtBlockNo?: Cardano.BlockNo;
  logger: Logger;
  cardanoNode: ObservableCardanoNode;
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
  connectionConfig$,
  logger,
  devOptions: requestedDevOptions,
  cardanoNode,
  exitAtBlockNo,
  projectionOptions
}: CreateTypeormProjectionProps) => {
  const { handlePolicyIds } = { handlePolicyIds: [], ...projectionOptions };

  logger.debug(`Creating projection with policyIds ${JSON.stringify(handlePolicyIds)}`);
  logger.debug(`Using a ${blocksBufferLength} blocks buffer`);

  const { mappers, entities, stores, extensions, willStore } = prepareTypeormProjection(
    {
      options: projectionOptions,
      projections
    },
    { logger }
  );
  const connect = (options?: TypeormOptions, devOptions?: TypeormDevOptions) =>
    createObservableConnection({
      connectionConfig$,
      devOptions,
      entities,
      extensions,
      logger,
      options
    });

  const tipTracker = createTypeormTipTracker({
    connection$: connect(),
    reconnectionConfig
  });
  const buffer = new TypeormStabilityWindowBuffer({
    connection$: connect(),
    logger,
    reconnectionConfig
  });
  const projectionSource$ = Bootstrap.fromCardanoNode({
    blocksBufferLength,
    buffer,
    cardanoNode,
    logger,
    projectedTip$: tipTracker.tip$
  });
  return concat(
    // initialize database before starting the projector
    connect(
      {
        installExtensions: true,
        migrations: migrations.filter(({ entity }) => entities.includes(entity as any)),
        migrationsRun: !requestedDevOptions?.synchronize
      },
      requestedDevOptions
    ).pipe(take(1), toEmpty),
    defer(() =>
      projectionSource$.pipe(
        applyMappers(mappers),
        // if there are any relevant data to write into db
        groupBy((evt) => willStore(evt)),
        mergeMap((group$) =>
          group$.key
            ? group$.pipe(
                shareRetryBackoff(
                  (evt$) =>
                    evt$.pipe(
                      withTypeormTransaction({ connection$: connect() }),
                      applyStores(stores),
                      buffer.storeBlockData(),
                      typeormTransactionCommit()
                    ),
                  { shouldRetry: isRecoverableTypeormError }
                )
              )
            : group$
        ),
        tipTracker.trackProjectedTip(),
        requestNext(),
        logProjectionProgress(logger),
        exitAtBlockNo ? takeWhile((event) => event.block.header.blockNo < exitAtBlockNo) : passthrough()
      )
    )
  );
};
