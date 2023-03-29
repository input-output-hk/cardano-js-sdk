// Runtime dependency: `yarn preprod:up cardano-node-ogmios postgres` (can be any network)
/* eslint-disable import/no-extraneous-dependencies */
const { Bootstrap, Projections, projectIntoSink, logProjectionProgress } = require('@cardano-sdk/projection');
const { createDataSource, createSink, TypeormStabilityWindowBuffer } = require('@cardano-sdk/projection-typeorm');
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
  devOptions: process.argv.includes('--drop')
    ? {
        dropSchema: true,
        synchronize: true
      }
    : undefined,
  logger,
  projections
});

const dataSource$ = from(
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
);

const cardanoNode = new OgmiosObservableCardanoNode(
  {
    connectionConfig$: of({
      port: 1339
    })
  },
  { logger }
);

const buffer = new TypeormStabilityWindowBuffer({ logger });

Bootstrap.fromCardanoNode({
  buffer,
  cardanoNode,
  logger
})
  .pipe(
    projectIntoSink({
      projections,
      sink: createSink({
        buffer,
        dataSource$,
        logger
      })
    }),
    logProjectionProgress(logger)
  )
  .subscribe();
