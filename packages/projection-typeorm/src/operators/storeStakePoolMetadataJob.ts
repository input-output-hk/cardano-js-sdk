import { ChainSyncEventType } from '@cardano-sdk/core';
import { Mappers } from '@cardano-sdk/projection';
import { STAKE_POOL_METADATA_QUEUE, StakePoolMetadataJob } from '../pgBoss';
import { WithPgBoss } from './withTypeormTransaction';
import { certificatePointerToId, typeormOperator } from './util';

export const storeStakePoolMetadataJob = typeormOperator<Mappers.WithStakePools & WithPgBoss>(
  async ({ eventType, stakePools, pgBoss, block: { header } }) => {
    if (eventType === ChainSyncEventType.RollBackward) {
      // Tasks are automatically deleted via slot cascade (referencing Block.slot)
      return;
    }
    const tasks = stakePools.updates
      .filter(({ poolParameters: { metadataJson } }) => !!metadataJson)
      .map(
        ({ source, poolParameters: { id, metadataJson } }): StakePoolMetadataJob => ({
          metadataJson: metadataJson!,
          poolId: id,
          poolRegistrationId: certificatePointerToId(source).toString()
        })
      );
    for (const task of tasks) {
      await pgBoss.send(STAKE_POOL_METADATA_QUEUE, task, { slot: header.slot });
    }
  }
);
