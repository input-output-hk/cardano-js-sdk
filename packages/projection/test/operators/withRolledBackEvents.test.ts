import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import {
  InsufficientEventCacheError,
  RollBackwardEvent,
  RollForwardEvent,
  WithStabilityWindow,
  withRolledBackEvents
} from '../../src';
import { createTestScheduler } from '@cardano-sdk/util-dev';

describe('withRolledBackEvents', () => {
  const stabilityWindowSlotsCount = 2;
  const blockId = Cardano.BlockId('0000000000000000000000000000000000000000000000000000000000000000');
  const rollForwardEvent = (slot: number, hash?: Cardano.BlockId, blockNo = slot) =>
    ({
      block: { header: { blockNo, hash, slot } },
      eventType: ChainSyncEventType.RollForward,
      stabilityWindowSlotsCount,
      tip: { slot }
    } as RollForwardEvent<WithStabilityWindow>);
  const rollBackwardEvent = (slot: number, hash: Cardano.BlockId, blockNo = slot) =>
    ({
      eventType: ChainSyncEventType.RollBackward,
      stabilityWindowSlotsCount,
      tip: { blockNo, hash, slot }
    } as RollBackwardEvent<WithStabilityWindow>);

  describe('without evtCache$', () => {
    it('adds "rolledBackEvents" to the events', () => {
      createTestScheduler().run(({ hot, expectObservable, expectSubscriptions }) => {
        const source$ = hot('a-bcde', {
          a: rollForwardEvent(0),
          b: rollForwardEvent(1, blockId),
          c: rollForwardEvent(2),
          d: rollForwardEvent(3),
          e: rollBackwardEvent(1, blockId)
        });
        expectObservable(source$.pipe(withRolledBackEvents())).toBe('-abcde', {
          a: rollForwardEvent(0),
          b: rollForwardEvent(1, blockId),
          c: rollForwardEvent(2),
          d: rollForwardEvent(3),
          e: {
            ...rollBackwardEvent(1, blockId),
            rolledBackEvents: [rollForwardEvent(3), rollForwardEvent(2)]
          }
        });
        expectSubscriptions(source$.subscriptions).toBe('^');
      });
    });
  });

  describe('with evtCache$', () => {
    it('adds "rolledBackEvents" that includes events from supplied evtCache$', () => {
      createTestScheduler().run(({ cold, hot, expectObservable, expectSubscriptions }) => {
        const evtCache$ = cold('a-bc|', {
          a: rollForwardEvent(0),
          b: rollForwardEvent(1, blockId),
          c: rollForwardEvent(2)
        });
        const source$ = hot('de', {
          d: rollForwardEvent(3),
          e: rollBackwardEvent(1, blockId)
        });
        expectObservable(source$.pipe(withRolledBackEvents(evtCache$))).toBe('-----(de)', {
          d: rollForwardEvent(3),
          e: {
            ...rollBackwardEvent(1, blockId),
            rolledBackEvents: [rollForwardEvent(3), rollForwardEvent(2)]
          }
        });
        expectSubscriptions(source$.subscriptions).toBe('^');
      });
    });

    it('errors if evtCache$ doesnt have events within the rollback', () => {
      createTestScheduler().run(({ cold, hot, expectObservable, expectSubscriptions }) => {
        const evtCache$ = cold('a-b|', {
          a: rollForwardEvent(0),
          b: rollForwardEvent(1, blockId)
        });
        const source$ = hot('de', {
          d: rollForwardEvent(3),
          e: rollBackwardEvent(1, blockId)
        });
        expectObservable(source$.pipe(withRolledBackEvents(evtCache$))).toBe(
          '----(d#)',
          {
            d: rollForwardEvent(3)
          },
          new InsufficientEventCacheError()
        );
        expectSubscriptions(source$.subscriptions).toBe('^---!');
      });
    });
  });
});
