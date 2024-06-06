import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { stubEraSummaries } from '../util.js';
import { withEpochNo } from '../../src/index.js';
import type { RollForwardEvent, UnifiedExtChainSyncEvent, WithNetworkInfo } from '../../src/index.js';

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
