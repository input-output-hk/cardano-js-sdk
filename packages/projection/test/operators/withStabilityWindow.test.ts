import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { ProjectorEvent, withStabilityWindow } from '../../src';
import { createTestScheduler } from '@cardano-sdk/util-dev';

describe('withStabilityWindow', () => {
  it('computes and adds "stabilityWindowSlotsCount" to the events', () => {
    createTestScheduler().run(({ hot, expectObservable, expectSubscriptions }) => {
      const source$ = hot<ProjectorEvent>('a-b', {
        a: {
          eventType: ChainSyncEventType.RollForward
        } as ProjectorEvent,
        b: {
          eventType: ChainSyncEventType.RollBackward
        } as ProjectorEvent
      });
      expectObservable(
        source$.pipe(
          withStabilityWindow({ activeSlotsCoefficient: 0.05, securityParameter: 432 } as Cardano.CompactGenesis)
        )
      ).toBe('-ab', {
        a: {
          eventType: ChainSyncEventType.RollForward,
          stabilityWindowSlotsCount: 25_920
        },
        b: {
          eventType: ChainSyncEventType.RollBackward,
          stabilityWindowSlotsCount: 25_920
        }
      });
      expectSubscriptions(source$.subscriptions).toBe('^');
    });
  });
});
