import { Mappers } from '../../operators';
import { inMemoryStoreOperator } from './utils';

export const storeStakeKeys = inMemoryStoreOperator<Mappers.WithStakeKeys>(({ stakeKeys: { insert, del }, store }) => {
  for (const stakeKey of insert) {
    store.stakeKeys.add(stakeKey);
  }
  for (const stakeKey of del) {
    store.stakeKeys.delete(stakeKey);
  }
});
