import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { ChainSyncDataSet, chainSyncData, createTestScheduler } from '@cardano-sdk/util-dev';
import { InMemory, withNetworkInfo, withRolledBackBlock } from '../../src/index.js';
import { stubBlockId } from '../util.js';
import type { ChainSyncRollBackward, TipOrOrigin } from '@cardano-sdk/core';
import type { UnifiedExtChainSyncEvent } from '../../src/index.js';

const dataWithStakeKeyDeregistration = chainSyncData(ChainSyncDataSet.WithPoolRetirement);

const createBlockHeader = (slot: number): Cardano.PartialBlockHeader => ({
  blockNo: Cardano.BlockNo(slot),
  hash: stubBlockId(slot),
  slot: Cardano.Slot(slot)
});
const createEvent = (eventType: ChainSyncEventType, slot: number, tipSlot = slot) =>
  ({
    block: { header: createBlockHeader(slot) },
    eventType,
    point:
      eventType === ChainSyncEventType.RollForward
        ? undefined
        : { hash: stubBlockId(tipSlot), slot: Cardano.Slot(tipSlot) },
    requestNext: expect.anything(),
    tip: { blockNo: Cardano.BlockNo(tipSlot), hash: stubBlockId(tipSlot), slot: Cardano.Slot(tipSlot) }
  } as UnifiedExtChainSyncEvent<{}>);

const sourceRollbackToPoint = (slot: number): ChainSyncRollBackward => {
  const point = { hash: stubBlockId(slot), slot: Cardano.Slot(slot) };
  return {
    eventType: ChainSyncEventType.RollBackward,
    point,
    requestNext: jest.fn(),
    tip: { ...point, blockNo: Cardano.BlockNo(slot) }
  };
};

const sourceRollbackToOrigin = (): ChainSyncRollBackward => ({
  eventType: ChainSyncEventType.RollBackward,
  point: 'origin',
  requestNext: jest.fn(),
  tip: 'origin'
});

describe('withRolledBackBlock', () => {
  let buffer: InMemory.InMemoryStabilityWindowBuffer;

  beforeEach(() => {
    buffer = new InMemory.InMemoryStabilityWindowBuffer();
  });

  it('re-emits rolled back blocks til rollback point one by one and calls requestNext on original event', () => {
    createTestScheduler().run(({ cold, hot, expectObservable, expectSubscriptions, flush }) => {
      const originalRollbackEvent = sourceRollbackToPoint(1);
      const projectedTip$ = cold('dcb', {
        b: createBlockHeader(1),
        c: createBlockHeader(2),
        d: createBlockHeader(3)
      });
      const source$ = hot('abcde', {
        a: createEvent(ChainSyncEventType.RollForward, 0),
        b: createEvent(ChainSyncEventType.RollForward, 1),
        c: createEvent(ChainSyncEventType.RollForward, 2),
        d: createEvent(ChainSyncEventType.RollForward, 3),
        e: originalRollbackEvent
      });
      expectObservable(
        source$.pipe(
          withRolledBackBlock(projectedTip$, buffer),
          withNetworkInfo(dataWithStakeKeyDeregistration.cardanoNode),
          buffer.handleEvents()
        )
      ).toBe('abcdef', {
        a: { ...createEvent(ChainSyncEventType.RollForward, 0), ...dataWithStakeKeyDeregistration.networkInfo },
        b: { ...createEvent(ChainSyncEventType.RollForward, 1), ...dataWithStakeKeyDeregistration.networkInfo },
        c: { ...createEvent(ChainSyncEventType.RollForward, 2), ...dataWithStakeKeyDeregistration.networkInfo },
        d: { ...createEvent(ChainSyncEventType.RollForward, 3), ...dataWithStakeKeyDeregistration.networkInfo },
        e: { ...createEvent(ChainSyncEventType.RollBackward, 3, 1), ...dataWithStakeKeyDeregistration.networkInfo },
        f: { ...createEvent(ChainSyncEventType.RollBackward, 2, 1), ...dataWithStakeKeyDeregistration.networkInfo }
      });
      expectSubscriptions(source$.subscriptions).toBe('^');
      flush();
      expect(originalRollbackEvent.requestNext).toBeCalledTimes(1);
    });
  });

  describe('rollback to origin', () => {
    describe('when local tip at origin', () => {
      it('calls requestNext without emitting', () => {
        createTestScheduler().run(({ cold, hot, expectObservable, expectSubscriptions, flush }) => {
          const rollbackEvent = sourceRollbackToOrigin();
          const projectedTip$ = cold<TipOrOrigin>('a', {
            a: 'origin'
          });
          const source$ = hot('a|', {
            a: rollbackEvent
          });
          expectObservable(source$.pipe(withRolledBackBlock(projectedTip$, buffer))).toBe('-|');
          expectSubscriptions(source$.subscriptions).toBe('^!');
          flush();
          expect(rollbackEvent.requestNext).toBeCalledTimes(1);
        });
      });
    });

    describe('when local tip is not at origin', () => {
      it('assumes we connected to the wrong network and throws', () => {
        createTestScheduler().run(({ cold, hot, expectObservable, flush }) => {
          const rollbackEvent = sourceRollbackToOrigin();
          const projectedTip$ = cold<TipOrOrigin>('a', {
            a: createBlockHeader(1)
          });
          const source$ = hot('a|', {
            a: rollbackEvent
          });
          expectObservable(source$.pipe(withRolledBackBlock(projectedTip$, buffer))).toBe(
            '#',
            {},
            new Error('Rollback to origin: wrong network?')
          );
          flush();
        });
      });
    });
  });

  it('throws when block is not found in the buffer', () => {
    createTestScheduler().run(({ cold, hot, expectObservable, flush }) => {
      const rollbackEvent = sourceRollbackToPoint(1);
      const projectedTip$ = cold<TipOrOrigin>('a', {
        a: createBlockHeader(2)
      });
      const source$ = hot('a|', {
        a: rollbackEvent
      });
      expectObservable(source$.pipe(withRolledBackBlock(projectedTip$, buffer))).toBe(
        '#',
        {},
        new Error(
          'Could not rollback to 0000000000000000000000000000000000000000000000000000000000000001: tip block not found in stability window buffer'
        )
      );
      flush();
    });
  });
});
