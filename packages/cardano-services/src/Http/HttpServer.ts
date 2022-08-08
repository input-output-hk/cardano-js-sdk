import { HttpService } from './HttpService';
import { Logger } from 'ts-log';
import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { RunnableModule } from '../RunnableModule';
import { fromSerializableObject, toSerializableObject } from '@cardano-sdk/util';
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
  logger: Logger;
}

export class HttpServer extends RunnableModule {
  public app: express.Application;
  public server: http.Server;
  #config: HttpServerConfig;
  #dependencies: HttpServerDependencies;

  constructor(config: HttpServerConfig, { logger, ...rest }: HttpServerDependencies) {
    super(config.name || 'HttpServer', logger);
    this.#config = config;
    this.#dependencies = { logger, ...rest };
  }
  async initializeImpl(): Promise<void> {
    this.app = express();
    this.app.use(
      bodyParser.json({
        limit: this.#config?.bodyParser?.limit || '500kB',
        reviver: (key, value) => (key === '' ? fromSerializableObject(value) : value)
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
      await service.initialize();
      this.app.use(`/${service.slug}`, service.router);
      this.logger.debug(`Using /${service.slug}`);
    }
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    this.app.use((err: any, _req: express.Request, res: express.Response, _n: express.NextFunction) => {
      HttpServer.sendJSON(res, new ProviderError(ProviderFailure.Unhealthy, err), err.status || 500);
    });
  }

  static sendJSON<ResponseBody>(
    res: express.Response<ResponseBody | ProviderError>,
    obj: ResponseBody | ProviderError,
    statusCode = 200
  ) {
    res.statusCode = statusCode;
    res.header(CONTENT_TYPE, APPLICATION_JSON);
    res.send(toSerializableObject(obj) as ResponseBody);
  }

  async startImpl(): Promise<void> {
    for (const service of this.#dependencies.services) await service.start();
    this.server = await listenPromise(this.app, this.#config.listen);
  }

  async shutdownImpl(): Promise<void> {
    for (const service of this.#dependencies.services) await service.shutdown();

    return serverClosePromise(this.server);
  }
}
