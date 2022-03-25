import { HttpServer, RunnableModule } from '../../src';
import { getRandomPort } from 'get-port-please';
import express from 'express';
import got from 'got';
import net from 'net';
const bodyParser = require('body-parser');

class SomeHttpServer extends HttpServer {
  private constructor(config: net.ListenOptions, router: express.Router) {
    super({ listen: config, name: 'SomeHttpServer', router });
  }
  static create(config: net.ListenOptions) {
    const router = express.Router();
    router.use(bodyParser.json());
    router.get('/health', (_req, res) => {
      res.send({ ok: true });
    });
    return new SomeHttpServer(config, router);
  }
}

describe('HttpServer', () => {
  let httpServer: HttpServer;
  let port: number;
  let apiUrlBase: string;

  it('Is a runnable module', async () => {
    port = await getRandomPort();
    httpServer = SomeHttpServer.create({ host: 'localhost', port });
    expect(httpServer).toBeInstanceOf(RunnableModule);
  });

  beforeEach(async () => {
    port = await getRandomPort();
    apiUrlBase = `http://localhost:${port}`;
    httpServer = SomeHttpServer.create({ host: 'localhost', port });
  });

  describe('initialize', () => {
    it('initializes the express application', async () => {
      expect(httpServer.app).not.toBeDefined();
      await httpServer.initialize();
      expect(httpServer.app).toBeDefined();
    });
  });

  describe('start', () => {
    beforeEach(async () => {
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
    beforeEach(async () => {
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

  describe('HTTP API', () => {
    beforeEach(async () => {
      await httpServer.initialize();
      await httpServer.start();
    });

    afterEach(async () => {
      await httpServer.shutdown();
    });

    it('health', async () => {
      const res = await got(`${apiUrlBase}/health`, {
        headers: { 'Content-Type': 'application/json' }
      });
      expect(res.statusCode).toBe(200);
      expect(JSON.parse(res.body)).toEqual({ ok: true });
    });
  });
});
