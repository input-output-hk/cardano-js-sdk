import { ChainSyncEventType } from '@cardano-sdk/core';
import { Mappers } from '@cardano-sdk/projection';
import { STAKE_POOL_METADATA_QUEUE, StakePoolMetadataJob, defaultJobOptions } from '../pgBoss';
import { WithPgBoss } from './withTypeormTransaction';
import { certificatePointerToId, typeormOperator } from './util';

export const willStoreStakePoolMetadataJob = ({ stakePools }: Mappers.WithStakePools) => stakePools.updates.length > 0;

export const createStoreStakePoolMetadataJob = (retryDelay = defaultJobOptions.retryDelay) =>
  typeormOperator<Mappers.WithStakePools & WithPgBoss>(async ({ block: { header }, eventType, pgBoss, stakePools }) => {
    const { slot } = header;

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

    for (const task of tasks)
      await pgBoss.send(STAKE_POOL_METADATA_QUEUE, task, { ...defaultJobOptions, retryDelay, slot });
  });
