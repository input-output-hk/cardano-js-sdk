import { Gauge, Registry } from 'prom-client';
import { HttpServerConfig, ServiceHealth, ServicesHealthCheckResponse } from './types';
import { HttpService } from './HttpService';
import { Logger } from 'ts-log';
import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { RunnableModule, contextLogger, fromSerializableObject, toSerializableObject } from '@cardano-sdk/util';
import { listenPromise, serverClosePromise } from '../util';
import bodyParser from 'body-parser';
import express from 'express';
import expressPromBundle from 'express-prom-bundle';
import http from 'http';
export const CONTENT_TYPE = 'Content-Type';
export const APPLICATION_JSON = 'application/json';

export interface HttpServerDependencies {
  services: HttpService[];
  runnableDependencies: RunnableModule[];
  logger: Logger;
}

export class HttpServer extends RunnableModule {
  public app: express.Application;
  public server: http.Server;
  #config: HttpServerConfig;
  #dependencies: HttpServerDependencies;
  #healthGauge: Gauge<string>;
  constructor(config: HttpServerConfig, { logger, ...rest }: HttpServerDependencies) {
    super(config.name || 'HttpServer', logger);
    this.#config = config;
    this.#dependencies = { logger, ...rest };
  }
  async #getServicesHealth() {
    const servicesHealth: ServiceHealth[] = await Promise.all(
      this.#dependencies.services.map((service) =>
        service
          .healthCheck()
          .then(({ ok }) => ({
            name: service.name,
            ok
          }))
          .catch((error) => {
            this.logger.error(error);
            return { name: service.name, ok: false };
          })
      )
    );
    return {
      ok: servicesHealth.every((service) => service.ok),
      services: servicesHealth
    };
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
      const promRegistry = new Registry();
      const getServicesHealth = async () => await this.#getServicesHealth();
      this.#healthGauge = new Gauge<string>({
        async collect() {
          const currentValue = Number((await getServicesHealth()).ok);
          // Set a health check gauge value with type number.Health check values: 0/1 (unhealthy/healthy)
          this.set(currentValue);
        },
        help: 'healthcheck_help',
        labelNames: ['method', 'statusCode'],
        name: 'healthcheck',
        registers: [promRegistry]
      });
      this.app.use(
        expressPromBundle({
          includeMethod: true,
          promRegistry,
          ...this.#config.metrics.options
        })
      );
      this.logger.info(
        `Prometheus metrics: ${(await promRegistry.getMetricsAsArray()).map(({ name }) => name)} configured at ${
          this.#config.metrics.options?.metricsPath || '/metrics'
        }`
      );
    }
    const requestLogger = contextLogger(this.logger, 'request');
    this.app.use((req, _res, next) => {
      const { body, method, path, query } = req;
      requestLogger.debug({ body, method, path, query });
      next();
    });

    for (const dependency of this.#dependencies.runnableDependencies) await dependency.initialize();

    for (const service of this.#dependencies.services) {
      await service.initialize();
      this.app.use(`/${service.slug}`, service.router);
      this.logger.debug(`Using /${service.slug}`);
    }

    const servicesHealthCheckHandler = async (req: express.Request, res: express.Response) => {
      this.logger.debug('/health', { ip: req.ip });
      let body: ServicesHealthCheckResponse | Error['message'];
      try {
        body = await this.#getServicesHealth();
      } catch (error) {
        this.logger.error(error);
        return HttpServer.sendJSON(res, new ProviderError(ProviderFailure.Unhealthy, error), 500);
      }
      return HttpServer.sendJSON(res, body);
    };

    this.app.use('/health', servicesHealthCheckHandler);
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    this.app.use((err: any, _req: express.Request, res: express.Response, _n: express.NextFunction) => {
      HttpServer.sendJSON(res, new ProviderError(ProviderFailure.Unhealthy, err), err.status || 500);
    });

    const buildInfo = JSON.parse(process.env.BUILD_INFO ?? '{}');
    const deploymentInfo = { ...buildInfo, startupDate: new Date() };
    const metaHandler = (_: express.Request, res: express.Response) => res.json(deploymentInfo);
    this.app.get('/meta', metaHandler);
    this.app.post('/meta', metaHandler);
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
    for (const dependency of this.#dependencies.runnableDependencies) await dependency.start();
    for (const service of this.#dependencies.services) await service.start();
    this.server = await listenPromise(this.app, this.#config.listen);
  }

  async shutdownImpl(): Promise<void> {
    this.#healthGauge?.set(0);

    for (const service of this.#dependencies.services) await service.shutdown();
    for (const dependency of this.#dependencies.runnableDependencies) await dependency.shutdown();

    return serverClosePromise(this.server);
  }
}
