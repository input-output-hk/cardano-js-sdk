import { HealthCheckResponse, ProviderError } from '@cardano-sdk/core';
import { dummyLogger } from 'ts-log';
import express from 'express';

export abstract class HttpService {
  public router: express.Router;
  public slug: string;

  protected constructor(slug: string, router: express.Router, logger = dummyLogger) {
    this.router = router;
    this.slug = slug;
    this.router.get('/health', async (req, res) => {
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

  protected abstract healthCheck(): Promise<HealthCheckResponse>;
}
