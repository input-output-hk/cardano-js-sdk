/* eslint-disable sonarjs/cognitive-complexity */
import * as OpenApiValidator from 'express-openapi-validator';
import { APPLICATION_JSON, CONTENT_TYPE, corsOptions } from './util';
import { DB_BLOCKS_BEHIND_TOLERANCE, listenPromise, serverClosePromise } from '../util';
import { Gauge, Registry } from 'prom-client';
import { HttpServerConfig, ServiceHealth, ServicesHealthCheckResponse } from './types';
import { HttpService } from './HttpService';
import { Logger } from 'ts-log';
import { ProviderError, ProviderFailure, providerFailureToStatusCodeMap } from '@cardano-sdk/core';
import { RunnableModule, contextLogger, fromSerializableObject, toSerializableObject } from '@cardano-sdk/util';
import { versionPathFromSpec } from '../util/openApi';
import bodyParser from 'body-parser';
import cors from 'cors';
import express from 'express';
import expressPromBundle from 'express-prom-bundle';
import http from 'http';
import path from 'path';

const apiSpecPath = path.join(__dirname, 'openApi.json');
const versionPath = versionPathFromSpec(apiSpecPath);

export interface HttpServerDependencies {
  services: HttpService[];
  runnableDependencies?: RunnableModule[];
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
          .then((details) => ({ ...details, name: service.name }))
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

  private checkReqVersion(version: string) {
    const [major, minor] = version.split('.');
    const versionRegex = new RegExp(`^${major}\\.(\\d+)\\.\\d+`);

    return (req: express.Request, res: express.Response, next: express.NextFunction) => {
      const match = req.baseUrl.match(versionRegex);

      if (match) {
        const [requestMinor] = match.slice(1).map(Number);
        if (requestMinor <= Number(minor)) {
          return next();
        }
      }

      return res
        .status(400)
        .send(
          `Unsupported version at ${req.baseUrl}. Supported versions are between ${major}.0.* and ${major}.${minor}.*`
        );
    };
  }

  protected async initializeImpl(): Promise<void> {
    this.app = express();

    if (this.#config.allowedOrigins) {
      this.app.use(cors(corsOptions(new Set(this.#config.allowedOrigins))));
    }

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

    if (this.#dependencies.runnableDependencies) {
      for (const dependency of this.#dependencies.runnableDependencies) await dependency.initialize();
    }

    for (const service of this.#dependencies.services) {
      await service.initialize();
      const serviceVersionPath = service.apiVersionPath();
      const majorVersion = serviceVersionPath.split('.')[0];
      const serviceBaseUrlRegex = new RegExp(`^${majorVersion}\\.\\d+\\.\\d+\\/${service.slug}`);
      this.app.use(serviceBaseUrlRegex, this.checkReqVersion(serviceVersionPath), service.router);
      this.logger.info(`Using ${serviceBaseUrlRegex}. Version: ${serviceVersionPath}`);
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    this.app.use((err: any, _req: express.Request, res: express.Response, _n: express.NextFunction) => {
      if (err instanceof ProviderError) {
        HttpServer.sendJSON(res, err, providerFailureToStatusCodeMap[err.reason]);
      } else {
        this.logger.error(err);
        HttpServer.sendJSON(res, new ProviderError(ProviderFailure.Unhealthy, err), err.status || 500);
      }
    });

    this.app.use(
      OpenApiValidator.middleware({
        apiSpec: apiSpecPath,
        ignoreUndocumented: true,
        validateRequests: true,
        validateResponses: process.env.NODE_ENV !== 'production'
      })
    );

    const serverMetadataHandler = async (_: express.Request, res: express.Response) => {
      this.logger.debug('/meta');
      return HttpServer.sendJSON(res, this.#config.meta);
    };

    const handlers = {
      health: async (_: express.Request, res: express.Response) => {
        this.logger.debug('/health');
        let health: ServicesHealthCheckResponse | Error['message'];
        try {
          health = await this.#getServicesHealth();
          return HttpServer.sendJSON(res, health, 200);
        } catch (error) {
          this.logger.error(error);
          return HttpServer.sendJSON(res, new ProviderError(ProviderFailure.Unhealthy, error), 500);
        }
      },
      live: async (_: express.Request, res: express.Response) => {
        this.logger.debug('/live');
        return res.sendStatus(200);
      },
      meta: serverMetadataHandler,
      ready: async (_: express.Request, res: express.Response) => {
        this.logger.debug('/ready');
        let health: ServicesHealthCheckResponse | Error['message'];
        try {
          health = await this.#getServicesHealth();
          res.sendStatus(health.ok ? 200 : 503);
        } catch (error) {
          this.logger.error(error);
          res.sendStatus(500);
        }
      }
    };

    let handler: keyof typeof handlers;
    for (handler in handlers) this.app.use(path.join(versionPath, handler), handlers[handler]);
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
    if (this.#dependencies.runnableDependencies) {
      for (const dependency of this.#dependencies.runnableDependencies) await dependency.start();
    }
    for (const service of this.#dependencies.services) await service.start();
    this.server = await listenPromise(this.app, this.#config.listen);
  }

  protected async shutdownImpl(): Promise<void> {
    this.#healthGauge?.set(0);

    for (const service of this.#dependencies.services) await service.shutdown();
    if (this.#dependencies.runnableDependencies) {
      for (const dependency of this.#dependencies.runnableDependencies) await dependency.shutdown();
    }

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
        buckets: [0.003, 0.03, 0.1, 0.3, 0.75, 1.5, 3, 5, 8, 12, 20, 30],
        includeMethod: true,
        includePath: true,
        promRegistry,
        ...this.#config.metrics?.options,
        metricsPath: path.join(versionPath, this.#config.metrics?.options?.metricsPath || '/metrics')
      })
    );
    this.logger.info(
      `Prometheus metrics: ${(await promRegistry.getMetricsAsArray()).map(({ name }) => name)} configured at ${
        this.#config.metrics?.options?.metricsPath || '/metrics'
      }`
    );
  }
}
