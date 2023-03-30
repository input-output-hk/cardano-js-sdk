import { ChainSyncEventType } from '@cardano-sdk/core';
import { PoolMetadataEntity } from '../entity';
import { STAKE_POOL_METADATA_QUEUE, StakePoolMetadataJob } from '../pgBoss';
import { certificatePointerToId, typeormSink } from './util';

export const stakePoolMetadata = typeormSink<'stakePoolMetadata'>({
  dependencies: ['stakePools'],
  entities: [PoolMetadataEntity],
  extensions: {
    pgBoss: true
  },
  async sink(evt) {
    if (evt.eventType === ChainSyncEventType.RollBackward) {
      // Tasks are automatically deleted via block_height cascade
      return;
    }
    const boss = evt.extensions.pgBoss!;
    const tasks = evt.stakePools.updates
      .filter(({ poolParameters: { metadataJson } }) => !!metadataJson)
      .map(
        ({ source, poolParameters: { id, metadataJson } }): StakePoolMetadataJob => ({
          metadataJson: metadataJson!,
          poolId: id,
          poolRegistrationId: certificatePointerToId(source).toString()
        })
      );
    for (const task of tasks) {
      await boss.send(STAKE_POOL_METADATA_QUEUE, task, { blockHeight: evt.blockEntity.height! });
    }
  }
});
