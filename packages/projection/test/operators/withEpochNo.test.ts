import { Cardano } from '@cardano-sdk/core';
import {
  ChainSyncEventType,
  RollForwardEvent,
  UnifiedExtChainSyncEvent,
  WithNetworkInfo,
  withEpochNo
} from '../../src';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { stubEraSummaries } from '../util';

const rollForwardEvent = (slot: number) =>
  ({
    block: { header: { slot: Cardano.Slot(slot) } },
    eraSummaries: stubEraSummaries,
    eventType: ChainSyncEventType.RollForward
  } as RollForwardEvent<WithNetworkInfo>);

describe('withEpochNo', () => {
  it('computes and adds "epochNo" to the events', () => {
    createTestScheduler().run(({ hot, expectObservable, expectSubscriptions }) => {
      const source$ = hot<UnifiedExtChainSyncEvent<WithNetworkInfo>>('abc', {
        a: rollForwardEvent(0),
        b: rollForwardEvent(500_000),
        c: rollForwardEvent(2_000_000)
      });
      expectObservable(source$.pipe(withEpochNo())).toBe('abc', {
        a: {
          ...rollForwardEvent(0),
          epochNo: 0
        },
        b: {
          ...rollForwardEvent(500_000),
          epochNo: 1
        },
        c: {
          ...rollForwardEvent(2_000_000),
          epochNo: 4
        }
      });
      expectSubscriptions(source$.subscriptions).toBe('^');
    });
  });
});
