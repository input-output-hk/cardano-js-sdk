// To be used with typeorm cli for generating migrations.
// Generated script has to be manually converted into 1 or more ProjectionMigration classes.
// Works with local database as started by yarn:*:up
import { allEntities } from './Projection/prepareTypeormProjection';
import { createDataSource } from '@cardano-sdk/projection-typeorm';
export { DataSource } from 'typeorm';

export const AppDataSource = createDataSource({
  connectionConfig: {
    database: 'projection',
    host: 'localhost',
    password: 'doNoUseThisSecret!',
    port: 5432,
    username: 'postgres'
  },
  entities: allEntities,
  logger: console
});
