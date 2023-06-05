import { Mappers } from '@cardano-sdk/projection';
import { StakeKeyEntity } from '../entity/StakeKey.entity';
import { typeormOperator } from './util';

export const storeStakeKeys = typeormOperator<Mappers.WithStakeKeys>(
  async ({ queryRunner, stakeKeys: { insert, del } }) => {
    const repository = queryRunner.manager.getRepository(StakeKeyEntity);
    const createAll = insert.length > 0 ? repository.insert(insert.map((hash) => ({ hash }))) : Promise.resolve();
    const deleteAll = del.length > 0 ? repository.delete(del) : Promise.resolve();
    await Promise.all([createAll, deleteAll]);
  }
);
