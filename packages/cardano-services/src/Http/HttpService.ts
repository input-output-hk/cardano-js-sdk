import { HealthCheckResponse, Provider, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { HttpServer } from './HttpServer';
import { Logger, dummyLogger } from 'ts-log';
import { ProviderHandler } from '../util';
import { RunnableModule } from '../RunnableModule';
import express from 'express';

export abstract class HttpService extends RunnableModule {
  public router: express.Router;
  public slug: string;
  public provider: Provider;

  constructor(slug: string, provider: Provider, router: express.Router, logger = dummyLogger) {
    super(slug, logger);
    this.router = router;
    this.slug = slug;
    this.provider = provider;

    const healthHandler = async (req: express.Request, res: express.Response) => {
      logger.debug('/health', { ip: req.ip });
      let body: HealthCheckResponse | Error['message'];
      try {
        body = await this.healthCheck();
      } catch (error) {
        logger.error(error);
        body = error instanceof ProviderError ? error.message : 'Unknown error';
        res.statusCode = 500;
      }
      res.send(body);
    };
    this.router.get('/health', healthHandler);
    this.router.post('/health', healthHandler);
  }

  async initializeImpl(): Promise<void> {
    if (!(await this.healthCheck()).ok) {
      throw new ProviderError(ProviderFailure.Unhealthy);
    }
  }

  async startImpl(): Promise<void> {
    await this.provider.start?.();
  }

  async shutdownImpl(): Promise<void> {
    await this.provider.close?.();
  }

  async healthCheck(): Promise<HealthCheckResponse> {
    return await this.provider.healthCheck();
  }

  static routeHandler(logger: Logger): ProviderHandler {
    return async (args, _r, res, _n, handler) => {
      try {
        return HttpServer.sendJSON(res, await handler(...args));
      } catch (error) {
        logger.error(error);
        return HttpServer.sendJSON(res, new ProviderError(ProviderFailure.Unhealthy, error), 500);
      }
    };
  }
}
