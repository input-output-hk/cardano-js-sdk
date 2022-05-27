import { HealthCheckResponse, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { HttpServer } from './HttpServer';
import { Logger, dummyLogger } from 'ts-log';
import { ProviderHandler } from '../util';
import express from 'express';

export abstract class HttpService {
  public router: express.Router;
  public slug: string;

  protected constructor(slug: string, router: express.Router, logger = dummyLogger) {
    this.router = router;
    this.slug = slug;
    this.router.post('/health', async (req, res) => {
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
    });
  }

  async close(): Promise<void> {
    return Promise.resolve();
  }

  protected abstract healthCheck(): Promise<HealthCheckResponse>;

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
