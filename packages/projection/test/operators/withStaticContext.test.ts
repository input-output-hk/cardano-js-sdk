import { ChainSyncEventType } from '@cardano-sdk/core';
import { ProjectorEvent, withStaticContext } from '../../src';
import { createTestScheduler } from '@cardano-sdk/util-dev';

describe('withStaticContext', () => {
  describe('with observable context', () => {
    it('adds last emitted context to every event', () => {
      createTestScheduler().run(({ hot, expectObservable, expectSubscriptions }) => {
        const context$ = hot('a-b', {
          a: { ctx: 'a' },
          b: { ctx: 'b' }
        });
        const source$ = hot<ProjectorEvent>('a--b', {
          a: {
            eventType: ChainSyncEventType.RollForward
          } as ProjectorEvent,
          b: {
            eventType: ChainSyncEventType.RollBackward
          } as ProjectorEvent
        });
        expectObservable(source$.pipe(withStaticContext(context$))).toBe('a--b', {
          a: {
            ctx: 'a',
            eventType: ChainSyncEventType.RollForward
          },
          b: {
            ctx: 'b',
            eventType: ChainSyncEventType.RollBackward
          }
        });
        expectSubscriptions(source$.subscriptions).toBe('^');
        expectSubscriptions(context$.subscriptions).toBe('^');
      });
    });
  });

  describe('with non-observable context', () => {
    it('adds context to every event', () => {
      createTestScheduler().run(({ hot, expectObservable, expectSubscriptions }) => {
        const context = { ctx: 'a' };
        const source$ = hot<ProjectorEvent>('a--b', {
          a: {
            eventType: ChainSyncEventType.RollForward
          } as ProjectorEvent,
          b: {
            eventType: ChainSyncEventType.RollBackward
          } as ProjectorEvent
        });
        expectObservable(source$.pipe(withStaticContext(context))).toBe('a--b', {
          a: {
            ctx: 'a',
            eventType: ChainSyncEventType.RollForward
          },
          b: {
            ctx: 'a',
            eventType: ChainSyncEventType.RollBackward
          }
        });
        expectSubscriptions(source$.subscriptions).toBe('^');
      });
    });
  });
});
