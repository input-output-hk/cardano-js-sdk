import { ChainSyncEventType } from '@cardano-sdk/core';
import { StabilityWindowBuffer } from './types';
import { UnifiedProjectorEvent } from '../types';

export const manageBuffer = <T>(evt: UnifiedProjectorEvent<T>, buffer: StabilityWindowBuffer) =>
  evt.eventType === ChainSyncEventType.RollForward
    ? buffer.addStabilityWindowBlock(evt.block)
    : buffer.deleteStabilityWindowBlock(evt.block);
