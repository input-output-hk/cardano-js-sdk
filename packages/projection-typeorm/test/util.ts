import { CreateDataSourceProps, createDataSource } from '../src';
import { createDatabase } from 'typeorm-extension';
import { logger } from '@cardano-sdk/util-dev';

export const connectionConfig = {
  database: 'projection',
  host: '127.0.0.1',
  password: 'doNoUseThisSecret!',
  port: 5432,
  username: 'postgres'
};

export const initializeDataSource = async (props: Pick<CreateDataSourceProps, 'entities' | 'extensions'>) => {
  const dataSource = createDataSource({
    connectionConfig,
    devOptions: { dropSchema: true, synchronize: true },
    logger,
    ...props
  });
  await createDatabase({
    options: {
      type: 'postgres' as const,
      ...connectionConfig,
      installExtensions: true
    }
  });
  await dataSource.initialize();
  return dataSource;
};
