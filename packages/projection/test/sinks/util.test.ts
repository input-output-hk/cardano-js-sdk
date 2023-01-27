/* eslint-disable @typescript-eslint/no-explicit-any */
import { ChainSyncEventType } from '@cardano-sdk/core';
import { RollBackwardEvent, RollForwardEvent, WithBlock, sinks } from '../../src';

describe('sinks util', () => {
  describe('manageBuffer', () => {
    it('calls "addStabilityWindowBlock" on RollForward', () => {
      const buffer = { addStabilityWindowBlock: jest.fn() } as unknown as sinks.StabilityWindowBuffer;
      const block = {};
      sinks.manageBuffer({ block, eventType: ChainSyncEventType.RollForward } as RollForwardEvent, buffer);
      expect(buffer.addStabilityWindowBlock).toBeCalledTimes(1);
      expect(buffer.addStabilityWindowBlock).toBeCalledWith(block);
    });

    it('calls "deleteStabilityWindowBlock" on RollBackward', () => {
      const buffer = { deleteStabilityWindowBlock: jest.fn() } as unknown as sinks.StabilityWindowBuffer;
      const block = {};
      sinks.manageBuffer({ block, eventType: ChainSyncEventType.RollBackward } as RollBackwardEvent<WithBlock>, buffer);
      expect(buffer.deleteStabilityWindowBlock).toBeCalledTimes(1);
      expect(buffer.deleteStabilityWindowBlock).toBeCalledWith(block);
    });
  });
});
