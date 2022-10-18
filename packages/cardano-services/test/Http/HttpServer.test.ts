/* eslint-disable max-params */
/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable @typescript-eslint/no-empty-function */

import { APPLICATION_JSON, CONTENT_TYPE, DbSyncUtxoProvider, HttpServer, HttpService, ServiceNames } from '../../src';
import { BlockNoModel, findLastBlockNo } from '../../src/util/DbSyncProvider';
import { Cardano, Provider } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { RunnableModule, fromSerializableObject, toSerializableObject } from '@cardano-sdk/util';
import { createLogger, logger } from '@cardano-sdk/util-dev';
import { getRandomPort } from 'get-port-please';
import { healthCheckResponseMock, mockCardanoNode } from '../../../core/test/CardanoNode/mocks';
import axios from 'axios';
import express from 'express';
import net from 'net';
import waitOn from 'wait-on';
const headers = { [CONTENT_TYPE]: APPLICATION_JSON };
const onHttpServer = (url: string) => waitOn({ resources: [url], validateStatus: (statusCode) => statusCode === 404 });
class SomeHttpService extends HttpService {
  shouldFail?: boolean;
  constructor(
    name: ServiceNames,
    provider: Provider,
    // eslint-disable-next-line @typescript-eslint/no-shadow
    logger: Logger,
    router: express.Router = express.Router(),
    assertReq?: (req: express.Request) => void,
    shouldFail?: boolean
  ) {
    super(name, provider, router, logger);
    this.shouldFail = shouldFail;
    router.all('/echo', (req, res) => {
      logger.debug(req.body);
      assertReq!(req);
      HttpServer.sendJSON(res, req.body);
    });
  }
  async healthCheck() {
    return this.shouldFail ? Promise.resolve({ ok: false }) : Promise.resolve({ ok: true });
  }
  async initializeImpl(): Promise<void> {
    await this.healthCheck();
  }
}
describe('HttpServer', () => {
  let httpServer: HttpServer;
  let port: number;
  let apiUrlBase: string;
  let provider: Provider;
  let cardanoNode: OgmiosCardanoNode;
  let lastBlockNoInDb: Cardano.BlockNo;
  const db = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING });

  it('Is a runnable module', async () => {
    port = await getRandomPort();
    httpServer = new HttpServer(
      { listen: { host: 'localhost', port } },
      { logger, runnableDependencies: [], services: [new SomeHttpService(ServiceNames.StakePool, provider, logger)] }
    );
    expect(httpServer).toBeInstanceOf(RunnableModule);
  });

  beforeEach(async () => {
    port = await getRandomPort();
    apiUrlBase = `http://localhost:${port}`;
    lastBlockNoInDb = (await db.query<BlockNoModel>(findLastBlockNo)).rows[0].block_no;
    cardanoNode = mockCardanoNode(
      healthCheckResponseMock({ blockNo: lastBlockNoInDb })
    ) as unknown as OgmiosCardanoNode;
    provider = new DbSyncUtxoProvider({ cardanoNode, db, logger });
  });

  describe('initialize', () => {
    afterEach(() => httpServer.shutdown());
    it('initializes the express application', async () => {
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port } },
        {
          logger,
          runnableDependencies: [cardanoNode],
          services: [new SomeHttpService(ServiceNames.StakePool, provider, logger)]
        }
      );
      expect(httpServer.app).not.toBeDefined();
      await httpServer.initialize();
      expect(httpServer.app).toBeDefined();
      expect(cardanoNode.initialize).toHaveBeenCalledTimes(1);
      await httpServer.start();
      await onHttpServer(apiUrlBase);
    });

    it('should not initialize the runnable dependencies if there are not any', async () => {
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port } },
        {
          logger,
          runnableDependencies: [],
          services: [new SomeHttpService(ServiceNames.StakePool, provider, logger)]
        }
      );
      await httpServer.initialize();
      expect(cardanoNode.initialize).toHaveBeenCalledTimes(0);
      await httpServer.start();
      await onHttpServer(apiUrlBase);
    });

    it('uses core serializableObject with body parser', async () => {
      const expectedBody = { bigint: 123n };
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port } },
        {
          logger,
          runnableDependencies: [cardanoNode],
          services: [
            new SomeHttpService(ServiceNames.StakePool, provider, logger, express.Router(), (req: express.Request) =>
              expect(req.body).toEqual(expectedBody)
            )
          ]
        }
      );
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
      await axios.post(
        `${apiUrlBase}/${ServiceNames.StakePool}/echo`,
        JSON.stringify(toSerializableObject(expectedBody)),
        { headers }
      );
    });
    it('correctly logs requests', async () => {
      const testLogger = createLogger({ record: true });
      const expectedBody = { bigint: 23n, check: 'ok', test: 42 };
      const expectedQuery = { bigint: '23', check: 'ok', test: '42' };
      const url = `${apiUrlBase}/${ServiceNames.StakePool}/echo`;
      let requestCounter = 0;
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port } },
        {
          logger: testLogger,
          runnableDependencies: [cardanoNode],
          services: [
            new SomeHttpService(ServiceNames.StakePool, provider, logger, express.Router(), (req: express.Request) => {
              if (requestCounter++ === 0) return expect(req.body).toEqual(expectedBody);
              expect(req.query).toEqual(expectedQuery);
            })
          ]
        }
      );
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
      await axios.post(url, JSON.stringify(toSerializableObject(expectedBody)), { headers });
      await axios.get(url, { params: expectedBody });
      expect(
        testLogger.messages
          .filter(({ level, message }) => level === 'debug' && message[0] === '[HttpServer|request]')
          .map(({ message: [, requestDetails] }) => requestDetails)
      ).toEqual([
        { body: {}, method: 'HEAD', path: '/', query: {} },
        { body: { bigint: 23n, check: 'ok', test: 42 }, method: 'POST', path: '/stake-pool/echo', query: {} },
        { body: {}, method: 'GET', path: '/stake-pool/echo', query: { bigint: '23', check: 'ok', test: '42' } }
      ]);
    });
  });
  describe('sendJSON', () => {
    it('sets content-type and transforms the object using toSerializableObj', () => {
      const obj = {
        bigint: 123n
      };
      const res = {
        header: jest.fn(),
        send: jest.fn().mockImplementation((json) => {
          expect(fromSerializableObject(json)).toEqual(obj);
        })
      };
      HttpServer.sendJSON(res as unknown as express.Response, obj);
      expect(res.send).toBeCalledTimes(1);
      expect(res.header).toBeCalledTimes(1);
    });
  });
  describe('start', () => {
    beforeEach(async () => {
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port } },
        {
          logger,
          runnableDependencies: [cardanoNode],
          services: [new SomeHttpService(ServiceNames.StakePool, provider, logger)]
        }
      );
      await httpServer.initialize();
    });
    afterEach(async () => {
      await httpServer.shutdown();
    });
    it('starts the express application, attaching the server to the public property', async () => {
      expect(httpServer.state).toBe('initialized');
      expect(httpServer.server).not.toBeDefined();
      await httpServer.start();
      expect(httpServer.state).toBe('running');
      expect(httpServer.server).toBeDefined();
      const addressInfo = httpServer.server.address() as net.AddressInfo;
      expect(addressInfo.port).toBe(port);
      expect(addressInfo.address).toBe('127.0.0.1');
    });
  });
  describe('shutdown', () => {
    it('closes the server', async () => {
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port } },
        {
          logger,
          runnableDependencies: [cardanoNode],
          services: [new SomeHttpService(ServiceNames.StakePool, provider, logger)]
        }
      );

      await httpServer.initialize();
      await httpServer.start();
      expect(httpServer.state).toBe('running');
      const spy = jest.fn();
      httpServer.server.on('close', spy);
      await httpServer.shutdown();
      expect(httpServer.state).toBe('initialized');
      expect(cardanoNode.shutdown).toHaveBeenCalledTimes(1);
      expect(spy).toHaveBeenCalled();
    });

    it('should not shut down the runnable dependencies if there are not any', async () => {
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port } },
        {
          logger,
          runnableDependencies: [],
          services: [new SomeHttpService(ServiceNames.StakePool, provider, logger)]
        }
      );
      await httpServer.initialize();
      await httpServer.start();
      await httpServer.shutdown();
      expect(cardanoNode.shutdown).toHaveBeenCalledTimes(0);
    });
  });
  describe('restarting', () => {
    // eslint-disable-next-line sonarjs/no-identical-functions
    beforeEach(async () => {
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port } },
        {
          logger,
          runnableDependencies: [cardanoNode],
          services: [new SomeHttpService(ServiceNames.StakePool, provider, logger)]
        }
      );
      await httpServer.initialize();
      await httpServer.start();
    });
    it('can be restarted', async () => {
      expect(httpServer.state).toBe('running');
      await httpServer.shutdown();
      expect(httpServer.state).toBe('initialized');
      await httpServer.start();
      expect(httpServer.state).toBe('running');
      await httpServer.shutdown();
      expect(httpServer.state).toBe('initialized');
    });
  });
  describe('metrics', () => {
    afterEach(async () => {
      await httpServer.shutdown();
    });
    it('is disabled by default', async () => {
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port } },
        {
          logger,
          runnableDependencies: [cardanoNode],
          services: [new SomeHttpService(ServiceNames.StakePool, provider, logger)]
        }
      );
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
      const response = await axios.get(`${apiUrlBase}/${ServiceNames.StakePool}/metrics`, {
        headers,
        validateStatus: null
      });
      expect(response.status).toBe(404);
    });
    it('can expose Prometheus metrics, at /metrics by default', async () => {
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port }, metrics: { enabled: true } },
        {
          logger,
          runnableDependencies: [cardanoNode],
          services: [new SomeHttpService(ServiceNames.StakePool, provider, logger)]
        }
      );
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
      const res = await axios.get(`${apiUrlBase}/metrics`, { headers });
      expect(res.status).toBe(200);
      expect(typeof res.data).toBe('string');
    });
    it('Prometheus metrics can be configured with prom-client options', async () => {
      const metricsPath = '/metrics-custom';
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port }, metrics: { enabled: true, options: { metricsPath } } },
        {
          logger,
          runnableDependencies: [cardanoNode],
          services: [new SomeHttpService(ServiceNames.StakePool, provider, logger)]
        }
      );
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
      const response = await axios.get(`${apiUrlBase}${metricsPath}`, { headers });
      expect(response.status).toBe(200);
      expect(typeof response.data).toBe('string');
    });
    it('metrics endpoint with healthy service', async () => {
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port }, metrics: { enabled: true } },
        {
          logger,
          runnableDependencies: [cardanoNode],
          services: [new SomeHttpService(ServiceNames.StakePool, provider, logger)]
        }
      );
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
      const response = await axios.get(`${apiUrlBase}/metrics`, { headers });
      expect(response.status).toBe(200);
      expect(response.data.includes('healthcheck 1')).toEqual(true);
    });
    it('metrics endpoint with unhealthy service', async () => {
      const service = new SomeHttpService(ServiceNames.StakePool, provider, logger);
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port }, metrics: { enabled: true } },
        { logger, runnableDependencies: [cardanoNode], services: [service] }
      );
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
      service.healthCheck = async () => Promise.resolve({ ok: false });
      const response = await axios.get(`${apiUrlBase}/metrics`, { headers });
      expect(response.status).toBe(200);
      expect(response.data.includes('healthcheck 0')).toEqual(true);
    });
  });
  describe('Service health check', () => {
    const shouldFail = true;
    beforeEach(async () => {
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port } },
        {
          logger,
          runnableDependencies: [cardanoNode],
          services: [
            new SomeHttpService(ServiceNames.StakePool, provider, logger),
            new SomeHttpService(ServiceNames.NetworkInfo, provider, logger, express.Router(), () => {}, shouldFail)
          ]
        }
      );
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
    });
    afterEach(async () => {
      await httpServer.shutdown();
    });
    it('healthy', async () => {
      const res = await axios.post(`${apiUrlBase}/${ServiceNames.StakePool}/health`, {
        headers: { [CONTENT_TYPE]: 'application/json' }
      });
      expect(res.status).toBe(200);
      expect(res.data).toEqual({ ok: true });
    });
    it('not healthy', async () => {
      const res = await axios.post(`${apiUrlBase}/${ServiceNames.NetworkInfo}/health`, {
        headers: { [CONTENT_TYPE]: 'application/json' }
      });
      expect(res.status).toBe(200);
      expect(res.data).toEqual({ ok: false });
    });
  });
  describe('Root health check', () => {
    afterEach(async () => {
      await httpServer.shutdown();
    });
    it('healthy', async () => {
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port } },
        {
          logger,
          runnableDependencies: [cardanoNode],
          services: [
            new SomeHttpService(ServiceNames.StakePool, provider, logger),
            new SomeHttpService(ServiceNames.NetworkInfo, provider, logger)
          ]
        }
      );
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
      const res = await axios.post(`${apiUrlBase}/health`, {
        headers: { [CONTENT_TYPE]: 'application/json' }
      });
      expect(res.status).toBe(200);
      expect(res.data).toEqual({
        ok: true,
        services: [
          {
            name: ServiceNames.StakePool,
            ok: true
          },
          {
            name: ServiceNames.NetworkInfo,
            ok: true
          }
        ]
      });
    });
    it('not healthy', async () => {
      const shouldFail = true;
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port } },
        {
          logger,
          runnableDependencies: [cardanoNode],
          services: [
            new SomeHttpService(ServiceNames.StakePool, provider, logger),
            new SomeHttpService(ServiceNames.NetworkInfo, provider, logger, express.Router(), () => {}, shouldFail)
          ]
        }
      );
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
      const res = await axios.post(`${apiUrlBase}/health`, {
        headers: { [CONTENT_TYPE]: 'application/json' }
      });
      expect(res.status).toBe(200);
      expect(res.data).toEqual({
        ok: false,
        services: [
          {
            name: ServiceNames.StakePool,
            ok: true
          },
          {
            name: ServiceNames.NetworkInfo,
            ok: false
          }
        ]
      });
    });
  });
});
