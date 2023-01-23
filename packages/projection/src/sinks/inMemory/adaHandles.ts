import {EMPTY} from 'rxjs';
import { AdaHandleProjection } from '../../projections/adaHandle';
import { ChainSyncEventType } from '@cardano-sdk/core';
import { Sink } from '../types';
import { WithInMemoryStore } from './types';

export const adaHandles: Sink<AdaHandleProjection, WithInMemoryStore> = {
  sink({ adaHandles, store, eventType }) {
    if (eventType === ChainSyncEventType.RollForward) {
      store.adaHandles.set(adaHandles.address, adaHandles.name);
    }
  },
  return EMPTY;
};
