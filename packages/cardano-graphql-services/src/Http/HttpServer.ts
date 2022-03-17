import { RunnableModule } from '../RunnableModule';
import { dummyLogger } from 'ts-log';
import { listenPromise, serverClosePromise } from '../util';
import express from 'express';
import http from 'http';
import net from 'net';

export type HttpServerConfig = {
  router: express.Router;
  name: string;
  listen: net.ListenOptions;
};

export abstract class HttpServer extends RunnableModule {
  public app: express.Application;
  public server: http.Server;

  protected constructor(public config: HttpServerConfig, logger = dummyLogger) {
    super(config.name, logger);
  }

  protected async initializeImpl(): Promise<void> {
    this.app = express();
    this.app.use(this.config.router);
  }

  protected async startImpl(): Promise<void> {
    this.server = await listenPromise(this.app, this.config.listen);
  }

  protected shutdownImpl(): Promise<void> {
    return serverClosePromise(this.server);
  }
}
