import { EMPTY } from 'rxjs';
import { Sink } from '../types';
import { StakeKeysProjection } from '../../projections';
import { WithInMemoryStore } from './types';

export const stakeKeys: Sink<StakeKeysProjection, WithInMemoryStore> = {
  sink({ stakeKeys: { insert, del }, store }) {
    for (const stakeKey of insert) {
      store.stakeKeys.add(stakeKey);
    }
    for (const stakeKey of del) {
      store.stakeKeys.delete(stakeKey);
    }
    return EMPTY;
  }
};
