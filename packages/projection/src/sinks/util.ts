import { ChainSyncEventType } from '@cardano-sdk/core';
import { StabilityWindowBuffer } from './types';
import { UnifiedProjectorEvent } from '../types';
import { WithNetworkInfo } from '../operators';

export const manageStabilityWindowBuffer = <T extends WithNetworkInfo>(
  evt: UnifiedProjectorEvent<T>,
  buffer: StabilityWindowBuffer<T>
) => (evt.eventType === ChainSyncEventType.RollForward ? buffer.rollForward(evt) : buffer.deleteBlock(evt.block));
