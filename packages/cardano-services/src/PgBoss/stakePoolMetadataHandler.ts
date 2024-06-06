import { CustomError } from 'ts-custom-error';
import { MoreThan } from 'typeorm';
import { NotImplementedError, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { PoolMetadataEntity, PoolRegistrationEntity } from '@cardano-sdk/projection-typeorm';
import { StakePoolMetadataFetchMode, checkProgramOptions } from '../Program/options/index.js';
import { createHttpStakePoolMetadataService } from '../StakePool/index.js';
import { isErrorWithConstraint } from './util.js';
import type { Cardano } from '@cardano-sdk/core';
import type { DataSource } from 'typeorm';
import type { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import type { StakePoolMetadataJob } from '@cardano-sdk/projection-typeorm';
import type { WorkerHandlerFactory } from './types.js';

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

export const getUrlToFetch = (
  metadataFetchMode: StakePoolMetadataFetchMode,
  smashUrl: string | undefined,
  directUrl: string,
  poolRegistrationId: string,
  metadataHash: string
) => {
  if (metadataFetchMode === StakePoolMetadataFetchMode.SMASH) {
    return `${smashUrl}/metadata/${poolRegistrationId}/${metadataHash}`;
  } else if (metadataFetchMode === StakePoolMetadataFetchMode.DIRECT) {
    return directUrl;
  }

  throw new NotImplementedError(
    `There is no implementation to handle the fetch mode (--metadata-fetch-mode): ${metadataFetchMode}`
  );
};

export const attachExtendedMetadata = (
  metadataWithoutExt: Cardano.StakePoolMetadata,
  extMetadata: Cardano.ExtendedStakePoolMetadata | CustomError | undefined
): Cardano.StakePoolMetadata => {
  if (extMetadata instanceof CustomError) {
    const error = extMetadata;

    if (error instanceof ProviderError && error.reason === ProviderFailure.NotFound) {
      return { ...metadataWithoutExt!, ext: null };
    }
    return metadataWithoutExt;
  } else if (extMetadata === undefined) {
    return metadataWithoutExt;
  }
  return { ...metadataWithoutExt!, ext: extMetadata };
};
export const stakePoolMetadataHandlerFactory: WorkerHandlerFactory = (options) => {
  const { dataSource, logger, metadataFetchMode, smashUrl } = options;
  const service = createHttpStakePoolMetadataService(logger);

  checkProgramOptions(metadataFetchMode, smashUrl);

  return async (task: StakePoolMetadataJob) => {
    const { metadataJson, poolId, poolRegistrationId } = task;
    const { hash, url } = metadataJson;

    logger.info(`Checking if pool update ${poolRegistrationId} is outdated by a more recent update`);

    // If there is a newer pool update in the chain...
    if (await isUpdateOutdated(dataSource, poolId, poolRegistrationId)) {
      logger.info('Pool update is outdated, metadata no longer needed');

      return;
    }

    const urlToFetch: string = getUrlToFetch(metadataFetchMode, smashUrl, url, poolId, hash);

    logger.info('Resolving stake pool metadata...', { metadataFetchMode, poolId, poolRegistrationId });

    const metadataResponse: Cardano.StakePoolMetadata | CustomError = await service.getStakePoolMetadata(
      hash,
      urlToFetch
    );

    if (metadataResponse instanceof CustomError) {
      logger.info('Stake pool metadata NOT resolved with errors', {
        metadataResponse,
        poolId,
        poolRegistrationId,
        url
      });
      // In case of errors the handler throws in order to let pg-boss to retry the job.
      logger.info('StakePoolMetadataJob failed to fetch stake pool metadata.');
      throw metadataResponse;
    } else {
      const metadataWithoutExt: Cardano.StakePoolMetadata = metadataResponse;

      logger.info('Stake pool metadata resolved successfully', { metadataWithoutExt, poolId, poolRegistrationId, url });

      logger.info('Resolving extended stake pool metadata...', { metadataFetchMode, poolId, poolRegistrationId });

      const extendedMetadata = await service.getValidateStakePoolExtendedMetadata(metadataWithoutExt);

      logger.info('Stake pool extended metadata resolved', {
        extendedMetadata,
        metadataFetchMode,
        poolId,
        poolRegistrationId
      });

      const metadata: Cardano.StakePoolMetadata = attachExtendedMetadata(metadataWithoutExt, extendedMetadata);

      await savePoolMetadata({ dataSource, hash, metadata, poolId, poolRegistrationId });

      logger.info('Stake pool metadata saved');

      if (extendedMetadata instanceof CustomError) {
        logger.info('StakePoolMetadataJob failed to fetch extended stake pool metadata.');
        throw extendedMetadata;
      }
    }
  };

  // TODO: Store the error in a dedicated table
  // Ref: LW-6409
};
