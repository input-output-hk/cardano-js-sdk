/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable prefer-spread */
import {
  Bootstrap,
  ProjectionEvent,
  logProjectionProgress,
  requestNext,
  withOperatorDuration
} from '@cardano-sdk/projection';
import { Cardano, ObservableCardanoNode } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Observable, concat, defer, groupBy, mergeMap, take, takeWhile } from 'rxjs';
import {
  PgConnectionConfig,
  TypeormDevOptions,
  TypeormOptions,
  TypeormStabilityWindowBuffer,
  WithTypeormContext,
  createObservableConnection,
  createTypeormTipTracker,
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
import { ReconnectionConfig, passthrough, shareRetryBackoff, toEmpty } from '@cardano-sdk/util-rxjs';
import { migrations } from './migrations';

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

type TrackDurationProps = {
  operatorNames: Array<string | null>;
};

const applyMappers =
  <T = {}>(selectedMappers: PreparedProjection['mappers'], trackDurationProps?: TrackDurationProps) =>
  (evt$: Observable<ProjectionEvent>) =>
    evt$.pipe.apply(
      evt$,
      trackDurationProps
        ? selectedMappers.map((mapper, i) =>
            withOperatorDuration(trackDurationProps.operatorNames[i] || '', mapper as any)
          )
        : (selectedMappers as any)
    ) as Observable<ProjectionEvent<T>>;
const applyStores =
  <T extends WithTypeormContext>(
    selectedStores: PreparedProjection['stores'],
    trackDurationProps?: TrackDurationProps
  ) =>
  (evt$: Observable<T>) =>
    evt$.pipe.apply(
      evt$,
      trackDurationProps
        ? selectedStores.map((mapper, i) =>
            withOperatorDuration(trackDurationProps.operatorNames[i] || '', mapper as any)
          )
        : (selectedStores as any)
    ) as Observable<T>;

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

  const { mappers, entities, stores, extensions, willStore, __debug } = prepareTypeormProjection(
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
        // TODO: only pass {operatorNames} if debugging;
        // we should pass some cli argument here
        applyMappers(mappers, { operatorNames: __debug.mappers }),
        // if there are any relevant data to write into db
        groupBy((evt) => willStore(evt)),
        mergeMap((group$) =>
          group$.key
            ? group$.pipe(
                shareRetryBackoff(
                  (evt$) =>
                    evt$.pipe(
                      withOperatorDuration(
                        'withTypeormTransaction',
                        withTypeormTransaction({ connection$: connect() })
                      ),
                      applyStores(stores, { operatorNames: __debug.stores }),
                      withOperatorDuration('storeBlockData', buffer.storeBlockData()),
                      withOperatorDuration('typeormTransactionCommit', typeormTransactionCommit())
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
