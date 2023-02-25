/* eslint-disable promise/always-return */
import {
  Cardano,
  ChainSyncEvent,
  ChainSyncEventType,
  ChainSyncRollForward,
  ObservableCardanoNode,
  Point
} from '@cardano-sdk/core';
import { ConnectionConfig } from '@cardano-ogmios/client';
import { InMemory, Projections, projectIntoSink } from '@cardano-sdk/projection';
import { Observable, filter, firstValueFrom, lastValueFrom, of, share, take } from 'rxjs';
import { OgmiosObservableCardanoNode } from '@cardano-sdk/ogmios';
import { dataWithStakeKeyDeregistration } from '../../../projection/test/events';
import { getEnv } from '../../src';
import { logger } from '@cardano-sdk/util-dev';

const connectionConfig = ((): ConnectionConfig => {
  const { OGMIOS_URL } = getEnv(['OGMIOS_URL']);
  const url = new URL(OGMIOS_URL);
  return {
    host: url.hostname,
    port: Number.parseInt(url.port)
  };
})();

const createForkProjectionSource = (forkFromNode: ObservableCardanoNode): ObservableCardanoNode => ({
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
            const slot = Cardano.Slot(
              intersectionPoint.slot + someEventsWithStakeKeyRegistration.length - events.length
            );
            subscriber.next({
              ...nextEvt,
              block: {
                ...nextEvt.block,
                header: {
                  ...nextEvt.block.header,
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
  let stubForkCardanoNode: ObservableCardanoNode;

  beforeAll(async () => {
    ogmiosCardanoNode = new OgmiosObservableCardanoNode({ connectionConfig$: of(connectionConfig) }, { logger });
    stubForkCardanoNode = createForkProjectionSource(ogmiosCardanoNode);
  });

  it('rolls back local data to intersection and resumes projection from there', async () => {
    // Setup projection service
    const store = InMemory.createStore();
    const inMemorySinks = InMemory.createSinks(store);
    const projections = { stakeKeys: Projections.stakeKeys };
    const projectFrom = (cardanoNode: ObservableCardanoNode) =>
      projectIntoSink({
        cardanoNode,
        logger,
        projections,
        sinks: inMemorySinks
      });

    // Project some events until we find at least 1 stake key registration
    const firstEventWithKeyRegistrations = await firstValueFrom(
      projectFrom(ogmiosCardanoNode).pipe(filter((evt) => evt.stakeKeys.register.size > 0))
    );
    const lastEventFromOriginalSync = firstEventWithKeyRegistrations;
    const numStakeKeysBeforeFork = store.stakeKeys.size;
    expect(numStakeKeysBeforeFork).toBe(firstEventWithKeyRegistrations.stakeKeys.register.size); // sanity check

    // Simulate a fork by adding some blocks that are not on the ogmios chain
    await lastValueFrom(projectFrom(stubForkCardanoNode).pipe(take(4)));
    const numStakeKeysAfterFork = store.stakeKeys.size;
    expect(numStakeKeysAfterFork).toBeGreaterThan(numStakeKeysBeforeFork);

    // Continue projection from ogmios
    const continue$ = projectFrom(ogmiosCardanoNode).pipe(share());
    const rollForward$ = continue$.pipe(filter((evt) => evt.eventType === ChainSyncEventType.RollForward));
    const rolledBackKeyRegistrations$ = continue$.pipe(
      filter((evt) => evt.eventType === ChainSyncEventType.RollBackward && evt.stakeKeys.register.size > 0)
    );
    await Promise.all([
      firstValueFrom(continue$).then((firstEvent) => {
        // Starts sync by rolling back to intersection
        expect(firstEvent.eventType).toBe(ChainSyncEventType.RollBackward);
      }),
      firstValueFrom(rolledBackKeyRegistrations$).then((rolledBackKeyRegistrationsEvent) => {
        // Rolls back registrations in store
        expect(store.stakeKeys.size).toBe(
          numStakeKeysAfterFork -
            rolledBackKeyRegistrationsEvent.stakeKeys.register.size +
            rolledBackKeyRegistrationsEvent.stakeKeys.deregister.size
        );
      }),
      firstValueFrom(rollForward$).then((firstRollForwardEvent) => {
        // Block heights continues from intersection
        expect(firstRollForwardEvent.block.header.blockNo).toEqual(lastEventFromOriginalSync.block.header.blockNo + 1);
        // State continues from intersection
        expect(store.stakeKeys.size).toBe(
          numStakeKeysBeforeFork +
            firstRollForwardEvent.stakeKeys.register.size -
            firstRollForwardEvent.stakeKeys.deregister.size
        );
      })
    ]);
  });
});
