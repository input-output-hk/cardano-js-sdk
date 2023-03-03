import { Projections } from '@cardano-sdk/projection';
import { StakeKeyEntity } from '../entity/StakeKey.entity';
import { TypeormSink } from '../types';
import { from, map } from 'rxjs';

export const stakeKeys: TypeormSink<Projections.StakeKeysProjection> = {
  entities: [StakeKeyEntity],
  sink({ stakeKeys: { insert, del }, queryRunner }) {
    const repository = queryRunner.manager.getRepository(StakeKeyEntity);
    const createAll = insert.length > 0 ? repository.insert(insert.map((hash) => ({ hash }))) : Promise.resolve();
    const deleteAll = del.length > 0 ? repository.delete(del) : Promise.resolve();
    return from(Promise.all([createAll, deleteAll])).pipe(map(() => void 0));
  }
};
