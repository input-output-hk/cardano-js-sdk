import { HttpService } from '../Http';
import { Logger } from 'ts-log';
import { ServiceNames } from '../Program/programs/types';
import { StakePoolProvider } from '@cardano-sdk/core';
import { providerHandler } from '../util';
import express from 'express';

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
