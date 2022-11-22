import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { RollForwardEvent, UnifiedProjectorEvent, operators } from '../../src';
import { createTestScheduler } from '@cardano-sdk/util-dev';

const eraSummaries = [
  {
    parameters: { epochLength: 432_000, slotLength: 1000 },
    start: { slot: 0, time: new Date(1_595_967_616_000) }
  }
];
const rollForwardEvent = (slot: number) =>
  ({
    block: { header: { slot: Cardano.Slot(slot) } },
    eraSummaries,
    eventType: ChainSyncEventType.RollForward
  } as RollForwardEvent<operators.WithNetworkInfo>);

describe('withEpochNo', () => {
  it('computes and adds "epochNo" to the events', () => {
    createTestScheduler().run(({ hot, expectObservable, expectSubscriptions }) => {
      const source$ = hot<UnifiedProjectorEvent<operators.WithNetworkInfo>>('abc', {
        a: rollForwardEvent(0),
        b: rollForwardEvent(500_000),
        c: rollForwardEvent(2_000_000)
      });
      expectObservable(source$.pipe(operators.withEpochNo())).toBe('abc', {
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
