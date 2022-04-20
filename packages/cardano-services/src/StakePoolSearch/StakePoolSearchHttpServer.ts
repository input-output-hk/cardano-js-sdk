import { Cardano, StakePoolQueryOptions } from '@cardano-sdk/core';
import { DbSyncStakePoolSearchProvider } from './DbSyncStakePoolSearchProvider';
import { ErrorObject, serializeError } from 'serialize-error';
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
      // TODO: update providerHandler to set body type on res based on provider method type that comes in generic param
      providerHandler<StakePoolQueryOptions>(async ([stakePoolOptions], req, res) => {
        logger.debug('/search', { ip: req.ip });
        let body: Error['message'] | Cardano.StakePool[];
        const { valid, errors } = isValidStakePoolOptions(stakePoolOptions);
        if (!valid) {
          res.statusCode = 400;
          body = JSON.stringify(errors);
        } else {
          try {
            body = await stakePoolSearchProvider.queryStakePools(stakePoolOptions);
          } catch (error) {
            res.statusCode = 500;
            body = JSON.stringify(
              Array.isArray(error) ? error.map<ErrorObject>((e) => serializeError(e)) : serializeError(error)
            );
            logger.error(body);
          }
        }

        super.sendJSON(res, body);
      })
    );
    return new StakePoolSearchHttpServer(config, { healthCheck: () => Promise.resolve({ ok: true }), logger, router });
  }
  async initializeImpl(): Promise<void> {
    await super.initializeImpl();
  }
}
