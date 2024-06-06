// To be used with typeorm cli for generating migrations.
// Generated script has to be manually converted into 1 or more ProjectionMigration classes.
// Works with local database as started by yarn:*:up
import { allEntities } from './Projection/prepareTypeormProjection.js';
import { createDataSource } from '@cardano-sdk/projection-typeorm';
export { DataSource } from 'typeorm';

export const AppDataSource = (() => {
  const { DB_NAME, DB_PORT } = process.env;

  if (!DB_NAME) throw new Error('Please specify the database name through the environment variable DB_NAME');

  return createDataSource({
    connectionConfig: {
      database: DB_NAME,
      host: 'localhost',
      password: 'doNoUseThisSecret!',
      port: DB_PORT ? Number.parseInt(DB_PORT, 10) : 5432,
      username: 'postgres'
    },
    entities: allEntities,
    logger: console
  });
})();
