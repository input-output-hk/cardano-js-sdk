import { Cardano, ProviderError, ProviderFailure, StakePoolQueryOptions } from '@cardano-sdk/core';
import { DbSyncStakePoolSearchProvider } from './DbSyncStakePoolSearchProvider';
import { HttpServer, HttpService } from '../Http';
import { Logger, dummyLogger } from 'ts-log';
import { isValidStakePoolOptions } from './validators';
import { providerHandler } from '../util';
import express from 'express';

export interface StakePoolSearchServiceDependencies {
  logger?: Logger;
  stakePoolSearchProvider: DbSyncStakePoolSearchProvider;
}

export class StakePoolSearchHttpService extends HttpService {
  private constructor({ logger = dummyLogger }: StakePoolSearchServiceDependencies, router: express.Router) {
    super('stake-pool-search', router, logger);
  }

  async healthCheck() {
    return Promise.resolve({ ok: true });
  }

  static create({ logger = dummyLogger, stakePoolSearchProvider }: StakePoolSearchServiceDependencies) {
    const router = express.Router();
    // Add initial healthCheck of the provider when implemented
    router.post(
      '/search',
      providerHandler<[StakePoolQueryOptions], Cardano.StakePool[]>(async ([stakePoolOptions], _, res) => {
        const { valid, errors } = isValidStakePoolOptions(stakePoolOptions);
        if (!valid) {
          return HttpServer.sendJSON(res, new ProviderError(ProviderFailure.BadRequest, errors), 400);
        }
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
