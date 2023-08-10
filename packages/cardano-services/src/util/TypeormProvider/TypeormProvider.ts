import { BehaviorSubject, Observable, tap } from 'rxjs';
import { DataSource } from 'typeorm';
import { HealthCheckResponse, Provider } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { PgConnectionConfig } from '@cardano-sdk/projection-typeorm';
import { TypeormService } from '../TypeormService';
import { createTypeormDataSource } from '../createTypeormSource';

export interface TypeormProviderDependencies {
  logger: Logger;
  entities: Function[];
  connectionConfig$: Observable<PgConnectionConfig>;
}

export abstract class TypeormProvider extends TypeormService implements Provider {
  #entities: Function[];
  #connectionConfig$: Observable<PgConnectionConfig>;
  #dataSource$ = new BehaviorSubject<DataSource | null>(null);
  health: HealthCheckResponse = { ok: false, reason: 'not started' };

  constructor(name: string, { connectionConfig$, logger, entities }: TypeormProviderDependencies) {
    super(name, { connectionConfig$, entities, logger });
    this.#entities = entities;
    this.#connectionConfig$ = connectionConfig$;
  }

  #subscribeToDataSource() {
    return createTypeormDataSource(this.#connectionConfig$, this.#entities, this.logger)
      .pipe(
        tap(() => {
          this.health = { ok: true };
        })
      )
      .subscribe((dataSource) => this.#dataSource$.next(dataSource));
  }

  onError(_: unknown) {
    this.health = { ok: false, reason: 'Provider error' };
    this.#subscribeToDataSource();
  }

  async healthCheck(): Promise<HealthCheckResponse> {
    this.#subscribeToDataSource();
    return this.health;
  }
}
