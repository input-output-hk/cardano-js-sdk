import { CustomError } from 'ts-custom-error';
import { MissingProgramOption } from '../Program/errors/MissingProgramOption.js';
import { POOL_DELIST_SCHEDULE, PoolDelistedEntity } from '@cardano-sdk/projection-typeorm';
import { createSmashStakePoolDelistedService } from '../StakePool/HttpStakePoolMetadata/SmashStakePoolDelistedService.js';
import type { WorkerHandlerFactory } from './types.js';

const createService = (smashUrl: string | undefined) => {
  if (!smashUrl) throw new MissingProgramOption(POOL_DELIST_SCHEDULE, 'smash-url');

  return createSmashStakePoolDelistedService(smashUrl);
};
export const stakePoolBatchDelistHandlerFactory: WorkerHandlerFactory = (options) => {
  const { logger, smashUrl, dataSource } = options;

  const service = createService(smashUrl);
  const repo = dataSource.getRepository(PoolDelistedEntity);

  return async (_data: unknown) => {
    logger.info(`Getting list of delisted stake pools from ${smashUrl}`);
    const delists = await service.getDelistedStakePoolIds();

    if (delists instanceof CustomError) {
      logger.error(`Failed to get the list of delisted stake pools from ${smashUrl}`);
      throw delists;
    } else {
      logger.info(`Got the list of delisted stake pools from ${smashUrl}, size:${delists.length}`);

      if (delists.length > 0) {
        await dataSource.manager.transaction(async (transaction) => {
          logger.info('Updating delisted stake pools data');
          await transaction.clear(PoolDelistedEntity);
          await transaction.save(delists.map((stakePoolId) => repo.create({ stakePoolId })));
        });
      } else {
        logger.info('Clearing delisted stake pools data');
        await repo.clear();
      }

      logger.info('Delisted stake pools data is updated');
    }
  };
};
