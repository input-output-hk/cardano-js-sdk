import { BaseProjectionEvent } from '@cardano-sdk/projection';
import {
  EMPTY,
  Observable,
  OperatorFunction,
  Subscription,
  last,
  map,
  merge,
  of,
  share,
  startWith,
  switchMap,
  takeUntil,
  timer
} from 'rxjs';
import { HealthCheckResponse, Milliseconds } from '@cardano-sdk/core';
import { HttpService } from '../Http';
import { Logger } from 'ts-log';
import { ProjectionName } from './prepareTypeormProjection';
import express from 'express';

export interface ProjectionServiceProps<T> {
  projection$: Observable<T>;
  projectionNames: ProjectionName[];
  /** Service will report unhealthy if it didn't project a block in `healthTimeout` ms. 60_000 by default. */
  healthTimeout?: Milliseconds;
  dryRun?: boolean;
}

export interface ProjectionServiceDependencies {
  logger: Logger;
  router?: express.Router;
}

const whileSourceOpen =
  <In, Out>(op: OperatorFunction<In, Out>): OperatorFunction<In, Out> =>
  (source$) => {
    const sharedEvt$ = source$.pipe(share());
    return sharedEvt$.pipe(op, takeUntil(sharedEvt$.pipe(last(null, null))));
  };

const toProjectionHealth = (maxFrequency: Milliseconds) => (evt$: Observable<BaseProjectionEvent>) =>
  evt$.pipe(
    map((e): HealthCheckResponse => {
      if (e.tip === 'origin') {
        return {
          ok: false,
          reason: 'CardanoNode at origin'
        };
      }
      return {
        localNode: {
          ledgerTip: e.tip
        },
        ok: e.tip.blockNo === e.block.header.blockNo && e.tip.hash === e.block.header.hash,
        projectedTip: e.block.header
      };
    }),
    map((health) => of(health)),
    startWith(EMPTY),
    whileSourceOpen(
      switchMap((health$) =>
        merge(
          health$,
          // switchMap unsubscribes/cancels the timer if source emits sooner
          timer(maxFrequency).pipe(
            map((): HealthCheckResponse => ({ ok: false, reason: `Projection timeout (${maxFrequency}ms)` }))
          )
        )
      )
    )
  );

/**
 * Manages subscription to provided `projection$` observable by implementing `RunnableModule`.
 *
 * Implements `HttpService.healthCheck()` by considering itself health only when
 * local node tip is equal to the projected tip.
 */
export class ProjectionHttpService<T extends BaseProjectionEvent> extends HttpService {
  #projection$: Observable<T>;
  #projectionSubscription?: Subscription;
  #healthTimeout: Milliseconds;
  #health: HealthCheckResponse = { ok: false, reason: 'ProjectionHttpService not started' };
  #dryRun?: boolean;

  constructor(
    { projection$, projectionNames, healthTimeout = Milliseconds(180_000), dryRun }: ProjectionServiceProps<T>,
    { logger, router = express.Router() }: ProjectionServiceDependencies
  ) {
    super(
      `Projection(${projectionNames.join(',')})`,
      { healthCheck: async () => this.#health },
      router,
      __dirname,
      logger
    );
    this.#dryRun = dryRun;
    this.#projection$ = projection$;
    this.#healthTimeout = healthTimeout;
  }

  async shutdownImpl(): Promise<void> {
    this.#projectionSubscription?.unsubscribe();
  }

  async startImpl(): Promise<void> {
    if (this.#dryRun) return;
    this.#projectionSubscription = this.#projection$.pipe(toProjectionHealth(this.#healthTimeout)).subscribe({
      complete: () => {
        throw new Error('Projection stopped');
      },
      next: (health) => (this.#health = health)
    });
  }
}
