import { Logger, dummyLogger } from 'ts-log';
import { RunnableModule } from '../RunnableModule';
import { listenPromise, serverClosePromise } from '../util';
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
  router: express.Router;
  logger?: Logger;
}

export abstract class HttpServer extends RunnableModule {
  public app: express.Application;
  public router: express.Router;
  public server: http.Server;

  protected constructor(public config: HttpServerConfig, { logger = dummyLogger, router }: HttpServerDependencies) {
    super(config.name || 'HttpServer', logger);
    this.router = router;
  }

  protected async initializeImpl(): Promise<void> {
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
    this.app.use(this.router);
  }

  protected async startImpl(): Promise<void> {
    this.server = await listenPromise(this.app, this.config.listen);
  }

  protected shutdownImpl(): Promise<void> {
    return serverClosePromise(this.server);
  }
}
