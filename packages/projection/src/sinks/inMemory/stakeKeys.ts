import { inMemorySink } from './utils';

export const stakeKeys = inMemorySink<'stakeKeys'>(({ stakeKeys: { insert, del }, store }) => {
  for (const stakeKey of insert) {
    store.stakeKeys.add(stakeKey);
  }
  for (const stakeKey of del) {
    store.stakeKeys.delete(stakeKey);
  }
});
