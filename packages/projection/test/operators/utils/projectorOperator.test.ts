import { ChainSyncEventType, ExtChainSyncEvent, ProjectorEventHandlers, projectorOperator } from '../../../src';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { of } from 'rxjs';

describe('projectorOperator', () => {
  // eslint-disable-next-line unicorn/consistent-function-scoping
  const testProjectorOperator = (handlers: ProjectorEventHandlers<unknown, unknown>) => {
    createTestScheduler().run(({ hot, expectObservable, expectSubscriptions }) => {
      const source$ = hot<ExtChainSyncEvent>('ab', {
        a: {
          eventType: ChainSyncEventType.RollForward
        } as ExtChainSyncEvent,
        b: {
          eventType: ChainSyncEventType.RollBackward
        } as ExtChainSyncEvent
      });
      expectObservable(source$.pipe(projectorOperator(handlers)())).toBe('ab', {
        a: {
          eventType: ChainSyncEventType.RollForward,
          someProp: true
        },
        b: {
          eventType: ChainSyncEventType.RollBackward,
          someProp: false
        }
      });
      expectSubscriptions(source$.subscriptions).toBe('^');
    });
  };

  it('can be used to add a synchronous handler', () => {
    testProjectorOperator({
      rollBackward: (e) => ({ ...e, someProp: false }),
      rollForward: (e) => ({ ...e, someProp: true })
    });
  });

  it('can be used to add an asynchronous handler', () => {
    testProjectorOperator({
      rollBackward: (e) => of({ ...e, someProp: false }),
      rollForward: (e) => of({ ...e, someProp: true })
    });
  });
});
