import { BehaviorSubject, Observable, Subscription, filter, firstValueFrom, timeout } from 'rxjs';
import { DataSource, QueryRunner } from 'typeorm';
import { Logger } from 'ts-log';
import { Milliseconds } from '@cardano-sdk/core';
import { PgConnectionConfig } from '@cardano-sdk/projection-typeorm';
import { RunnableModule, isNotNil } from '@cardano-sdk/util';
import { createTypeormDataSource } from '../createTypeormDataSource';

export interface TypeormServiceDependencies {
  logger: Logger;
  entities: Function[];
  connectionConfig$: Observable<PgConnectionConfig>;
  connectionTimeout: Milliseconds;
}

export abstract class TypeormService extends RunnableModule {
  #entities: Function[];
  #connectionConfig$: Observable<PgConnectionConfig>;
  protected dataSource$ = new BehaviorSubject<DataSource | null>(null);
  #subscription: Subscription | undefined;
  #connectionTimeout: Milliseconds;

  constructor(name: string, { connectionConfig$, logger, entities, connectionTimeout }: TypeormServiceDependencies) {
    super(name, logger);
    this.#entities = entities;
    this.#connectionConfig$ = connectionConfig$;
    this.#connectionTimeout = connectionTimeout;
  }

  async #subscribeToDataSource() {
    return new Promise((resolve, reject) => {
      this.#subscription = createTypeormDataSource(this.#connectionConfig$, this.#entities, this.logger).subscribe(
        (dataSource) => {
          if (dataSource !== this.dataSource$.value) {
            this.dataSource$.next(dataSource);
          }
          if (dataSource) {
            resolve(dataSource);
          } else {
            reject(new Error('Failed to initialize data source'));
          }
        }
      );
    });
  }

  #reset() {
    this.#subscription?.unsubscribe();
    this.#subscription = undefined;
    this.dataSource$.value !== null && this.dataSource$.next(null);
  }

  onError(_: unknown) {
    this.#reset();
    void this.#subscribeToDataSource().catch(() => void 0);
  }

  async withDataSource<T>(callback: (dataSource: DataSource) => Promise<T>): Promise<T> {
    // eslint-disable-next-line @typescript-eslint/no-unused-expressions
    this.#connectionTimeout;
    try {
      return await callback(
        await firstValueFrom(this.dataSource$.pipe(filter(isNotNil), timeout({ first: this.#connectionTimeout })))
      );
    } catch (error) {
      this.onError(error);
      throw error;
    }
  }

  async withQueryRunner<T>(callback: (queryRunner: QueryRunner) => Promise<T>): Promise<T> {
    return this.withDataSource(async (dataSource) => {
      const queryRunner = dataSource.createQueryRunner();
      try {
        const result = await callback(queryRunner);
        await queryRunner.release();
        return result;
      } catch (error) {
        try {
          await queryRunner.release();
        } catch (releaseError) {
          this.logger.warn(releaseError);
        }
        throw error;
      }
    });
  }

  async initializeImpl() {
    return Promise.resolve();
  }

  async startImpl() {
    await this.#subscribeToDataSource();
  }

  async shutdownImpl() {
    this.#reset();
    this.dataSource$.complete();
  }
}
