import { Cardano } from '@cardano-sdk/core';
import { DataSource, MoreThan } from 'typeorm';
import { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import { PoolMetadataEntity, PoolRegistrationEntity, StakePoolMetadataTask } from '@cardano-sdk/projection-typeorm';
import { WorkerHandlerFactory } from './types';
import { createHttpStakePoolMetadataService } from '../StakePool';

const isErrorWithConstraint = (error: unknown): error is Error & { constraint: unknown } =>
  error instanceof Error && 'constraint' in error;

export const isUpdateOutdated = async (dataSource: DataSource, poolId: Cardano.PoolId, poolRegistrationId: string) => {
  const repos = dataSource.getRepository(PoolRegistrationEntity);
  // TODO: Improve this check to take in account stability window
  // Ref: LW-6492
  const res = await repos.countBy({
    id: MoreThan(poolRegistrationId as unknown as bigint),
    stakePool: { id: poolId }
  });

  return res > 0;
};

interface SavePoolMetadataArguments {
  dataSource: DataSource;
  hash: Hash32ByteBase16;
  metadata: Cardano.StakePoolMetadata;
  poolId: Cardano.PoolId;
  poolRegistrationId: string;
}

export const savePoolMetadata = async (args: SavePoolMetadataArguments) => {
  const { dataSource, hash, metadata, poolId, poolRegistrationId } = args;
  const repos = dataSource.getRepository(PoolMetadataEntity);
  const entity = repos.create({
    ...metadata,
    hash,
    poolUpdate: { id: BigInt(poolRegistrationId) },
    stakePool: { id: poolId }
  });

  try {
    await repos.upsert(entity, ['poolUpdate']);
  } catch (error) {
    // If no poolRegistration record is present, it was rolled back: do nothing
    if (isErrorWithConstraint(error) && error.constraint === 'FK_pool_metadata_pool_update_id') return;

    throw error;
  }
};

export const stakePoolMetadataHandlerFactory: WorkerHandlerFactory = (dataSource, logger) => {
  const service = createHttpStakePoolMetadataService(logger);

  return async (task: StakePoolMetadataTask) => {
    const { metadataJson, poolId, poolRegistrationId } = task;
    const { hash, url } = metadataJson;

    logger.info(`Checking if pool update ${poolRegistrationId} is outdated by a more recent update`);

    // If there is a newer pool update in the chain...
    if (await isUpdateOutdated(dataSource, poolId, poolRegistrationId)) {
      logger.info('Pool update is outdated, metadata no longer needed');

      return;
    }

    logger.info('Resolving stake pool metadata...', { poolId, poolRegistrationId });

    const { errors, metadata } = await service.getStakePoolMetadata(hash, url);

    logger.info('Stake pool metadata resolved', { errors, metadata, poolId, poolRegistrationId });

    // In case there is some error in fetching extended metadata and the root metadata is populated,
    // we need to save the latter anyway
    if (metadata) {
      logger.info('Saving stake pool metadata...');
      await savePoolMetadata({ dataSource, hash, metadata, poolId, poolRegistrationId });
      logger.info('Stake pool metadata saved');
    }

    // TODO: Store the error in a dedicated table
    // Ref: LW-6409

    // In case of errors the handler throws in order to let pg-boss to retry the job.
    if (errors?.length) throw errors[0];
  };
};
