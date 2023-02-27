import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { EMPTY } from 'rxjs';
import { Sink } from '../types';
import { StakePoolsProjection } from '../../projections';
import { WithCertificateSource } from '../../operators';
import { WithInMemoryStore } from './types';

const findOrCreate = ({ store: { stakePools } }: WithInMemoryStore, poolId: Cardano.PoolId) => {
  let stakePool = stakePools.get(poolId);
  if (!stakePool) {
    stakePools.set(poolId, (stakePool = { retirements: [], updates: [] }));
  }
  return stakePool;
};

export const stakePools: Sink<StakePoolsProjection, WithInMemoryStore> = {
  sink(evt) {
    if (evt.eventType === ChainSyncEventType.RollForward) {
      for (const [poolId, poolUpdates] of evt.stakePools.updates) {
        findOrCreate(evt, poolId).updates.push(...poolUpdates);
      }
      for (const [poolId, poolRetirements] of evt.stakePools.retirements) {
        findOrCreate(evt, poolId).retirements.push(...poolRetirements);
      }
    } else {
      // Delete all updates and retirements >= current cursor.
      const belowTip = ({ source }: WithCertificateSource) =>
        evt.point !== 'origin' && source.slot < evt.block.header.slot;
      for (const [_, stakePool] of evt.store.stakePools) {
        stakePool.updates = stakePool.updates.filter(belowTip);
        stakePool.retirements = stakePool.retirements.filter(belowTip);
      }
    }
    return EMPTY;
  }
};
