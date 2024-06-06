import { StakeKeyEntity } from '../entity/StakeKey.entity.js';
import { typeormOperator } from './util.js';
import type { Mappers } from '@cardano-sdk/projection';

export const storeStakeKeys = typeormOperator<Mappers.WithStakeKeys>(
  async ({ queryRunner, stakeKeys: { insert, del } }) => {
    const repository = queryRunner.manager.getRepository(StakeKeyEntity);
    const createAll = insert.length > 0 ? repository.insert(insert.map((hash) => ({ hash }))) : Promise.resolve();
    const deleteAll = del.length > 0 ? repository.delete(del) : Promise.resolve();
    await Promise.all([createAll, deleteAll]);
  }
);
