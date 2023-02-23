import {
  CardanoNodeErrors,
  ChainSyncEvent,
  ChainSyncEventType,
  ObservableCardanoNode,
  Point,
  PointOrOrigin
} from '@cardano-sdk/core';
import { ChainSyncData } from '../../../golden-test-generator/src';
import { Observable, of } from 'rxjs';
import { SerializedChainSyncEvent } from '../../../golden-test-generator/src/ChainSyncEvents';
import { genesisToEraSummary } from './genesisToEraSummary';

const intersect = (events: ChainSyncData['body'], points: PointOrOrigin[]) => {
  const blockPoints = points.filter((point): point is Point => point !== 'origin');
  if (blockPoints.length === 0) {
    if (points.length === 0) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      throw new CardanoNodeErrors.CardanoClientErrors.IntersectionNotFoundError(points as any[]);
    }
    return {
      events,
      intersection: {
        point: 'origin' as const,
        tip: events[0].tip
      }
    };
  }
  const remainingEvents = [...events];
  let eventsSinceIntersection: SerializedChainSyncEvent[] = [];
  let evt: ChainSyncData['body'][0] | undefined;
  while ((evt = remainingEvents.pop())) {
    if (evt.eventType !== ChainSyncEventType.RollForward) {
      eventsSinceIntersection = [evt, ...eventsSinceIntersection];
      continue;
    }
    const {
      block: { header }
    } = evt;
    const point = blockPoints.find(({ hash }) => header.hash === hash);
    if (point) {
      return {
        events: eventsSinceIntersection,
        intersection: {
          point,
          tip:
            eventsSinceIntersection.length > 0
              ? eventsSinceIntersection[eventsSinceIntersection.length - 1].tip
              : header
        }
      };
    }
    eventsSinceIntersection = [evt, ...eventsSinceIntersection];
  }
  if (points.includes('origin')) {
    return {
      events,
      intersection: {
        point: 'origin' as const,
        tip: events[0].tip
      }
    };
  }
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  throw new CardanoNodeErrors.CardanoClientErrors.IntersectionNotFoundError(points as any[]);
};

const prepareData = (dataFileName: string) => {
  const {
    body: allEvents,
    metadata: {
      cardano: { compactGenesis }
    }
  } = require(`./data/${dataFileName}`) as ChainSyncData;
  const eraSummaries = [genesisToEraSummary(compactGenesis)];
  const cardanoNode: ObservableCardanoNode = {
    eraSummaries$: of(eraSummaries),
    findIntersect: (points) => {
      const { intersection, events } = intersect(allEvents, points);
      return of({
        chainSync$: new Observable<ChainSyncEvent>((subscriber) => {
          const remainingEvents = [...events];
          const requestNext = () => {
            const nextEvent = remainingEvents.shift();
            if (nextEvent) {
              subscriber.next({
                ...nextEvent,
                requestNext: () => setTimeout(requestNext, 1)
              });
            } else {
              subscriber.complete();
            }
          };
          requestNext();
        }),
        intersection
      });
    },
    genesisParameters$: of(compactGenesis)
  };
  return {
    allEvents,
    cardanoNode,
    networkInfo: {
      eraSummaries,
      genesisParameters: compactGenesis
    }
  };
};
export type StubChainSyncData = ReturnType<typeof prepareData>;

export const dataWithPoolRetirement = prepareData('with-pool-retirement.json');
export const dataWithStakeKeyDeregistration = prepareData('with-stake-key-deregistration');
