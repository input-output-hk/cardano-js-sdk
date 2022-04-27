import { HttpService } from './HttpService';
import { Logger, dummyLogger } from 'ts-log';
import { ProviderError, util } from '@cardano-sdk/core';
import { RunnableModule } from '../RunnableModule';
import { listenPromise, serverClosePromise } from '../util';
import bodyParser, { Options } from 'body-parser';
import express from 'express';
import expressPromBundle from 'express-prom-bundle';
import http from 'http';
import net from 'net';
import promClient from 'prom-client';

export const CONTENT_TYPE = 'Content-Type';
export const APPLICATION_JSON = 'application/json';

export type HttpServerConfig = {
  metrics?: {
    enabled: boolean;
    options?: expressPromBundle.Opts;
  };
  bodyParser?: {
    limit?: Options['limit'];
  };
  name?: string;
  listen: net.ListenOptions;
};

export interface HttpServerDependencies {
  services: HttpService[];
  logger?: Logger;
}

export class HttpServer extends RunnableModule {
  public app: express.Application;
  public server: http.Server;
  #config: HttpServerConfig;
  #dependencies: HttpServerDependencies;

  constructor(config: HttpServerConfig, { logger = dummyLogger, ...rest }: HttpServerDependencies) {
    super(config.name || 'HttpServer', logger);
    this.#config = config;
    this.#dependencies = { logger, ...rest };
  }

  async initializeImpl(): Promise<void> {
    this.app = express();
    this.app.use(
      bodyParser.json({
        limit: this.#config?.bodyParser?.limit || '500kB',
        reviver: (key, value) => (key === '' ? util.fromSerializableObject(value) : value)
      })
    );
    if (this.#config?.metrics?.enabled) {
      this.app.use(
        expressPromBundle({
          includeMethod: true,
          promRegistry: new promClient.Registry(),
          ...this.#config.metrics.options
        })
      );
      this.logger.info(`Prometheus metrics configured at ${this.#config.metrics.options?.metricsPath || '/metrics'}`);
    }
    for (const service of this.#dependencies.services) {
      this.app.use(`/${service.slug}`, service.router);
      this.logger.debug(`Using /${service.slug}`);
    }
  }

  static sendJSON<ResponseBody>(
    res: express.Response<ResponseBody | ProviderError>,
    obj: ResponseBody | ProviderError,
    statusCode = 200
  ) {
    res.statusCode = statusCode;
    res.header(CONTENT_TYPE, APPLICATION_JSON);
    res.send(util.toSerializableObject(obj) as ResponseBody);
  }

  async startImpl(): Promise<void> {
    this.server = await listenPromise(this.app, this.#config.listen);
  }

  shutdownImpl(): Promise<void> {
    return serverClosePromise(this.server);
  }
}
