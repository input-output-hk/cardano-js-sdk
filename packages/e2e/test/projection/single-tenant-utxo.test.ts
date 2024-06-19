import * as Postgres from '@cardano-sdk/projection-typeorm';
import { Bootstrap, Mappers, ProjectionEvent, requestNext } from '@cardano-sdk/projection';
import { Cardano, ObservableCardanoNode } from '@cardano-sdk/core';
import { ConnectionConfig } from '@cardano-ogmios/client';
import { DataSource, QueryRunner } from 'typeorm';
import { Observable, filter, firstValueFrom, lastValueFrom, of, scan, takeWhile } from 'rxjs';
import { OgmiosObservableCardanoNode } from '@cardano-sdk/ogmios';
import { ReconnectionConfig } from '@cardano-sdk/util-rxjs';
import { createDatabase, dropDatabase } from 'typeorm-extension';
import { getEnv } from '../../src';
import { logger } from '@cardano-sdk/util-dev';

const entities = [
  Postgres.BlockEntity,
  Postgres.BlockDataEntity,
  Postgres.AssetEntity,
  Postgres.TokensEntity,
  Postgres.OutputEntity,
  Postgres.NftMetadataEntity
];

const ogmiosConnectionConfig = ((): ConnectionConfig => {
  const { OGMIOS_URL } = getEnv(['OGMIOS_URL']);
  const url = new URL(OGMIOS_URL);
  return {
    host: url.hostname,
    port: Number.parseInt(url.port)
  };
})();

const pgConnectionConfig = ((): Postgres.PgConnectionConfig => {
  const { STAKE_POOL_TEST_CONNECTION_STRING } = getEnv(['STAKE_POOL_TEST_CONNECTION_STRING']);
  const withoutProtocol = STAKE_POOL_TEST_CONNECTION_STRING.split('://')[1];
  const [credentials, hostPortDb] = withoutProtocol.split('@');
  const [username, password] = credentials.split(':');
  const [hostPort, database] = hostPortDb.split('/');
  const [host, port] = hostPort.split(':');
  return {
    database,
    host,
    password,
    port: Number.parseInt(port),
    username
  };
})();

const createDataSource = () =>
  Postgres.createDataSource({
    connectionConfig: pgConnectionConfig,
    devOptions: {
      dropSchema: true,
      synchronize: true
    },
    entities,
    logger,
    options: {
      installExtensions: true
    }
  });

const databaseOptions = {
  options: {
    type: 'postgres' as const,
    ...pgConnectionConfig,
    installExtensions: true
  }
};

const countUniqueOutputAddresses = (queryRunner: QueryRunner) =>
  queryRunner.manager
    .createQueryBuilder(Postgres.OutputEntity, 'output')
    .select('output.address', 'address')
    .distinct(true)
    .getRawMany()
    .then((results) => results.length);

describe.skip('single-tenant utxo projection', () => {
  let cardanoNode: ObservableCardanoNode;
  let connection$: Observable<Postgres.TypeormConnection>;
  let buffer: Postgres.TypeormStabilityWindowBuffer;
  let tipTracker: Postgres.TypeormTipTracker;
  let queryRunner: QueryRunner;
  let dataSource: DataSource;

  const initialize = async () => {
    await createDatabase(databaseOptions);
    dataSource = createDataSource();
    await dataSource.initialize();
    queryRunner = dataSource.createQueryRunner('slave');
    connection$ = Postgres.createObservableConnection({
      connectionConfig$: of(pgConnectionConfig),
      entities,
      logger
    });
    const reconnectionConfig: ReconnectionConfig = { initialInterval: 10 };
    buffer = new Postgres.TypeormStabilityWindowBuffer({ connection$, logger, reconnectionConfig });
    tipTracker = Postgres.createTypeormTipTracker({ connection$, reconnectionConfig });
  };

  const cleanup = async () => {
    await queryRunner.release();
    await dataSource.destroy();
  };

  beforeEach(async () => {
    cardanoNode = new OgmiosObservableCardanoNode({ connectionConfig$: of(ogmiosConnectionConfig) }, { logger });
    await initialize();
  });

  afterEach(async () => cleanup());

  const storeUtxo = (evt$: Observable<ProjectionEvent<Mappers.WithMint & Mappers.WithUtxo>>) =>
    evt$.pipe(
      Postgres.withTypeormTransaction({ connection$ }),
      Postgres.storeBlock(),
      Postgres.storeAssets(),
      Postgres.storeUtxo(),
      buffer.storeBlockData(),
      Postgres.typeormTransactionCommit()
    );

  const projectMultiTenant = () =>
    Bootstrap.fromCardanoNode({
      blocksBufferLength: 10,
      buffer,
      cardanoNode,
      logger,
      projectedTip$: tipTracker.tip$
    }).pipe(Mappers.withMint(), Mappers.withUtxo(), storeUtxo, requestNext(), tipTracker.trackProjectedTip());

  const projectSingleTenant = (addresses: Cardano.PaymentAddress[]) =>
    Bootstrap.fromCardanoNode({
      blocksBufferLength: 10,
      buffer,
      cardanoNode,
      logger,
      projectedTip$: tipTracker.tip$
    }).pipe(
      Mappers.withMint(),
      Mappers.withUtxo(),
      Mappers.filterProducedUtxoByAddresses({ addresses }),
      storeUtxo,
      tipTracker.trackProjectedTip(),
      requestNext()
    );

  it('Mappers.filterProducedUtxoByAddresses can be used to produce a single-tenant utxo database', async () => {
    // Project some events until we find at least 1 stake key registration
    const { block: multiAddressDbBlock, addresses: uniqueAddresses } = await firstValueFrom(
      projectMultiTenant().pipe(
        scan(
          ({ addresses }, { block, utxo }) => {
            for (const [_, txOut] of utxo.produced) {
              addresses.add(txOut.address);
            }
            return { addresses, block };
          },
          {
            addresses: new Set<Cardano.PaymentAddress>(),
            block: null as unknown as Cardano.Block
          }
        ),
        filter(({ addresses }) => addresses.size > 1)
      )
    );
    expect(uniqueAddresses.size).toBeGreaterThan(1);
    expect(await countUniqueOutputAddresses(queryRunner)).toBe(uniqueAddresses.size);
    await cleanup();
    await dropDatabase(databaseOptions);
    await initialize();
    // project utxo of only 1 address til block after which we
    // previously had more than 1 address
    const addresses = [...uniqueAddresses.values()].slice(0, 1);
    await lastValueFrom(
      projectSingleTenant(addresses).pipe(
        takeWhile((evt) => evt.block.header.hash !== multiAddressDbBlock.header.hash, true)
      )
    );
    expect(await countUniqueOutputAddresses(queryRunner)).toBe(1);
  });
});
