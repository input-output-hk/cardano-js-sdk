import * as OpenApiValidator from 'express-openapi-validator';
import { HttpService } from '../Http';
import { Logger } from 'ts-log';
import { ServiceNames } from '../Program/programs/types';
import { StakePoolProvider } from '@cardano-sdk/core';
import { providerHandler } from '../util';
import express from 'express';
import path from 'path';

const apiSpec = path.join(__dirname, 'openApi.json');

export interface StakePoolServiceDependencies {
  logger: Logger;
  stakePoolProvider: StakePoolProvider;
}

export class StakePoolHttpService extends HttpService {
  constructor({ logger, stakePoolProvider }: StakePoolServiceDependencies, router: express.Router = express.Router()) {
    super(ServiceNames.StakePool, stakePoolProvider, router, apiSpec, logger);

    router.use(
      OpenApiValidator.middleware({
        apiSpec,
        ignoreUndocumented: true,
        validateRequests: true,
        validateResponses: true
      })
    );
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
