import { CreateDataSourceProps, createDataSource } from '../src';
import { logger } from '@cardano-sdk/util-dev';

export const connectionConfig = {
  database: 'projection',
  host: '127.0.0.1',
  password: 'doNoUseThisSecret!',
  port: 5432,
  username: 'postgres'
};

export const initializeDataSource = async (
  props: Pick<CreateDataSourceProps, 'entities' | 'extensions' | 'devOptions'>
) => {
  const dataSource = createDataSource({
    connectionConfig,
    devOptions: props.devOptions || { dropSchema: true, synchronize: true },
    logger,
    ...props
  });
  await dataSource.initialize();
  return dataSource;
};
