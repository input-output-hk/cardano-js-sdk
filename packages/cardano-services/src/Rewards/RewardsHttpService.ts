import * as OpenApiValidator from 'express-openapi-validator';
import { DbSyncRewardsProvider } from './DbSyncRewardProvider/DbSyncRewards';
import { HttpService } from '../Http';
import { Logger, dummyLogger } from 'ts-log';
import { ServiceNames } from '../Program';
import { providerHandler } from '../util';
import express from 'express';
import path from 'path';

export interface RewardServiceDependencies {
  logger?: Logger;
  rewardsProvider: DbSyncRewardsProvider;
}

export class RewardsHttpService extends HttpService {
  constructor(
    { logger = dummyLogger, rewardsProvider }: RewardServiceDependencies,
    router: express.Router = express.Router()
  ) {
    super(ServiceNames.Rewards, rewardsProvider, router, logger);

    const apiSpec = path.join(__dirname, 'openApi.json');
    router.use(
      OpenApiValidator.middleware({
        apiSpec,
        ignoreUndocumented: true,
        validateRequests: true,
        validateResponses: true
      })
    );
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
