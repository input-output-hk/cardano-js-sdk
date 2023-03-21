import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { Operators, UnifiedProjectorEvent } from '../../src';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { stubEraSummaries } from '../util';

const createEvent = (epochNo: number, eventType: ChainSyncEventType, crossEpochBoundary?: boolean) =>
  ({
    crossEpochBoundary,
    epochNo,
    eraSummaries: stubEraSummaries,
    eventType
  } as UnifiedProjectorEvent<Operators.WithEpochNo & Operators.WithNetworkInfo & Partial<Operators.WithEpochBoundary>>);

describe('withEpochBoundary', () => {
  describe('from origin', () => {
    it('is true only if processing the 1st block of a new epoch, exluding 0th epoch', () => {
      createTestScheduler().run(({ hot, expectObservable, expectSubscriptions }) => {
        const source$ = hot<UnifiedProjectorEvent<Operators.WithEpochNo & Operators.WithNetworkInfo>>('abcdefg', {
          a: createEvent(0, ChainSyncEventType.RollForward),
          b: createEvent(0, ChainSyncEventType.RollForward),
          c: createEvent(1, ChainSyncEventType.RollForward),
          d: createEvent(1, ChainSyncEventType.RollForward),
          e: createEvent(0, ChainSyncEventType.RollBackward),
          f: createEvent(1, ChainSyncEventType.RollForward),
          g: createEvent(2, ChainSyncEventType.RollForward)
        });
        expectObservable(source$.pipe(Operators.withEpochBoundary({ point: 'origin' }))).toBe('abcdefg', {
          a: createEvent(0, ChainSyncEventType.RollForward, false),
          b: createEvent(0, ChainSyncEventType.RollForward, false),
          c: createEvent(1, ChainSyncEventType.RollForward, true),
          d: createEvent(1, ChainSyncEventType.RollForward, false),
          e: createEvent(0, ChainSyncEventType.RollBackward, true),
          f: createEvent(1, ChainSyncEventType.RollForward, true),
          g: createEvent(2, ChainSyncEventType.RollForward, true)
        });
        expectSubscriptions(source$.subscriptions).toBe('^');
      });
    });
  });

  describe('resuming sync', () => {
    it('is true when resuming sync from the last block of an epoch', () => {
      createTestScheduler().run(({ hot, expectObservable, expectSubscriptions }) => {
        const source$ = hot<UnifiedProjectorEvent<Operators.WithEpochNo & Operators.WithNetworkInfo>>('a', {
          a: createEvent(1, ChainSyncEventType.RollForward)
        });
        expectObservable(
          source$.pipe(Operators.withEpochBoundary({ point: { hash: '' as Cardano.BlockId, slot: Cardano.Slot(0) } }))
        ).toBe('a', {
          a: createEvent(1, ChainSyncEventType.RollForward, true)
        });
        expectSubscriptions(source$.subscriptions).toBe('^');
      });
    });
  });
});
