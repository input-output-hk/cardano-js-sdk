import { BehaviorSubject, Observable, Subscription, filter, firstValueFrom } from 'rxjs';
import { DataSource } from 'typeorm';
import { Logger } from 'ts-log';
import { PgConnectionConfig } from '@cardano-sdk/projection-typeorm';
import { RunnableModule, isNotNil } from '@cardano-sdk/util';
import { TypeormProviderDependencies, createTypeormDataSource } from '../TypeormProvider';

export class TypeormService extends RunnableModule {
  #entities: Function[];
  #connectionConfig$: Observable<PgConnectionConfig>;
  logger: Logger;
  #dataSource$ = new BehaviorSubject<DataSource | null>(null);
  #subscription: Subscription | undefined;

  constructor(name: string, { connectionConfig$, logger, entities }: TypeormProviderDependencies) {
    super(name, logger);
    this.#entities = entities;
    this.#connectionConfig$ = connectionConfig$;
  }

  #subscribeToDataSource() {
    this.#subscription = createTypeormDataSource(this.#connectionConfig$, this.#entities, this.logger).subscribe(
      (dataSource) => this.#dataSource$.next(dataSource)
    );
  }

  #reset() {
    this.#subscription?.unsubscribe();
    this.#subscription = undefined;
    this.#dataSource$.value !== null && this.#dataSource$.next(null);
  }

  onError(_: unknown) {
    this.#reset();
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
