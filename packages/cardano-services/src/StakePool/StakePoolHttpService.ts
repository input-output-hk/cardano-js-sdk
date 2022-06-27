import * as OpenApiValidator from 'express-openapi-validator';
import { DbSyncStakePoolProvider } from './DbSyncStakePoolProvider';
import { HttpService } from '../Http';
import { Logger, dummyLogger } from 'ts-log';
import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { ServiceNames } from '../Program';
import { providerHandler } from '../util';
import express from 'express';
import path from 'path';

export interface StakePoolServiceDependencies {
  logger?: Logger;
  stakePoolProvider: DbSyncStakePoolProvider;
}

export class StakePoolHttpService extends HttpService {
  #stakePoolProvider: DbSyncStakePoolProvider;
  private constructor(
    { logger = dummyLogger, stakePoolProvider }: StakePoolServiceDependencies,
    router: express.Router
  ) {
    super(ServiceNames.StakePool, router, logger);
    this.#stakePoolProvider = stakePoolProvider;
  }

  static create({ logger = dummyLogger, stakePoolProvider }: StakePoolServiceDependencies) {
    const router = express.Router();
    const apiSpec = path.join(__dirname, 'openApi.json');
    router.use(
      OpenApiValidator.middleware({
        apiSpec,
        ignoreUndocumented: true, // otherwhise /metrics endpoint should be included in spec
        validateRequests: true,
        validateResponses: true
      })
    );
    // Add initial healthCheck of the provider when implemented
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
    return new StakePoolHttpService({ logger, stakePoolProvider }, router);
  }

  async initializeImpl(): Promise<void> {
    if (!(await this.healthCheck()).ok) {
      throw new ProviderError(ProviderFailure.Unhealthy);
    }
  }

  async healthCheck() {
    return this.#stakePoolProvider.healthCheck();
  }
}
