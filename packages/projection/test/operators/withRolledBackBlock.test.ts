import { Cardano, ChainSyncEventType, ChainSyncRollBackward } from '@cardano-sdk/core';
import { ChainSyncDataSet, chainSyncData, createTestScheduler } from '@cardano-sdk/util-dev';
import { InMemory, Operators, UnifiedProjectorEvent } from '../../src';
import { stubBlockId } from '../util';

const dataWithStakeKeyDeregistration = chainSyncData(ChainSyncDataSet.WithPoolRetirement);

const createEvent = (eventType: ChainSyncEventType, slot: number, tipSlot = slot) =>
  ({
    block: { header: { blockNo: Cardano.BlockNo(slot), hash: stubBlockId(slot), slot: Cardano.Slot(slot) } },
    eventType,
    point:
      eventType === ChainSyncEventType.RollForward
        ? undefined
        : { hash: stubBlockId(tipSlot), slot: Cardano.Slot(tipSlot) },
    requestNext: expect.anything(),
    tip: { blockNo: Cardano.BlockNo(tipSlot), hash: stubBlockId(tipSlot), slot: Cardano.Slot(tipSlot) }
  } as UnifiedProjectorEvent<{}>);

const sourceRollback = (slot: number): ChainSyncRollBackward => {
  const point = { hash: stubBlockId(slot), slot: Cardano.Slot(slot) };
  return {
    eventType: ChainSyncEventType.RollBackward,
    point,
    requestNext: jest.fn(),
    tip: { ...point, blockNo: Cardano.BlockNo(slot) }
  };
};

describe('withRolledBackBlocks', () => {
  let buffer: InMemory.InMemoryStabilityWindowBuffer;

  beforeEach(() => {
    buffer = new InMemory.InMemoryStabilityWindowBuffer();
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
      expectObservable(
        source$.pipe(
          Operators.withRolledBackBlock(buffer),
          Operators.withNetworkInfo(dataWithStakeKeyDeregistration.cardanoNode),
          buffer.handleEvents()
        )
      ).toBe('abcd(ef)', {
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
});
