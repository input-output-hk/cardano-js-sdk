import { Logger, dummyLogger } from 'ts-log';
import { RunnableModule } from '../RunnableModule';
import { listenPromise, serverClosePromise } from '../util';
import express from 'express';
import http from 'http';
import net from 'net';

export type HttpServerConfig = {
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
    this.app.use(this.router);
  }

  protected async startImpl(): Promise<void> {
    this.server = await listenPromise(this.app, this.config.listen);
  }

  protected shutdownImpl(): Promise<void> {
    return serverClosePromise(this.server);
  }
}
