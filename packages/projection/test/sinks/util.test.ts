/* eslint-disable @typescript-eslint/no-explicit-any */
import { ChainSyncEventType } from '@cardano-sdk/core';
import { RollBackwardEvent, RollForwardEvent, WithBlock, sinks } from '../../src';
import { WithNetworkInfo } from '../../src/operators';

describe('sinks util', () => {
  describe('manageStabilityWindowBuffer', () => {
    it('calls "rollForward" on RollForward', () => {
      const buffer = { rollForward: jest.fn() } as unknown as sinks.StabilityWindowBuffer<WithNetworkInfo>;
      const block = {};
      const evt = { block, eventType: ChainSyncEventType.RollForward } as RollForwardEvent<WithNetworkInfo>;
      sinks.manageBuffer(evt, buffer);
      expect(buffer.rollForward).toBeCalledTimes(1);
      expect(buffer.rollForward).toBeCalledWith(evt);
    });

    it('calls "deleteBlock" on RollBackward', () => {
      const buffer = { deleteBlock: jest.fn() } as unknown as sinks.StabilityWindowBuffer<WithNetworkInfo>;
      const block = {};
      sinks.manageBuffer(
        { block, eventType: ChainSyncEventType.RollBackward } as RollBackwardEvent<WithBlock & WithNetworkInfo>,
        buffer
      );
      expect(buffer.deleteBlock).toBeCalledTimes(1);
      expect(buffer.deleteBlock).toBeCalledWith(block);
    });
  });
});
