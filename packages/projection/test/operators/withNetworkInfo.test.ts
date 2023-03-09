import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { ChainSyncDataSet, chainSyncData, createTestScheduler } from '@cardano-sdk/util-dev';
import { Operators, RollForwardEvent, UnifiedProjectorEvent } from '../../src';

const { networkInfo, cardanoNode } = chainSyncData(ChainSyncDataSet.WithPoolRetirement);

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
      expectObservable(source$.pipe(Operators.withNetworkInfo(cardanoNode))).toBe('ab', {
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
