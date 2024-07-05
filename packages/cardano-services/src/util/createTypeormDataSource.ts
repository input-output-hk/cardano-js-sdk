import { Logger } from 'ts-log';
import { Observable, from, switchMap } from 'rxjs';
import { PgConnectionConfig, createDataSource } from '@cardano-sdk/projection-typeorm';

export const createTypeormDataSource = (
  connectionConfig$: Observable<PgConnectionConfig>,
  entities: Function[],
  logger: Logger
) =>
  connectionConfig$.pipe(
    switchMap((connectionConfig) =>
      from(
        (async () => {
          try {
            const dataSource = createDataSource({ connectionConfig, entities, logger });
            await dataSource.initialize();
            return dataSource;
          } catch (error) {
            logger.error(error, 'Error while creating DataSource');
            return null;
          }
        })()
      )
    )
  );
