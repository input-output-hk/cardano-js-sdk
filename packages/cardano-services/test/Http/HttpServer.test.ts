import { APPLICATION_JSON, CONTENT_TYPE, DbSyncUtxoProvider, HttpServer, HttpService, RunnableModule } from '../../src';
import { Logger, dummyLogger as logger } from 'ts-log';
import { Pool } from 'pg';
import { Provider } from '@cardano-sdk/core';
import { fromSerializableObject, toSerializableObject } from '@cardano-sdk/util';
import { getRandomPort } from 'get-port-please';
import axios from 'axios';
import express from 'express';
import net from 'net';
import waitOn from 'wait-on';

const onHttpServer = (url: string) => waitOn({ resources: [url], validateStatus: (statusCode) => statusCode === 404 });

class SomeHttpService extends HttpService {
  constructor(
    provider: Provider,
    // eslint-disable-next-line @typescript-eslint/no-shadow
    logger: Logger,
    router: express.Router = express.Router(),
    assertReq?: (req: express.Request) => void
  ) {
    super('some-http-service', provider, router, logger);

    router.post('/echo', (req, res) => {
      logger.debug(req.body);
      assertReq!(req);
      HttpServer.sendJSON(res, req.body);
    });
  }

  async healthCheck() {
    return Promise.resolve({ ok: true });
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
  const db = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING });

  it('Is a runnable module', async () => {
    port = await getRandomPort();
    httpServer = new HttpServer(
      { listen: { host: 'localhost', port } },
      { logger, services: [new SomeHttpService(provider, logger)] }
    );
    expect(httpServer).toBeInstanceOf(RunnableModule);
  });

  beforeEach(async () => {
    port = await getRandomPort();
    apiUrlBase = `http://localhost:${port}`;
    provider = new DbSyncUtxoProvider(db, logger);
  });

  describe('initialize', () => {
    it('initializes the express application', async () => {
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port } },
        { logger, services: [new SomeHttpService(provider, logger)] }
      );
      expect(httpServer.app).not.toBeDefined();
      await httpServer.initialize();
      expect(httpServer.app).toBeDefined();
    });

    it('uses core serializableObject with body parser', async () => {
      const expectedBody = { bigint: 123n };
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port } },
        {
          logger,
          services: [
            new SomeHttpService(provider, logger, express.Router(), (req: express.Request) =>
              expect(req.body).toEqual(expectedBody)
            )
          ]
        }
      );
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
      await axios.post(`${apiUrlBase}/some-http-service/echo`, JSON.stringify(toSerializableObject(expectedBody)), {
        headers: { [CONTENT_TYPE]: APPLICATION_JSON }
      });
      await httpServer.shutdown();
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
        { logger, services: [new SomeHttpService(provider, logger)] }
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
    beforeEach(async () => {
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port } },
        { logger, services: [new SomeHttpService(provider, logger)] }
      );
      await httpServer.initialize();
      await httpServer.start();
    });

    it('closes the server', async () => {
      expect(httpServer.state).toBe('running');
      const spy = jest.fn();
      httpServer.server.on('close', spy);
      await httpServer.shutdown();
      expect(httpServer.state).toBe('initialized');
      expect(spy).toHaveBeenCalled();
    });
  });

  describe('restarting', () => {
    // eslint-disable-next-line sonarjs/no-identical-functions
    beforeEach(async () => {
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port } },
        { logger, services: [new SomeHttpService(provider, logger)] }
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
        { logger, services: [new SomeHttpService(provider, logger)] }
      );
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
      const res2 = await axios.get(`${apiUrlBase}/some-http-service/metrics`, {
        headers: { [CONTENT_TYPE]: APPLICATION_JSON },
        validateStatus: null
      });
      expect(res2.status).toBe(404);
    });

    it('can expose Prometheus metrics, at /metrics by default', async () => {
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port }, metrics: { enabled: true } },
        { logger, services: [new SomeHttpService(provider, logger)] }
      );
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
      const res = await axios.get(`${apiUrlBase}/metrics`, {
        headers: { [CONTENT_TYPE]: APPLICATION_JSON }
      });
      expect(res.status).toBe(200);
      expect(typeof res.data).toBe('string');
    });

    it('Prometheus metrics can be configured with prom-client options', async () => {
      const metricsPath = '/metrics-custom';
      httpServer = new HttpServer(
        { listen: { port }, metrics: { enabled: true, options: { metricsPath } } },
        { logger, services: [new SomeHttpService(provider, logger)] }
      );
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
      const res = await axios.get(`${apiUrlBase}${metricsPath}`, {
        headers: { [CONTENT_TYPE]: APPLICATION_JSON }
      });
      expect(res.status).toBe(200);
      expect(typeof res.data).toBe('string');
    });
  });

  describe('HTTP API', () => {
    beforeEach(async () => {
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port } },
        { logger, services: [new SomeHttpService(provider, logger)] }
      );
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
    });

    afterEach(async () => {
      await httpServer.shutdown();
    });

    it('health', async () => {
      const res = await axios.post(`${apiUrlBase}/some-http-service/health`, {
        headers: { [CONTENT_TYPE]: 'application/json' }
      });
      expect(res.status).toBe(200);
      expect(res.data).toEqual({ ok: true });
    });
  });
});
