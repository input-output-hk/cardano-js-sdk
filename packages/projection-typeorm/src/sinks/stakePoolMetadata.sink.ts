import { PoolMetadataEntity } from '../entity';
import { typeormSink } from './util';

export const stakePoolMetadata = typeormSink<'stakePoolMetadata'>({
  entities: [PoolMetadataEntity],
  async sink(_evt) {
    // TODO
  }
});
