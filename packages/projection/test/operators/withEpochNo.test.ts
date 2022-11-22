import { ChainSyncEventType } from '@cardano-sdk/core';
import { ProjectorEvent, RollForwardEvent, withEpochNo } from '../../src';
import { createTestScheduler } from '@cardano-sdk/util-dev';

const rollForwardEvent = (slot: number) =>
  ({
    block: { header: { slot } },
    eventType: ChainSyncEventType.RollForward
  } as RollForwardEvent);
const eraSummaries = [
  {
    parameters: { epochLength: 432_000, slotLength: 1000 },
    start: { slot: 0, time: new Date(1_595_967_616_000) }
  }
];

describe('withEpochNo', () => {
  it('computes and adds "epochNo" to the events', () => {
    createTestScheduler().run(({ hot, expectObservable, expectSubscriptions }) => {
      const source$ = hot<ProjectorEvent>('abc', {
        a: rollForwardEvent(0),
        b: rollForwardEvent(500_000),
        c: rollForwardEvent(2_000_000)
      });
      expectObservable(source$.pipe(withEpochNo(eraSummaries))).toBe('abc', {
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
