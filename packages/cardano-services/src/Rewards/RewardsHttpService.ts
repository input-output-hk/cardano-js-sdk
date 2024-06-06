import { HttpService } from '../Http/index.js';
import { ServiceNames } from '../Program/programs/types.js';
import { providerHandler } from '../util/index.js';
import express from 'express';
import type { Logger } from 'ts-log';
import type { RewardsProvider } from '@cardano-sdk/core';

export interface RewardServiceDependencies {
  logger: Logger;
  rewardsProvider: RewardsProvider;
}

export class RewardsHttpService extends HttpService {
  constructor({ logger, rewardsProvider }: RewardServiceDependencies, router: express.Router = express.Router()) {
    super(ServiceNames.Rewards, rewardsProvider, router, __dirname, logger);

    router.post(
      '/account-balance',
      providerHandler(rewardsProvider.rewardAccountBalance.bind(rewardsProvider))(
        HttpService.routeHandler(logger),
        logger
      )
    );
    router.post(
      '/history',
      providerHandler(rewardsProvider.rewardsHistory.bind(rewardsProvider))(HttpService.routeHandler(logger), logger)
    );
  }
}
