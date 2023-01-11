import { Cardano, ChainSyncEventType, ChainSyncRollBackward } from '@cardano-sdk/core';
import { UnifiedProjectorEvent, operators, sinks } from '../../src';
import { concatMap, defaultIfEmpty, map } from 'rxjs';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { dataWithStakeKeyDeregistration } from '../events';
import { stubBlockId } from '../util';

const createEvent = (eventType: ChainSyncEventType, slot: number, tipSlot = slot) =>
  ({
    block: { header: { blockNo: Cardano.BlockNo(slot), hash: stubBlockId(slot), slot: Cardano.Slot(slot) } },
    eventType,
    requestNext: expect.anything(),
    tip: { blockNo: Cardano.BlockNo(tipSlot), hash: stubBlockId(tipSlot), slot: Cardano.Slot(tipSlot) }
  } as UnifiedProjectorEvent<{}>);

const sourceRollback = (slot: number) =>
  ({
    eventType: ChainSyncEventType.RollBackward,
    requestNext: jest.fn(),
    tip: { blockNo: Cardano.BlockNo(slot), hash: stubBlockId(slot), slot: Cardano.Slot(slot) }
  } as ChainSyncRollBackward);

describe('withRolledBackBlocks', () => {
  let buffer: sinks.StabilityWindowBuffer;

  const manageBuffer = () =>
    concatMap((evt: UnifiedProjectorEvent<{}>) =>
      sinks.manageBuffer<{}>(evt, buffer).pipe(
        defaultIfEmpty(null),
        map(() => evt)
      )
    );

  beforeEach(() => {
    buffer = new sinks.InMemoryStabilityWindowBuffer(dataWithStakeKeyDeregistration.networkInfo);
  });

  it('re-emits rolled back blocks one by one and calls requestNext on original event', () => {
    createTestScheduler().run(({ hot, expectObservable, expectSubscriptions, flush }) => {
      const originalRollbackEvent = sourceRollback(1);
      const source$ = hot('abcde', {
        a: createEvent(ChainSyncEventType.RollForward, 0),
        b: createEvent(ChainSyncEventType.RollForward, 1),
        c: createEvent(ChainSyncEventType.RollForward, 2),
        d: createEvent(ChainSyncEventType.RollForward, 3),
        e: originalRollbackEvent
      });
      expectObservable(source$.pipe(operators.withRolledBackBlock(buffer), manageBuffer())).toBe('abcd(ef)', {
        a: createEvent(ChainSyncEventType.RollForward, 0),
        b: createEvent(ChainSyncEventType.RollForward, 1),
        c: createEvent(ChainSyncEventType.RollForward, 2),
        d: createEvent(ChainSyncEventType.RollForward, 3),
        e: createEvent(ChainSyncEventType.RollBackward, 3, 1),
        f: createEvent(ChainSyncEventType.RollBackward, 2, 1)
      });
      expectSubscriptions(source$.subscriptions).toBe('^');
      flush();
      expect(originalRollbackEvent.requestNext).toBeCalledTimes(1);
    });
  });
});
