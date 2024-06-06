/* eslint-disable max-params */
/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable @typescript-eslint/no-empty-function */

import {
  APPLICATION_JSON,
  CONTENT_TYPE,
  DbSyncUtxoProvider,
  HttpServer,
  HttpService,
  InMemoryCache,
  ORIGIN,
  ServiceNames,
  UNLIMITED_CACHE_TTL
} from '../../src/index.js';
import { Cardano } from '@cardano-sdk/core';
import { Pool } from 'pg';
import { RunnableModule, fromSerializableObject, toSerializableObject } from '@cardano-sdk/util';
import { baseVersionPath, serverStarted } from '../util.js';
import { createLogger, logger } from '@cardano-sdk/util-dev';
import { findLedgerTip } from '../../src/util/DbSyncProvider/index.js';
import { getRandomPort } from 'get-port-please';
import { healthCheckResponseMock, mockCardanoNode } from '../../../core/test/CardanoNode/mocks.js';
import { versionPathFromSpec } from '../../src/util/openApi.js';
import axios from 'axios';
import express from 'express';
import path from 'path';
import type { LedgerTipModel } from '../../src/util/DbSyncProvider/index.js';
import type { Logger } from 'ts-log';
import type { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import type { Provider } from '@cardano-sdk/core';
import type { ServerMetadata } from '../../src/index.js';
import type net from 'net';

const apiSpec = path.join(__dirname, 'openApi.json');
const someServiceVersionPath = versionPathFromSpec(apiSpec);

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
    super(name, provider, router, __dirname, logger);
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
  let serviceUrlBase: string;
  let provider: Provider;
  let cardanoNode: OgmiosCardanoNode;
  let lastBlockNoInDb: Cardano.BlockNo;

  const dbPools = {
    healthCheck: new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC }),
    main: new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC })
  };
  const headers = { [CONTENT_TYPE]: APPLICATION_JSON };
  const cache = { db: new InMemoryCache(UNLIMITED_CACHE_TTL), healthCheck: new InMemoryCache(UNLIMITED_CACHE_TTL) };

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
    apiUrlBase = `http://localhost:${port}${baseVersionPath}`;
    serviceUrlBase = `http://localhost:${port}${someServiceVersionPath}`;
    lastBlockNoInDb = Cardano.BlockNo((await dbPools.main.query<LedgerTipModel>(findLedgerTip)).rows[0].block_no);
    cardanoNode = mockCardanoNode(
      healthCheckResponseMock({ blockNo: lastBlockNoInDb })
    ) as unknown as OgmiosCardanoNode;
    provider = new DbSyncUtxoProvider({ cache, cardanoNode, dbPools, logger });
  });

  afterAll(() => Promise.all([dbPools.healthCheck.end(), dbPools.main.end()]));

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
      await serverStarted(apiUrlBase);
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
      await serverStarted(apiUrlBase);
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
      await serverStarted(apiUrlBase);
      await axios.post(
        `${serviceUrlBase}/${ServiceNames.StakePool}/echo`,
        JSON.stringify(toSerializableObject(expectedBody)),
        { headers }
      );
    });

    it('correctly logs requests', async () => {
      const testLogger = createLogger({ record: true });
      const expectedBody = { bigint: 23n, check: 'ok', test: 42 };
      const expectedQuery = { bigint: '23', check: 'ok', test: '42' };
      const url = `${serviceUrlBase}/${ServiceNames.StakePool}/echo`;
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
      await serverStarted(apiUrlBase);
      await axios.post(url, JSON.stringify(toSerializableObject(expectedBody)), { headers });
      await axios.get(url, { params: expectedBody });
      expect(
        testLogger.messages
          .filter(({ level, message }) => level === 'debug' && message[0] === '[HttpServer|request]')
          .map(({ message: [, requestDetails] }) => requestDetails)
      ).toEqual([
        { body: {}, method: 'HEAD', path: baseVersionPath, query: {} },
        {
          body: { bigint: 23n, check: 'ok', test: 42 },
          method: 'POST',
          // Note: `.replaceAll(path.sep, '/')` is needed on Windows:
          path: path.join(someServiceVersionPath, 'stake-pool', 'echo').replaceAll(path.sep, '/'),
          query: {}
        },
        {
          body: {},
          method: 'GET',
          // Note: `.replaceAll(path.sep, '/')` is needed on Windows:
          path: path.join(someServiceVersionPath, 'stake-pool', 'echo').replaceAll(path.sep, '/'),
          query: { bigint: '23', check: 'ok', test: '42' }
        }
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

  describe('api version checks', () => {
    let major: number;
    let minor: number;
    let patch: number;
    beforeEach(async () => {
      const v = someServiceVersionPath
        .match(/v(\d+)\.(\d+)\.(\d+)/)!
        .slice(1)
        .map(Number);
      major = v[0];
      minor = v[1];
      patch = v[2];

      httpServer = new HttpServer(
        { listen: { host: 'localhost', port } },
        {
          logger,
          runnableDependencies: [cardanoNode],
          services: [new SomeHttpService(ServiceNames.StakePool, provider, logger, express.Router(), () => {})]
        }
      );
      await httpServer.initialize();
      await httpServer.start();
      await serverStarted(apiUrlBase);
    });

    afterEach(() => httpServer.shutdown());

    it('accept smaller minor version', async () => {
      serviceUrlBase = `http://localhost:${port}/v${major}.${minor - 1}.${patch}`;
      await expect(
        axios.post(`${serviceUrlBase}/${ServiceNames.StakePool}/echo`, {}, { headers })
      ).resolves.toBeTruthy();
    });

    it('reject higher minor version', async () => {
      serviceUrlBase = `http://localhost:${port}/v${major}.${minor + 1}.${patch}`;
      await expect(axios.post(`${serviceUrlBase}/${ServiceNames.StakePool}/echo`, {}, { headers })).rejects.toThrow();
    });

    it('reject different major version', async () => {
      serviceUrlBase = `http://localhost:${port}/v${major - 1}.${minor}.${patch}`;
      await expect(axios.post(`${serviceUrlBase}/${ServiceNames.StakePool}/echo`, {}, { headers })).rejects.toThrow();
    });

    it('accept any patch version', async () => {
      serviceUrlBase = `http://localhost:${port}/v${major}.${minor}.${patch + 1}`;
      await expect(
        axios.post(`${serviceUrlBase}/${ServiceNames.StakePool}/echo`, {}, { headers })
      ).resolves.toBeTruthy();
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
      if (addressInfo.family === 'IPv6') {
        expect(addressInfo.address).toBe('::1');
      } else {
        expect(addressInfo.address).toBe('127.0.0.1');
      }
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
      await serverStarted(apiUrlBase);
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
      await serverStarted(apiUrlBase);
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
      await serverStarted(apiUrlBase);
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
      await serverStarted(apiUrlBase);
      const response = await axios.get(`${apiUrlBase}/metrics`, { headers });
      expect(response.status).toBe(200);
      expect(response.data.includes('healthcheck 1')).toEqual(true);
      expect(response.data.includes('node_sync_percentage')).toEqual(true);
      expect(response.data.includes('projection_sync_percentage')).toEqual(true);
    });
    it('metrics endpoint with unhealthy service', async () => {
      const service = new SomeHttpService(ServiceNames.StakePool, provider, logger);
      httpServer = new HttpServer(
        { listen: { host: 'localhost', port }, metrics: { enabled: true } },
        { logger, runnableDependencies: [cardanoNode], services: [service] }
      );
      await httpServer.initialize();
      await httpServer.start();
      await serverStarted(apiUrlBase);
      service.healthCheck = async () => Promise.resolve({ ok: false });
      const response = await axios.get(`${apiUrlBase}/metrics`, { headers });
      expect(response.status).toBe(200);
      expect(response.data.includes('healthcheck 0')).toEqual(true);
    });
  });

  describe('live endpoint', () => {
    afterEach(async () => {
      await httpServer.shutdown();
    });

    it('/live endpoint returns a 200 coded response, if the server is running, for GET and POST requests', async () => {
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
      await serverStarted(apiUrlBase);

      const resGet = await axios.get(`${apiUrlBase}/live`);
      const resPost = await axios.post(`${apiUrlBase}/live`);

      expect(resGet.status).toBe(200);
      expect(resPost.status).toBe(200);
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
    });
    afterEach(async () => {
      await httpServer.shutdown();
    });
    it('healthy', async () => {
      const res = await axios.post(`${serviceUrlBase}/${ServiceNames.StakePool}/health`, {
        headers: { [CONTENT_TYPE]: 'application/json' }
      });
      expect(res.status).toBe(200);
      expect(res.data).toEqual({ ok: true });
    });
    it('not healthy', async () => {
      const res = await axios.post(`${serviceUrlBase}/${ServiceNames.NetworkInfo}/health`, {
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
      await serverStarted(apiUrlBase);
      const res = await axios.get(`${apiUrlBase}/health`);
      const readyRes = await axios.get(`${apiUrlBase}/ready`);
      expect(res.status).toBe(200);
      expect(readyRes.status).toBe(200);
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

      const res = await axios.post(`${apiUrlBase}/health`, {
        headers: { [CONTENT_TYPE]: 'application/json' }
      });
      const readyRes = await axios.get(`${apiUrlBase}/ready`, {
        validateStatus: () => true
      });
      expect(res.status).toBe(200);
      expect(readyRes.status).toBe(503);
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

  describe('Server metadata', () => {
    const metaEndpoint = 'meta';

    afterEach(async () => {
      await httpServer.shutdown();
    });

    it('/meta endpoint returns a 200 coded response with a valid metadata', async () => {
      const meta: ServerMetadata = {
        extra: JSON.parse(
          '{"narHash": "sha256-PN60Ot9hQZIwh4LRgnPd8iiq9F3hFNXP7PYVpBlM9TQ=", "path":"/nix/store/i0sgvj906qpzw1bk7h8b3vij0z477ff6-source"}'
        ),
        lastModified: 1_666_954_298,
        lastModifiedDate: '20_221_028_105_138',
        rev: '65d78fc015bf7bd856c5febe0ba84d3ad18a069c',
        shortRev: '65d78fc',
        startupTime: 1_234_566
      };

      httpServer = new HttpServer(
        { listen: { host: 'localhost', port }, meta },
        {
          logger,
          runnableDependencies: [cardanoNode],
          services: [new SomeHttpService(ServiceNames.StakePool, provider, logger)]
        }
      );

      await httpServer.initialize();
      await httpServer.start();
      await serverStarted(apiUrlBase);

      const res = await axios.get<ServerMetadata>(`${apiUrlBase}/${metaEndpoint}`, {
        headers: { [CONTENT_TYPE]: 'application/json' }
      });

      expect(res.status).toBe(200);
      expect(res.data).toMatchObject(meta);
    });
  });

  describe('CORS', () => {
    const allowedOrigin = 'http://cardano.com';
    const unknownOrigin = 'http://cardano2.com';

    afterEach(async () => {
      await httpServer.shutdown();
    });

    it('allows requests from all origins when allowed origins config is not specified', async () => {
      httpServer = new HttpServer(
        { allowedOrigins: undefined, listen: { host: 'localhost', port } },
        {
          logger,
          runnableDependencies: [cardanoNode],
          services: [new SomeHttpService(ServiceNames.Utxo, provider, logger)]
        }
      );

      await httpServer.initialize();
      await httpServer.start();
      await serverStarted(apiUrlBase);

      const res = await axios.get(`${apiUrlBase}/health`, {
        headers: { [CONTENT_TYPE]: 'application/json' }
      });

      expect(res.status).toBe(200);
      expect(res.data).toBeDefined();
    });

    it('mirrors "origin" header in "access-control-allow-origin" if it matches an allowed origin', async () => {
      httpServer = new HttpServer(
        { allowedOrigins: [allowedOrigin], listen: { host: 'localhost', port } },
        {
          logger,
          runnableDependencies: [cardanoNode],
          services: [new SomeHttpService(ServiceNames.Utxo, provider, logger)]
        }
      );

      await httpServer.initialize();
      await httpServer.start();
      await serverStarted(apiUrlBase, 404, { [ORIGIN]: allowedOrigin });

      const res = await axios.get(`${apiUrlBase}/health`, {
        headers: { [CONTENT_TYPE]: 'application/json', [ORIGIN]: allowedOrigin }
      });

      expect(res.headers['access-control-allow-origin']).toEqual(allowedOrigin);
    });

    it('allows requests with no origin header', async () => {
      httpServer = new HttpServer(
        { allowedOrigins: [allowedOrigin], listen: { host: 'localhost', port } },
        {
          logger,
          runnableDependencies: [cardanoNode],
          services: [new SomeHttpService(ServiceNames.Utxo, provider, logger)]
        }
      );

      await httpServer.initialize();
      await httpServer.start();
      await serverStarted(apiUrlBase, 404, { [ORIGIN]: allowedOrigin });

      const res = await axios.get(`${apiUrlBase}/health`, {
        headers: { [CONTENT_TYPE]: 'application/json' }
      });

      expect(res.status).toBe(200);
      expect(res.data).toBeDefined();
    });

    it('rejects requests from disallowed origins', async () => {
      httpServer = new HttpServer(
        { allowedOrigins: [allowedOrigin], listen: { host: 'localhost', port } },
        {
          logger,
          runnableDependencies: [cardanoNode],
          services: [new SomeHttpService(ServiceNames.Utxo, provider, logger)]
        }
      );

      await httpServer.initialize();
      await httpServer.start();
      await serverStarted(apiUrlBase, 404, { [ORIGIN]: allowedOrigin });

      try {
        await axios.get(`${apiUrlBase}/health`, {
          headers: { [CONTENT_TYPE]: 'application/json', [ORIGIN]: unknownOrigin }
        });
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
      } catch (error: any) {
        expect(error.response.status).toBe(403);
        expect(error.response.statusText).toBe('Forbidden');
      }
    });
  });
});
