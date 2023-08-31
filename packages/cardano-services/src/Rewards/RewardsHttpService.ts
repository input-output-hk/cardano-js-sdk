import { HttpService } from '../Http';
import { Logger } from 'ts-log';
import { RewardsProvider } from '@cardano-sdk/core';
import { ServiceNames } from '../Program/programs/types';
import { providerHandler } from '../util';
import express from 'express';

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
