import * as Postgres from '@cardano-sdk/projection-typeorm';
import { BlockDataEntity, BlockEntity, StakeKeyEntity } from '@cardano-sdk/projection-typeorm';
import {
  Bootstrap,
  ChainSyncEvent,
  ChainSyncEventType,
  ChainSyncRollForward,
  InMemory,
  Mappers,
  ObservableCardanoNode,
  ProjectionEvent,
  ProjectionOperator,
  StabilityWindowBuffer,
  WithBlock,
  requestNext,
  withStaticContext
} from '@cardano-sdk/projection';
import { Cardano, Point, TipOrOrigin } from '@cardano-sdk/core';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { ConnectionConfig } from '@cardano-ogmios/client';
import { Observable, filter, firstValueFrom, lastValueFrom, map, of, take, takeWhile, throwError, toArray } from 'rxjs';
import { OgmiosObservableCardanoNode } from '@cardano-sdk/ogmios';
import { ReconnectionConfig } from '@cardano-sdk/util-rxjs';
import { createDatabase } from 'typeorm-extension';
import { getEnv } from '../../src';

const dataWithStakeDeregistration = chainSyncData(ChainSyncDataSet.WithStakeKeyDeregistration);

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

const createForkProjectionSource = (
  forkFromNode: ObservableCardanoNode,
  lastEvt: WithBlock
): ObservableCardanoNode => ({
  // Same network info
  eraSummaries$: forkFromNode.eraSummaries$,
  genesisParameters$: forkFromNode.genesisParameters$,
  submitTx: () => throwError(() => new Error('Not implemented')),
  // Stub chain sync that forks from provided tip
  // eslint-disable-next-line sort-keys-fix/sort-keys-fix
  findIntersect: (points) => {
    const intersectionPoint = points[0] as Point;
    const someEventsWithStakeRegistration = dataWithStakeDeregistration.allEvents
      .filter(
        (evt): evt is Omit<ChainSyncRollForward, 'requestNext'> =>
          evt.eventType === ChainSyncEventType.RollForward &&
          evt.block.body.some((tx) =>
            tx.body.certificates?.some((cert) => cert.__typename === Cardano.CertificateType.StakeRegistration)
          )
      )
      .slice(0, 2);
    return of({
      chainSync$: new Observable<ChainSyncEvent>((subscriber) => {
        const events = [...someEventsWithStakeRegistration];
        const next = () => {
          const nextEvt = events.shift();
          if (nextEvt) {
            const blockOffset = someEventsWithStakeRegistration.length - events.length;
            const slot = Cardano.Slot(intersectionPoint.slot + blockOffset * 20);
            const blockNo = Cardano.BlockNo(lastEvt.block.header.blockNo + blockOffset);
            subscriber.next({
              ...nextEvt,
              block: {
                ...nextEvt.block,
                header: {
                  ...nextEvt.block.header,
                  blockNo,
                  slot
                }
              },
              requestNext: next
            });
          } else {
            subscriber.complete();
          }
        };
        next();
      }),
      intersection: {
        point: intersectionPoint,
        tip: someEventsWithStakeRegistration[someEventsWithStakeRegistration.length - 1].tip
      }
    });
  },
  healthCheck$: new Observable()
});

const fakeTip = <T extends ProjectionEvent>(evt$: Observable<T>): Observable<T> =>
  evt$.pipe(
    map((evt) => ({
      ...evt,
      tip: evt.block.header
    }))
  );

describe('resuming projection when intersection is not local tip', () => {
  let ogmiosCardanoNode: ObservableCardanoNode;

  beforeAll(async () => {
    ogmiosCardanoNode = new OgmiosObservableCardanoNode({ connectionConfig$: of(ogmiosConnectionConfig) }, { logger });
  });

  const project = (
    cardanoNode: ObservableCardanoNode,
    buffer: StabilityWindowBuffer,
    projectedTip$: Observable<TipOrOrigin>,
    into: ProjectionOperator<Mappers.WithStakeKeys>
  ) =>
    Bootstrap.fromCardanoNode({ blocksBufferLength: 10, buffer, cardanoNode, logger, projectedTip$ }).pipe(
      fakeTip,
      Mappers.withCertificates(),
      Mappers.withStakeKeys(),
      into,
      requestNext()
    );

  const testRollbackAndContinue = (
    buffer: StabilityWindowBuffer,
    tip$: Observable<TipOrOrigin>,
    into: ProjectionOperator<Mappers.WithStakeKeys>,
    getNumberOfLocalStakeKeys: () => Promise<number>
  ) => {
    it('rolls back local data to intersection and resumes projection from there', async () => {
      // Project some events until we find at least 1 stake key registration
      const firstEventWithKeyRegistrations = await firstValueFrom(
        project(ogmiosCardanoNode, buffer, tip$, into).pipe(filter((evt) => evt.stakeKeys.insert.length > 0))
      );
      const lastEventFromOriginalSync = firstEventWithKeyRegistrations;
      const numStakeKeysBeforeFork = await getNumberOfLocalStakeKeys();
      expect(numStakeKeysBeforeFork).toBe(firstEventWithKeyRegistrations.stakeKeys.insert.length); // sanity check

      // Simulate a fork by adding some blocks that are not on the ogmios chain
      const stubForkCardanoNode = createForkProjectionSource(ogmiosCardanoNode, lastEventFromOriginalSync);
      await lastValueFrom(project(stubForkCardanoNode, buffer, tip$, into).pipe(take(4)));
      const numStakeKeysAfterFork = await getNumberOfLocalStakeKeys();
      expect(numStakeKeysAfterFork).toBeGreaterThan(numStakeKeysBeforeFork);

      // Continue projection from ogmios
      const eventsTilStakeKeyRollback = await firstValueFrom(
        project(ogmiosCardanoNode, buffer, tip$, into).pipe(
          takeWhile((evt) => evt.stakeKeys.del.length === 0 && evt.stakeKeys.insert.length === 0, true),
          toArray()
        )
      );

      // Starts sync by rolling back to intersection
      expect(eventsTilStakeKeyRollback[0].eventType).toBe(ChainSyncEventType.RollBackward);
      const stakeKeyRollbackEvent = eventsTilStakeKeyRollback[eventsTilStakeKeyRollback.length - 1];
      expect(stakeKeyRollbackEvent.eventType).toBe(ChainSyncEventType.RollBackward);
      expect(await getNumberOfLocalStakeKeys()).toBe(
        numStakeKeysAfterFork -
          stakeKeyRollbackEvent.stakeKeys.del.length +
          stakeKeyRollbackEvent.stakeKeys.insert.length
      );

      // Continue projection from ogmios
      const firstRollForwardEvent = await lastValueFrom(
        project(ogmiosCardanoNode, buffer, tip$, into).pipe(
          takeWhile((evt) => evt.eventType === ChainSyncEventType.RollBackward, true)
        )
      );
      expect(firstRollForwardEvent.eventType).toBe(ChainSyncEventType.RollForward);
      // Block heights continues from intersection
      expect(firstRollForwardEvent.block.header.blockNo).toEqual(lastEventFromOriginalSync.block.header.blockNo + 1);
    });
  };

  describe('InMemory', () => {
    const store = InMemory.createStore();
    const buffer = new InMemory.InMemoryStabilityWindowBuffer();
    testRollbackAndContinue(
      buffer,
      buffer.tip$,
      (evt$) => evt$.pipe(withStaticContext({ store }), InMemory.storeStakeKeys(), buffer.handleEvents()),
      async () => store.stakeKeys.size
    );
  });

  describe('typeorm', () => {
    const reconnectionConfig: ReconnectionConfig = { initialInterval: 10 };
    const entities = [BlockEntity, BlockDataEntity, StakeKeyEntity];
    const connection$ = Postgres.createObservableConnection({
      connectionConfig$: of(pgConnectionConfig),
      entities,
      logger
    });
    const buffer = new Postgres.TypeormStabilityWindowBuffer({ connection$, logger, reconnectionConfig });
    const tipTracker = Postgres.createTypeormTipTracker({ connection$, reconnectionConfig });
    const dataSource = Postgres.createDataSource({
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

    const getNumberOfLocalStakeKeys = async () => {
      const repository = dataSource.getRepository(Postgres.StakeKeyEntity);
      return repository.count();
    };

    beforeAll(async () => {
      await createDatabase({
        options: {
          type: 'postgres',
          ...pgConnectionConfig,
          installExtensions: true
        }
      });
      await dataSource.initialize();
    });

    afterAll(async () => {
      await dataSource.destroy();
      tipTracker.shutdown();
    });

    testRollbackAndContinue(
      buffer,
      tipTracker.tip$,
      (evt$) =>
        evt$.pipe(
          Postgres.withTypeormTransaction({ connection$ }),
          Postgres.storeBlock(),
          Postgres.storeStakeKeys(),
          buffer.storeBlockData(),
          Postgres.typeormTransactionCommit(),
          tipTracker.trackProjectedTip()
        ),
      getNumberOfLocalStakeKeys
    );
  });
});
