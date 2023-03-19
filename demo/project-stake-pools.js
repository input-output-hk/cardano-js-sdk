// Runtime dependency: `yarn preprod:up cardano-node-ogmios postgres` (can be any network)
/* eslint-disable import/no-extraneous-dependencies */
const { Projections, projectIntoSink } = require('@cardano-sdk/projection');
const { createDataSource, createSinks } = require('@cardano-sdk/projection-typeorm');
const { OgmiosObservableCardanoNode } = require('@cardano-sdk/ogmios');
const { from, of } = require('rxjs');
const { createDatabase } = require('typeorm-extension');

const logger = {
  ...console,
  debug: () => void 0
};

const projections = {
  stakePools: Projections.stakePools
};

const connectionConfig = {
  database: 'projection',
  host: 'localhost',
  password: 'doNoUseThisSecret!',
  username: 'postgres'
};

const dataSource = createDataSource({
  connectionConfig,
  devOptions: {
    dropSchema: true,
    synchronize: true
  },
  logger,
  projections
});

const cardanoNode = new OgmiosObservableCardanoNode(
  {
    connectionConfig$: of({
      port: 1339
    })
  },
  { logger }
);

projectIntoSink({
  cardanoNode,
  logger,
  projections,
  sinksFactory: () =>
    createSinks({
      dataSource$: from(
        (async () => {
          await createDatabase({
            options: {
              type: 'postgres',
              ...connectionConfig,
              installExtensions: true
            }
          });
          await dataSource.initialize();
          return dataSource;
        })()
      ),
      logger
    })
}).subscribe();
