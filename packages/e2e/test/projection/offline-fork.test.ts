/* eslint-disable promise/always-return */
import * as Postgres from '@cardano-sdk/projection-typeorm';
import {
  Cardano,
  ChainSyncEvent,
  ChainSyncEventType,
  ChainSyncRollForward,
  ObservableCardanoNode,
  Point
} from '@cardano-sdk/core';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { ConnectionConfig } from '@cardano-ogmios/client';
import { InMemory, Projections, SinksFactory, WithBlock, projectIntoSink } from '@cardano-sdk/projection';
import { Observable, filter, firstValueFrom, lastValueFrom, of, share, take } from 'rxjs';
import { OgmiosObservableCardanoNode } from '@cardano-sdk/ogmios';
import { createDatabase } from 'typeorm-extension';
import { getEnv } from '../../src';

const dataWithStakeKeyDeregistration = chainSyncData(ChainSyncDataSet.WithStakeKeyDeregistration);

const ogmiosConnectionConfig = ((): ConnectionConfig => {
  const { OGMIOS_URL } = getEnv(['OGMIOS_URL']);
  const url = new URL(OGMIOS_URL);
  return {
    host: url.hostname,
    port: Number.parseInt(url.port)
  };
})();

// const { PROJECTION_PG_CONNECTION_STRING } = getEnv(['PROJECTION_PG_CONNECTION_STRING']);
const pgConnectionConfig = ((): Postgres.PgConnectionConfig => {
  const { PROJECTION_PG_CONNECTION_STRING } = getEnv(['PROJECTION_PG_CONNECTION_STRING']);
  // postgresql://postgres:doNoUseThisSecret!@localhost:5435/projection
  const withoutProtocol = PROJECTION_PG_CONNECTION_STRING.split('://')[1];
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
  // Stub chain sync that forks from provided tip
  // eslint-disable-next-line sort-keys-fix/sort-keys-fix
  findIntersect: (points) => {
    const intersectionPoint = points[0] as Point;
    const someEventsWithStakeKeyRegistration = dataWithStakeKeyDeregistration.allEvents
      .filter(
        (evt): evt is Omit<ChainSyncRollForward, 'requestNext'> =>
          evt.eventType === ChainSyncEventType.RollForward &&
          evt.block.body.some((tx) =>
            tx.body.certificates?.some((cert) => cert.__typename === Cardano.CertificateType.StakeKeyRegistration)
          )
      )
      .slice(0, 2);
    return of({
      chainSync$: new Observable<ChainSyncEvent>((subscriber) => {
        const events = [...someEventsWithStakeKeyRegistration];
        const requestNext = () => {
          const nextEvt = events.shift();
          if (nextEvt) {
            const blockOffset = someEventsWithStakeKeyRegistration.length - events.length;
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
              requestNext
            });
          } else {
            subscriber.complete();
          }
        };
        requestNext();
      }),
      intersection: {
        point: intersectionPoint,
        tip: someEventsWithStakeKeyRegistration[someEventsWithStakeKeyRegistration.length - 1].tip
      }
    });
  }
});

describe('resuming projection when intersection is not local tip', () => {
  let ogmiosCardanoNode: ObservableCardanoNode;
  const projections = { stakeKeys: Projections.stakeKeys };

  beforeAll(async () => {
    ogmiosCardanoNode = new OgmiosObservableCardanoNode({ connectionConfig$: of(ogmiosConnectionConfig) }, { logger });
  });

  const project = (cardanoNode: ObservableCardanoNode, sinksFactory: SinksFactory<typeof projections>) =>
    projectIntoSink({
      cardanoNode,
      logger,
      projections,
      sinksFactory
    });

  const testRollbackAndContinue = (
    sinksFactory: SinksFactory<typeof projections>,
    getNumberOfLocalStakeKeys: () => Promise<number>
  ) => {
    it('rolls back local data to intersection and resumes projection from there', async () => {
      // Project some events until we find at least 1 stake key registration
      const firstEventWithKeyRegistrations = await firstValueFrom(
        project(ogmiosCardanoNode, sinksFactory).pipe(filter((evt) => evt.stakeKeys.insert.length > 0))
      );
      const lastEventFromOriginalSync = firstEventWithKeyRegistrations;
      const numStakeKeysBeforeFork = await getNumberOfLocalStakeKeys();
      expect(numStakeKeysBeforeFork).toBe(firstEventWithKeyRegistrations.stakeKeys.insert.length); // sanity check

      // Simulate a fork by adding some blocks that are not on the ogmios chain
      const stubForkCardanoNode = createForkProjectionSource(ogmiosCardanoNode, lastEventFromOriginalSync);
      await lastValueFrom(project(stubForkCardanoNode, sinksFactory).pipe(take(4)));
      const numStakeKeysAfterFork = await getNumberOfLocalStakeKeys();
      expect(numStakeKeysAfterFork).toBeGreaterThan(numStakeKeysBeforeFork);

      // Continue projection from ogmios
      const continue$ = project(ogmiosCardanoNode, sinksFactory).pipe(share());
      const rollForward$ = continue$.pipe(filter((evt) => evt.eventType === ChainSyncEventType.RollForward));
      const rolledBackKeyRegistrations$ = continue$.pipe(
        filter(
          (evt) =>
            evt.eventType === ChainSyncEventType.RollBackward &&
            // Test was flaky when checking only `del.length`,
            // because then it could be skipping some events that affect total # of stake pools
            (evt.stakeKeys.del.length > 0 || evt.stakeKeys.insert.length > 0)
        )
      );
      await Promise.all([
        firstValueFrom(continue$).then((firstEvent) => {
          // Starts sync by rolling back to intersection
          expect(firstEvent.eventType).toBe(ChainSyncEventType.RollBackward);
        }),
        firstValueFrom(rolledBackKeyRegistrations$).then(async (rolledBackKeyRegistrationsEvent) => {
          // Rolls back registrations in store
          expect(await getNumberOfLocalStakeKeys()).toBe(
            numStakeKeysAfterFork -
              rolledBackKeyRegistrationsEvent.stakeKeys.del.length +
              rolledBackKeyRegistrationsEvent.stakeKeys.insert.length
          );
        }),
        firstValueFrom(rollForward$).then(async (firstRollForwardEvent) => {
          // Block heights continues from intersection
          expect(firstRollForwardEvent.block.header.blockNo).toEqual(
            lastEventFromOriginalSync.block.header.blockNo + 1
          );
          // State continues from intersection
          expect(await getNumberOfLocalStakeKeys()).toBe(
            numStakeKeysBeforeFork +
              firstRollForwardEvent.stakeKeys.insert.length -
              firstRollForwardEvent.stakeKeys.del.length
          );
        })
      ]);
    });
  };

  describe('InMemory', () => {
    const store = InMemory.createStore();
    const sinks = InMemory.createSinks(store);
    testRollbackAndContinue(
      () => sinks,
      async () => store.stakeKeys.size
    );
  });

  describe('typeorm', () => {
    const dataSource = Postgres.createDataSource({
      connectionConfig: pgConnectionConfig,
      devOptions: {
        dropSchema: true,
        synchronize: true
      },
      logger,
      options: {
        installExtensions: true
      },
      projections
    });
    const sinksFactory = Postgres.createSinksFactory({
      dataSource$: of(dataSource),
      logger
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
    afterAll(() => dataSource.destroy());

    testRollbackAndContinue(sinksFactory, getNumberOfLocalStakeKeys);
  });
});
