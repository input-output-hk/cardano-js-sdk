import * as OpenApiValidator from 'express-openapi-validator';
import { DbSyncStakePoolProvider } from './DbSyncStakePoolProvider';
import { HttpService } from '../Http';
import { Logger, dummyLogger } from 'ts-log';
import { ServiceNames } from '../Program';
import { providerHandler } from '../util';
import express from 'express';
import path from 'path';

export interface StakePoolServiceDependencies {
  logger?: Logger;
  stakePoolProvider: DbSyncStakePoolProvider;
}

export class StakePoolHttpService extends HttpService {
  private constructor({ logger = dummyLogger }: StakePoolServiceDependencies, router: express.Router) {
    super(ServiceNames.StakePool, router, logger);
  }

  async healthCheck() {
    return Promise.resolve({ ok: true });
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
    return new StakePoolHttpService({ logger, stakePoolProvider }, router);
  }
}
