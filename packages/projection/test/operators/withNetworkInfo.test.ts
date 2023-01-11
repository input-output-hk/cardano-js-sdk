import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { RollForwardEvent, UnifiedProjectorEvent, operators } from '../../src';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { dataWithPoolRetirement } from '../events';

const networkInfo = dataWithPoolRetirement.networkInfo;

const createEvent = (eventType: ChainSyncEventType) =>
  ({
    block: { header: { slot: Cardano.Slot(123) } },
    eventType
  } as RollForwardEvent<operators.WithNetworkInfo>);

describe('withNetworkInfo', () => {
  it('adds "eraSummaries" and "genesisParameters" to each event', () => {
    createTestScheduler().run(({ hot, expectObservable, expectSubscriptions }) => {
      const source$ = hot<UnifiedProjectorEvent<operators.WithNetworkInfo>>('ab', {
        a: createEvent(ChainSyncEventType.RollForward),
        b: createEvent(ChainSyncEventType.RollBackward)
      });
      expectObservable(source$.pipe(operators.withNetworkInfo(networkInfo))).toBe('ab', {
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
