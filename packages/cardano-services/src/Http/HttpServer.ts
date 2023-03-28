import * as OpenApiValidator from 'express-openapi-validator';
import { DB_BLOCKS_BEHIND_TOLERANCE, listenPromise, serverClosePromise } from '../util';
import { Gauge, Registry } from 'prom-client';
import { HttpServerConfig, ServiceHealth, ServicesHealthCheckResponse } from './types';
import { HttpService } from './HttpService';
import { Logger } from 'ts-log';
import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { RunnableModule, contextLogger, fromSerializableObject, toSerializableObject } from '@cardano-sdk/util';
import bodyParser from 'body-parser';
import express from 'express';
import expressPromBundle from 'express-prom-bundle';
import http from 'http';
import path from 'path';

export const CONTENT_TYPE = 'Content-Type';
export const APPLICATION_JSON = 'application/json';

export const getListen = (url: URL) => ({ host: url.hostname, port: url ? Number.parseInt(url.port) : undefined });

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
          .then((details) => {
            const { ok } = details;

            return { ...(ok ? { details } : undefined), name: service.name, ok };
          })
          .catch((error) => {
            this.logger.error(error);
            return { name: service.name, ok: false };
          })
      )
    );
    const result = {
      ok: servicesHealth.every((service) => service.ok),
      services: servicesHealth
    };

    if (!result.ok) this.logger.error('Root health check NOT OK!', result);

    return result;
  }

  protected async initializeImpl(): Promise<void> {
    this.app = express();
    this.app.use(
      bodyParser.json({
        limit: this.#config?.bodyParser?.limit || '500kB',
        reviver: (key, value) => (key === '' ? fromSerializableObject(value) : value)
      })
    );
    if (this.#config?.metrics?.enabled) {
      await this.initMetrics();
    }
    const requestLogger = contextLogger(this.logger, 'request');
    this.app.use((req, _res, next) => {
      // eslint-disable-next-line @typescript-eslint/no-shadow
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

    const healthCheckHandler =
      (statusCodeFromHealth: (health: ServicesHealthCheckResponse) => number) =>
      async (req: express.Request, res: express.Response) => {
        this.logger.debug('/ready', { ip: req.ip });
        let health: ServicesHealthCheckResponse | Error['message'];
        try {
          health = await this.#getServicesHealth();
        } catch (error) {
          this.logger.error(error);
          return HttpServer.sendJSON(res, new ProviderError(ProviderFailure.Unhealthy, error), 500);
        }
        return HttpServer.sendJSON(res, health, statusCodeFromHealth(health));
      };

    this.app.use(
      '/health',
      healthCheckHandler(() => 200)
    );
    this.app.use(
      '/ready',
      healthCheckHandler(({ ok }) => (ok ? 200 : 503))
    );
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    this.app.use((err: any, _req: express.Request, res: express.Response, _n: express.NextFunction) => {
      HttpServer.sendJSON(res, new ProviderError(ProviderFailure.Unhealthy, err), err.status || 500);
    });

    const apiSpec = path.join(__dirname, 'openApi.json');
    this.app.use(
      OpenApiValidator.middleware({
        apiSpec,
        ignoreUndocumented: true,
        validateRequests: true,
        validateResponses: true
      })
    );

    const serverMetadataHandler = async (req: express.Request, res: express.Response) => {
      this.logger.debug('/meta', { ip: req.ip });
      return HttpServer.sendJSON(res, this.#config.meta);
    };

    this.app.use('/meta', serverMetadataHandler);
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

  protected async startImpl(): Promise<void> {
    for (const dependency of this.#dependencies.runnableDependencies) await dependency.start();
    for (const service of this.#dependencies.services) await service.start();
    this.server = await listenPromise(this.app, this.#config.listen);
  }

  protected async shutdownImpl(): Promise<void> {
    this.#healthGauge?.set(0);

    for (const service of this.#dependencies.services) await service.shutdown();
    for (const dependency of this.#dependencies.runnableDependencies) await dependency.shutdown();

    return serverClosePromise(this.server);
  }

  // eslint-disable-next-line sonarjs/cognitive-complexity
  private async initMetrics() {
    const promRegistry = new Registry();
    const anyService = this.#dependencies.services[0];
    // eslint-disable-next-line no-new
    new Gauge<string>({
      async collect() {
        const currentValue = (await anyService.healthCheck()).localNode?.networkSync;
        if (currentValue) this.set(currentValue * 100);
      },
      help: 'Node synchronization status',
      name: 'node_sync_percentage',
      registers: [promRegistry]
    });
    for (const service of this.#dependencies.services) {
      // '-' replaced with '_' to satisfy name validation rules
      const serviceName = service.slug.replace('-', '_');
      // eslint-disable-next-line no-new
      new Gauge<string>({
        async collect() {
          const data = await service.healthCheck();
          let syncStatus;
          if (data.projectedTip && data.localNode?.ledgerTip) {
            syncStatus =
              (data.projectedTip.blockNo * 100) / (data.localNode?.ledgerTip?.blockNo - DB_BLOCKS_BEHIND_TOLERANCE);
          }
          if (syncStatus) {
            // syncStatus calculation takes into account DB_BLOCKS_BEHIND_TOLERANCE
            // and reports 100% if the value is within the rage
            // (ledgerTip - DB_BLOCKS_BEHIND_TOLERANCE) ≤  projectedTip ≤ ledgerTip
            if (syncStatus > 100) this.set(100);
            else this.set(syncStatus);
          }
        },
        help: `Projection synchronization status - ${service.name}`,
        name: `projection_sync_percentage_${serviceName}`,
        registers: [promRegistry]
      });
    }

    // eslint-disable-next-line unicorn/consistent-function-scoping
    const getServicesHealth = async () => await this.#getServicesHealth();
    this.#healthGauge = new Gauge<string>({
      // eslint-disable-next-line sonarjs/no-identical-functions
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
        ...this.#config.metrics?.options
      })
    );
    this.logger.info(
      `Prometheus metrics: ${(await promRegistry.getMetricsAsArray()).map(({ name }) => name)} configured at ${
        this.#config.metrics?.options?.metricsPath || '/metrics'
      }`
    );
  }
}
