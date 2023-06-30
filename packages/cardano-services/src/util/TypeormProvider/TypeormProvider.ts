import { BehaviorSubject, Observable, Subscription, filter, firstValueFrom, tap } from 'rxjs';
import { DataSource } from 'typeorm';
import { HealthCheckResponse, Provider } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { PgConnectionConfig } from '@cardano-sdk/projection-typeorm';
import { RunnableModule, isNotNil } from '@cardano-sdk/util';
import { createTypeormDataSource } from './util';

export interface TypeormProviderDependencies {
  logger: Logger;
  entities: Function[];
  connectionConfig$: Observable<PgConnectionConfig>;
}

export abstract class TypeormProvider extends RunnableModule implements Provider {
  #entities: Function[];
  #subscription: Subscription | undefined;
  #connectionConfig$: Observable<PgConnectionConfig>;
  #dataSource$ = new BehaviorSubject<DataSource | null>(null);

  logger: Logger;
  health: HealthCheckResponse = { ok: false, reason: 'not started' };

  constructor({ connectionConfig$, logger, entities }: TypeormProviderDependencies) {
    super('TypeormProvider', logger);
    this.#entities = entities;
    this.#connectionConfig$ = connectionConfig$;
  }

  #subscribeToDataSource() {
    this.#subscription = createTypeormDataSource(this.#connectionConfig$, this.#entities, this.logger)
      .pipe(
        tap(() => {
          this.health = { ok: true };
        })
      )
      .subscribe((dataSource) => this.#dataSource$.next(dataSource));
  }

  #reset() {
    this.#subscription?.unsubscribe();
    this.#subscription = undefined;
    this.#dataSource$.value !== null && this.#dataSource$.next(null);
  }

  onError(_: unknown) {
    this.#reset();
    this.health = { ok: false, reason: 'Provider error' };
    this.#subscribeToDataSource();
  }

  async withDataSource<T>(callback: (dataSource: DataSource) => Promise<T>): Promise<T> {
    try {
      return await callback(await firstValueFrom(this.#dataSource$.pipe(filter(isNotNil))));
    } catch (error) {
      this.onError(error);
      throw error;
    }
  }

  async healthCheck(): Promise<HealthCheckResponse> {
    return this.health;
  }

  async initializeImpl() {
    return Promise.resolve();
  }

  async startImpl() {
    this.#subscribeToDataSource();
  }

  async shutdownImpl() {
    this.#reset();
    this.#dataSource$.complete();
  }
}
