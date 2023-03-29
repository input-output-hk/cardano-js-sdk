import { StakeKeyEntity } from '../entity/StakeKey.entity';
import { typeormSink } from './util';

export const stakeKeys = typeormSink<'stakeKeys'>({
  entities: [StakeKeyEntity],
  sink: ({ stakeKeys: { insert, del }, queryRunner }) => {
    const repository = queryRunner.manager.getRepository(StakeKeyEntity);
    const createAll = insert.length > 0 ? repository.insert(insert.map((hash) => ({ hash }))) : Promise.resolve();
    const deleteAll = del.length > 0 ? repository.delete(del) : Promise.resolve();
    return Promise.all([createAll, deleteAll]);
  }
});
