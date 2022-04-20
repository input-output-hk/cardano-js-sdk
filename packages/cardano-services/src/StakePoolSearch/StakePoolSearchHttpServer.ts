import { Cardano, ProviderError, ProviderFailure, StakePoolQueryOptions } from '@cardano-sdk/core';
import { DbSyncStakePoolSearchProvider } from './DbSyncStakePoolSearchProvider';
import { HttpServer, HttpServerConfig, HttpServerDependencies } from '../Http';
import { Logger, dummyLogger } from 'ts-log';
import { isValidStakePoolOptions } from './validators';
import { providerHandler } from '../util';
import bodyParser, { Options } from 'body-parser';
import express from 'express';
import net from 'net';

export interface StakePoolSearchServerDependencies {
  stakePoolSearchProvider: DbSyncStakePoolSearchProvider;
  logger?: Logger;
}

export interface StakePoolSearchServerConfig extends HttpServerConfig {
  listen: net.ListenOptions;
  bodyParser?: {
    limit?: Options['limit'];
  };
}

export class StakePoolSearchHttpServer extends HttpServer {
  private constructor(config: StakePoolSearchServerConfig, httpServerDependencies: HttpServerDependencies) {
    super({ listen: config.listen, name: 'StakePoolSearchServer' }, httpServerDependencies);
  }
  static create(
    { stakePoolSearchProvider, logger = dummyLogger }: StakePoolSearchServerDependencies,
    config: StakePoolSearchServerConfig
  ) {
    const router = express.Router();
    router.use(bodyParser.json({ limit: config.bodyParser?.limit || '500kB', type: 'application/json' }));
    router.post(
      '/search',
      providerHandler<[StakePoolQueryOptions], Cardano.StakePool[]>(async ([stakePoolOptions], _, res) => {
        const { valid, errors } = isValidStakePoolOptions(stakePoolOptions);
        if (!valid) {
          return super.sendJSON(res, new ProviderError(ProviderFailure.BadRequest, errors), 400);
        }
        try {
          return super.sendJSON(res, await stakePoolSearchProvider.queryStakePools(stakePoolOptions));
        } catch (error) {
          logger.error(error);
          return super.sendJSON(res, new ProviderError(ProviderFailure.Unhealthy, error), 500);
        }
      }, logger)
    );
    return new StakePoolSearchHttpServer(config, { healthCheck: () => Promise.resolve({ ok: true }), logger, router });
  }
  async initializeImpl(): Promise<void> {
    await super.initializeImpl();
  }
}
