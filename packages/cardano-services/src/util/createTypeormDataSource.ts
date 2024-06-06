import { createDataSource } from '@cardano-sdk/projection-typeorm';
import { from, switchMap } from 'rxjs';
import type { Logger } from 'ts-log';
import type { Observable } from 'rxjs';
import type { PgConnectionConfig } from '@cardano-sdk/projection-typeorm';

export const createTypeormDataSource = (
  connectionConfig$: Observable<PgConnectionConfig>,
  entities: Function[],
  logger: Logger
) =>
  connectionConfig$.pipe(
    switchMap((connectionConfig) =>
      from(
        (async () => {
          const dataSource = createDataSource({ connectionConfig, entities, logger });
          await dataSource.initialize();
          return dataSource;
        })()
      )
    )
  );
