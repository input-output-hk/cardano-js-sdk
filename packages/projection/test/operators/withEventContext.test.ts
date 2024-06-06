import { ChainSyncEventType } from '@cardano-sdk/core';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { withEventContext } from '../../src/index.js';
import type { ExtChainSyncEvent } from '../../src/index.js';

describe('withEventContext', () => {
  describe('with observable context', () => {
    it('creates and adds context to every event', () => {
      createTestScheduler().run(({ cold, hot, expectObservable, expectSubscriptions, flush }) => {
        const createContext = jest.fn(() =>
          cold('a', {
            a: { ctx: 'a' }
          })
        );
        const source$ = hot<ExtChainSyncEvent>('a--b', {
          a: {
            eventType: ChainSyncEventType.RollForward
          } as ExtChainSyncEvent,
          b: {
            eventType: ChainSyncEventType.RollBackward
          } as ExtChainSyncEvent
        });
        expectObservable(source$.pipe(withEventContext(createContext))).toBe('a--b', {
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
        flush();
        expect(createContext).toBeCalledTimes(2);
      });
    });
  });

  describe('with non-observable context', () => {
    it('creates and adds context to every event', () => {
      createTestScheduler().run(({ hot, expectObservable, expectSubscriptions, flush }) => {
        const createContext = jest.fn(() => ({ ctx: 'a' }));
        const source$ = hot<ExtChainSyncEvent>('a--b', {
          a: {
            eventType: ChainSyncEventType.RollForward
          } as ExtChainSyncEvent,
          b: {
            eventType: ChainSyncEventType.RollBackward
          } as ExtChainSyncEvent
        });
        expectObservable(source$.pipe(withEventContext(createContext))).toBe('a--b', {
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
        flush();
        expect(createContext).toBeCalledTimes(2);
      });
    });
  });
});
