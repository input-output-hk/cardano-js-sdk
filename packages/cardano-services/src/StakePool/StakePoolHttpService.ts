import { HttpService } from '../Http/index.js';
import { ServiceNames } from '../Program/programs/types.js';
import { providerHandler } from '../util/index.js';
import express from 'express';
import type { Logger } from 'ts-log';
import type { StakePoolProvider } from '@cardano-sdk/core';

export interface StakePoolServiceDependencies {
  logger: Logger;
  stakePoolProvider: StakePoolProvider;
}

export class StakePoolHttpService extends HttpService {
  constructor({ logger, stakePoolProvider }: StakePoolServiceDependencies, router: express.Router = express.Router()) {
    super(ServiceNames.StakePool, stakePoolProvider, router, __dirname, logger);

    router.post(
      '/search',
      providerHandler(stakePoolProvider.queryStakePools.bind(stakePoolProvider))(
        HttpService.routeHandler(logger),
        logger
      )
    );
    router.post(
      '/stats',
      providerHandler(stakePoolProvider.stakePoolStats.bind(stakePoolProvider))(
        HttpService.routeHandler(logger),
        logger
      )
    );
  }
}
