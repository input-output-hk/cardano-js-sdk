import * as OpenApiValidator from 'express-openapi-validator';
import { Cardano, ProviderError, ProviderFailure, StakePoolQueryOptions } from '@cardano-sdk/core';
import { DbSyncStakePoolSearchProvider } from './DbSyncStakePoolSearchProvider';
import { HttpServer, HttpService } from '../Http';
import { Logger, dummyLogger } from 'ts-log';
import { ServiceNames } from '../Program';
import { providerHandler } from '../util';
import express from 'express';
import path from 'path';

export interface StakePoolSearchServiceDependencies {
  logger?: Logger;
  stakePoolSearchProvider: DbSyncStakePoolSearchProvider;
}

export class StakePoolSearchHttpService extends HttpService {
  private constructor({ logger = dummyLogger }: StakePoolSearchServiceDependencies, router: express.Router) {
    super(ServiceNames.StakePoolSearch, router, logger);
  }

  async healthCheck() {
    return Promise.resolve({ ok: true });
  }

  static create({ logger = dummyLogger, stakePoolSearchProvider }: StakePoolSearchServiceDependencies) {
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
      providerHandler<[StakePoolQueryOptions], Cardano.StakePool[]>(async ([stakePoolOptions], _, res) => {
        try {
          return HttpServer.sendJSON(res, await stakePoolSearchProvider.queryStakePools(stakePoolOptions));
        } catch (error) {
          logger.error(error);
          return HttpServer.sendJSON(res, new ProviderError(ProviderFailure.Unhealthy, error), 500);
        }
      }, logger)
    );
    return new StakePoolSearchHttpService({ logger, stakePoolSearchProvider }, router);
  }
}
