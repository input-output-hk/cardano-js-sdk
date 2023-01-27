import { ChainSyncEventType } from '@cardano-sdk/core';
import { EMPTY } from 'rxjs';
import { Sink } from '../types';
import { StakeKeysProjection } from '../../projections';
import { WithInMemoryStore } from './types';

export const stakeKeys: Sink<StakeKeysProjection, WithInMemoryStore> = {
  sink({ stakeKeys: eventStakeKeys, store, eventType }) {
    const operations =
      eventType === ChainSyncEventType.RollForward
        ? eventStakeKeys
        : {
            deregister: eventStakeKeys.register,
            register: eventStakeKeys.deregister
          };
    for (const stakeKey of operations.register) {
      store.stakeKeys.add(stakeKey);
    }
    for (const stakeKey of operations.deregister) {
      store.stakeKeys.delete(stakeKey);
    }
    return EMPTY;
  }
};
