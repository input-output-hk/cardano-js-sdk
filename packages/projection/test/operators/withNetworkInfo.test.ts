import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { Operators, RollForwardEvent, UnifiedProjectorEvent } from '../../src';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { dataWithPoolRetirement } from '../events';

const networkInfo = dataWithPoolRetirement.networkInfo;

const createEvent = (eventType: ChainSyncEventType) =>
  ({
    block: { header: { slot: Cardano.Slot(123) } },
    eventType
  } as RollForwardEvent<Operators.WithNetworkInfo>);

describe('withNetworkInfo', () => {
  it('adds "eraSummaries" and "genesisParameters" to each event', () => {
    createTestScheduler().run(({ hot, expectObservable, expectSubscriptions }) => {
      const source$ = hot<UnifiedProjectorEvent<Operators.WithNetworkInfo>>('ab', {
        a: createEvent(ChainSyncEventType.RollForward),
        b: createEvent(ChainSyncEventType.RollBackward)
      });
      expectObservable(source$.pipe(Operators.withNetworkInfo(dataWithPoolRetirement.cardanoNode))).toBe('ab', {
        a: {
          ...createEvent(ChainSyncEventType.RollForward),
          eraSummaries: networkInfo.eraSummaries,
          genesisParameters: networkInfo.genesisParameters
        },
        b: {
          ...createEvent(ChainSyncEventType.RollBackward),
          eraSummaries: networkInfo.eraSummaries,
          genesisParameters: networkInfo.genesisParameters
        }
      });
      expectSubscriptions(source$.subscriptions).toBe('^');
    });
  });
});
