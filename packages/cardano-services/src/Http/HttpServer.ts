import { HealthCheckResponse, ProviderError } from '@cardano-sdk/core';
import { Logger, dummyLogger } from 'ts-log';
import { RunnableModule } from '../RunnableModule';
import { listenPromise, serverClosePromise } from '../util';
import bodyParser from 'body-parser';
import express from 'express';
import expressPromBundle from 'express-prom-bundle';
import http from 'http';
import net from 'net';
import promClient from 'prom-client';

export type HttpServerConfig = {
  metrics?: {
    enabled: boolean;
    options?: expressPromBundle.Opts;
  };
  name?: string;
  listen: net.ListenOptions;
};

export interface HttpServerDependencies {
  healthCheck: () => Promise<HealthCheckResponse>;
  router: express.Router;
  logger?: Logger;
}

export abstract class HttpServer extends RunnableModule {
  public app: express.Application;
  public server: http.Server;
  #dependencies: HttpServerDependencies;

  protected constructor(public config: HttpServerConfig, { logger = dummyLogger, ...rest }: HttpServerDependencies) {
    super(config.name || 'HttpServer', logger);
    this.#dependencies = { logger, ...rest };
  }

  protected async initializeImpl(): Promise<void> {
    this.#dependencies.router.use(bodyParser.json());
    this.#dependencies.router.get('/health', async (req, res) => {
      this.logger.debug('/health', { ip: req.ip });
      let body: HealthCheckResponse | Error['message'];
      try {
        body = await this.#dependencies.healthCheck();
      } catch (error) {
        this.logger.error(error);
        body = error instanceof ProviderError ? error.message : 'Unknown error';
        res.statusCode = 500;
      }
      res.send(body);
    });
    this.app = express();
    if (this.config.metrics?.enabled) {
      this.app.use(
        expressPromBundle({
          includeMethod: true,
          promRegistry: new promClient.Registry(),
          ...this.config.metrics.options
        })
      );
      this.logger.info(`Prometheus metrics configured at ${this.config.metrics.options?.metricsPath || '/metrics'}`);
    }

    this.app.use(this.#dependencies.router);
  }

  protected async startImpl(): Promise<void> {
    this.server = await listenPromise(this.app, this.config.listen);
  }

  protected shutdownImpl(): Promise<void> {
    return serverClosePromise(this.server);
  }
}
