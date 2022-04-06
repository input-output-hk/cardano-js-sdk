import {
  APPLICATION_JSON,
  CONTENT_TYPE,
  HttpServer,
  HttpServerConfig,
  HttpServerDependencies,
  RunnableModule
} from '../../src';
import { getRandomPort } from 'get-port-please';
import { util } from '@cardano-sdk/core';
import express from 'express';
import got from 'got';
import net from 'net';
import waitOn from 'wait-on';

const onHttpServer = (url: string) => waitOn({ resources: [url], validateStatus: (statusCode) => statusCode === 404 });

class SomeHttpServer extends HttpServer {
  private constructor(config: HttpServerConfig, dependencies: HttpServerDependencies) {
    super({ ...config, name: 'SomeHttpServer' }, dependencies);
  }
  static create(config: HttpServerConfig, initialize?: (router: express.Router) => void) {
    const router = express.Router();
    if (initialize) initialize(router);
    return new SomeHttpServer(config, {
      healthCheck: () => Promise.resolve({ ok: true }),
      router
    });
  }
  publicSendJSON(res: express.Response, obj: unknown) {
    HttpServer.sendJSON(res, obj);
  }
}

describe('HttpServer', () => {
  let httpServer: SomeHttpServer;
  let port: number;
  let apiUrlBase: string;

  it('Is a runnable module', async () => {
    port = await getRandomPort();
    httpServer = SomeHttpServer.create({ listen: { host: 'localhost', port } });
    expect(httpServer).toBeInstanceOf(RunnableModule);
  });

  beforeEach(async () => {
    port = await getRandomPort();
    apiUrlBase = `http://localhost:${port}`;
  });

  describe('initialize', () => {
    it('initializes the express application', async () => {
      httpServer = SomeHttpServer.create({ listen: { host: 'localhost', port } });
      expect(httpServer.app).not.toBeDefined();
      await httpServer.initialize();
      expect(httpServer.app).toBeDefined();
    });

    it('uses core serializableObject with body parser', async () => {
      const expectedBody = {
        bigint: 123n
      };
      httpServer = SomeHttpServer.create({ listen: { host: 'localhost', port } }, (router) => {
        router.post('/echo', (req, res) => {
          expect(req.body).toEqual(expectedBody);
          res.send();
        });
      });
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
      await got.post(`${apiUrlBase}/echo`, {
        body: JSON.stringify(util.toSerializableObject(expectedBody)),
        headers: { [CONTENT_TYPE]: APPLICATION_JSON }
      });
      await httpServer.shutdown();
    });
  });

  describe('sendJSON', () => {
    it('sets content-type and transforms the object using toSerializableObj', () => {
      httpServer = SomeHttpServer.create({ listen: { host: 'localhost', port } });
      const obj = {
        bigint: 123n
      };
      const res = {
        header: jest.fn(),
        send: jest.fn().mockImplementation((json) => {
          expect(util.fromSerializableObject(JSON.parse(json))).toEqual(obj);
        })
      };
      httpServer.publicSendJSON(res as unknown as express.Response, obj);
      expect(res.send).toBeCalledTimes(1);
      expect(res.header).toBeCalledTimes(1);
    });
  });

  describe('start', () => {
    beforeEach(async () => {
      httpServer = SomeHttpServer.create({ listen: { host: 'localhost', port } });
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
      httpServer = SomeHttpServer.create({ listen: { host: 'localhost', port } });
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
      httpServer = SomeHttpServer.create({ listen: { host: 'localhost', port } });
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
      httpServer = SomeHttpServer.create({ listen: { host: 'localhost', port } });
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
      const res2 = await got(`${apiUrlBase}/metrics`, {
        headers: { [CONTENT_TYPE]: APPLICATION_JSON },
        throwHttpErrors: false
      });
      expect(res2.statusCode).toBe(404);
    });

    it('can expose Prometheus metrics, at /metrics by default', async () => {
      httpServer = SomeHttpServer.create({ listen: { port }, metrics: { enabled: true } });
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
      const res = await got(`${apiUrlBase}/metrics`, {
        headers: { [CONTENT_TYPE]: APPLICATION_JSON }
      });
      expect(res.statusCode).toBe(200);
      expect(typeof res.body).toBe('string');
    });

    it('Prometheus metrics can be configured with prom-client options', async () => {
      const metricsPath = '/metrics-custom';
      httpServer = SomeHttpServer.create({
        listen: { port },
        metrics: { enabled: true, options: { metricsPath } }
      });
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
      const res = await got(`${apiUrlBase}${metricsPath}`, {
        headers: { [CONTENT_TYPE]: APPLICATION_JSON }
      });
      expect(res.statusCode).toBe(200);
      expect(typeof res.body).toBe('string');
    });
  });

  describe('HTTP API', () => {
    beforeEach(async () => {
      httpServer = SomeHttpServer.create({ listen: { host: 'localhost', port } });
      await httpServer.initialize();
      await httpServer.start();
      await onHttpServer(apiUrlBase);
    });

    afterEach(async () => {
      await httpServer.shutdown();
    });

    it('health', async () => {
      const res = await got(`${apiUrlBase}/health`, {
        headers: { [CONTENT_TYPE]: 'application/json' }
      });
      expect(res.statusCode).toBe(200);
      expect(JSON.parse(res.body)).toEqual({ ok: true });
    });
  });
});
