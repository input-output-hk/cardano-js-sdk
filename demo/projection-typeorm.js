// Runtime dependency: `yarn preprod:up cardano-node-ogmios postgres` (can be any network)
/* eslint-disable import/no-extraneous-dependencies */
const { Bootstrap, Mappers, requestNext, logProjectionProgress } = require('@cardano-sdk/projection');
const {
  createDataSource,
  withTypeormTransaction,
  typeormTransactionCommit,
  TypeormStabilityWindowBuffer,
  BlockDataEntity,
  BlockEntity,
  StakePoolEntity,
  PoolRegistrationEntity,
  PoolRetirementEntity,
  OutputEntity,
  AssetEntity,
  TokensEntity,
  storeBlock,
  storeAssets,
  storeUtxo,
  storeStakePools,
  storeStakePoolMetadataJob,
  isRecoverableTypeormError
} = require('@cardano-sdk/projection-typeorm');
const { OgmiosObservableCardanoNode } = require('@cardano-sdk/ogmios');
const { defer, from, of } = require('rxjs');
const { createDatabase } = require('typeorm-extension');
const { shareRetryBackoff } = require('@cardano-sdk/util-rxjs');

const logger = {
  ...console,
  debug: () => void 0
};

const entities = [
  BlockDataEntity,
  BlockEntity,
  StakePoolEntity,
  PoolRegistrationEntity,
  PoolRetirementEntity,
  AssetEntity,
  TokensEntity,
  OutputEntity
];
const extensions = {
  pgBoss: true
};

const cardanoNode = new OgmiosObservableCardanoNode(
  {
    connectionConfig$: of({
      port: 1339
    })
  },
  { logger }
);
const buffer = new TypeormStabilityWindowBuffer({ logger });

// #region TypeORM setup

const connectionConfig = {
  database: 'projection',
  host: 'localhost',
  password: 'doNoUseThisSecret!',
  username: 'postgres'
};

const dataSource$ = defer(() =>
  from(
    (async () => {
      const dataSource = createDataSource({
        connectionConfig,
        devOptions: process.argv.includes('--drop')
          ? {
              dropSchema: true,
              synchronize: true
            }
          : undefined,
        entities,
        extensions,
        logger
      });
      await createDatabase({
        options: {
          type: 'postgres',
          ...connectionConfig,
          installExtensions: true
        }
      });
      await dataSource.initialize();
      await buffer.initialize(dataSource.createQueryRunner());
      return dataSource;
    })()
  )
);

// #endregion

Bootstrap.fromCardanoNode({
  buffer,
  cardanoNode,
  logger
})
  .pipe(
    Mappers.withCertificates(),
    Mappers.withStakePools(),
    Mappers.withMint(),
    Mappers.withUtxo(),
    // Single-tenant example
    // Mappers.filterProducedUtxoByAddresses({
    //   addresses: [
    //     'addr_test1qpgn04xka0857kh6859za75tfvlrlu2lft0yc9z87598yjezw8yvpkv977yj5va20xmd9vw5fczfl3uu4expskz8adfqpydths'
    //   ]
    // }),
    shareRetryBackoff(
      (evt$) =>
        evt$.pipe(
          withTypeormTransaction({ dataSource$, logger }, extensions),
          storeBlock(),
          buffer.storeBlockData(),
          storeAssets(),
          storeUtxo(),
          storeStakePools(),
          storeStakePoolMetadataJob(),
          typeormTransactionCommit()
        ),
      { shouldRetry: isRecoverableTypeormError }
    ),
    requestNext(),
    logProjectionProgress(logger)
  )
  .subscribe();
