import { Ed25519KeyHashHex } from '@cardano-sdk/crypto';
import { Mappers } from '../../operators';
import { inMemoryStoreOperator } from './utils';

export const storeStakeKeys = inMemoryStoreOperator<Mappers.WithStakeKeys>(({ stakeKeys: { insert, del }, store }) => {
  for (const stakeKey of insert) {
    store.stakeKeys.add(stakeKey as unknown as Ed25519KeyHashHex);
  }
  for (const stakeKey of del) {
    store.stakeKeys.delete(stakeKey as unknown as Ed25519KeyHashHex);
  }
});
