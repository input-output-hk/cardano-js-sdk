import { ChainSyncEventType } from '@cardano-sdk/core';
import { Operators, ProjectorEvent } from '../../src';
import { createTestScheduler } from '@cardano-sdk/util-dev';

describe('withEventContext', () => {
  describe('with observable context', () => {
    it('creates and adds context to every event', () => {
      createTestScheduler().run(({ cold, hot, expectObservable, expectSubscriptions, flush }) => {
        const createContext = jest.fn(() =>
          cold('a', {
            a: { ctx: 'a' }
          })
        );
        const source$ = hot<ProjectorEvent>('a--b', {
          a: {
            eventType: ChainSyncEventType.RollForward
          } as ProjectorEvent,
          b: {
            eventType: ChainSyncEventType.RollBackward
          } as ProjectorEvent
        });
        expectObservable(source$.pipe(Operators.withEventContext(createContext))).toBe('a--b', {
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
        const source$ = hot<ProjectorEvent>('a--b', {
          a: {
            eventType: ChainSyncEventType.RollForward
          } as ProjectorEvent,
          b: {
            eventType: ChainSyncEventType.RollBackward
          } as ProjectorEvent
        });
        expectObservable(source$.pipe(Operators.withEventContext(createContext))).toBe('a--b', {
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
