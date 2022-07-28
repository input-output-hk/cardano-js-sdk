/* eslint-disable sonarjs/no-identical-functions */
/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable max-len */
import { Cardano, TxSubmitProvider } from '@cardano-sdk/core';
import { Connection } from '@cardano-ogmios/client';
import {
  HttpServer,
  HttpServerConfig,
  TxSubmitHttpService,
  createDnsResolver,
  getRabbitMqTxSubmitProvider,
  loadAndStartTxWorker
} from '../../../src';
import { Ogmios } from '@cardano-sdk/ogmios';
import { RunningTxSubmitWorker } from '../../../src/TxWorker/utils';
import { SrvRecord } from 'dns';
import { createLogger } from 'bunyan';
import { createMockOgmiosServer } from '../../../../ogmios/test/mocks/mockOgmiosServer';
import { dummyLogger } from 'ts-log';
import { getPort, getRandomPort } from 'get-port-please';
import { listenPromise, serverClosePromise } from '../../../src/util';
import { ogmiosServerReady } from '../../util';
import { txsPromise } from '../../../../rabbitmq/test/utils';
import { types } from 'util';
import axios from 'axios';
import http from 'http';

jest.mock('dns', () => ({
  promises: {
    resolveSrv: async (serviceName: string): Promise<SrvRecord[]> => {
      if (serviceName === process.env.OGMIOS_SRV_SERVICE_NAME)
        return [{ name: 'localhost', port: 1337, priority: 6, weight: 5 }];
      if (serviceName === process.env.RABBITMQ_SRV_SERVICE_NAME)
        return [{ name: 'localhost', port: 5672, priority: 6, weight: 5 }];
      return [];
    }
  }
}));

describe('Service dependency abstractions', () => {
  const APPLICATION_JSON = 'application/json';
  const logger = createLogger({ level: 'error', name: 'test' });
  const dnsResolver = createDnsResolver({ factor: 1.1, maxRetryTime: 1000 }, logger);

  describe('RabbitMQ-dependant service with service discovery', () => {
    let apiUrlBase: string;
    let txSubmitProvider: TxSubmitProvider;
    let httpServer: HttpServer;
    let port: number;
    let config: HttpServerConfig;

    describe('Established connection', () => {
      beforeAll(async () => {
        port = await getPort();
        apiUrlBase = `http://localhost:${port}/tx-submit`;
        config = { listen: { port } };
        txSubmitProvider = await getRabbitMqTxSubmitProvider(dnsResolver, logger, {
          rabbitmqSrvServiceName: process.env.RABBITMQ_SRV_SERVICE_NAME,
          serviceDiscoveryBackoffFactor: 1.1,
          serviceDiscoveryTimeout: 1000
        });
        httpServer = new HttpServer(config, {
          services: [new TxSubmitHttpService({ txSubmitProvider })]
        });
        await httpServer.initialize();
        await httpServer.start();
      });

      afterAll(async () => {
        await httpServer.shutdown();
      });

      it('txSubmitProvider should be instance of a Proxy ', () => {
        expect(types.isProxy(txSubmitProvider)).toEqual(true);
      });

      it('forwards the txSubmitProvider health response', async () => {
        const res = await axios.post(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
    });
  });

  describe('RabbitMQ-dependant service with static config', () => {
    let apiUrlBase: string;
    let txSubmitProvider: TxSubmitProvider;
    let httpServer: HttpServer;
    let port: number;
    let config: HttpServerConfig;

    describe('Established connection', () => {
      beforeAll(async () => {
        port = await getPort();
        apiUrlBase = `http://localhost:${port}/tx-submit`;
        config = { listen: { port } };
        txSubmitProvider = await getRabbitMqTxSubmitProvider(dnsResolver, logger, {
          rabbitmqUrl: new URL(process.env.RABBITMQ_URL!)
        });
        httpServer = new HttpServer(config, {
          services: [new TxSubmitHttpService({ txSubmitProvider })]
        });
        await httpServer.initialize();
        await httpServer.start();
      });

      afterAll(async () => {
        await httpServer.shutdown();
      });

      it('txSubmitProvider should not be a instance of Proxy ', () => {
        expect(types.isProxy(txSubmitProvider)).toEqual(false);
      });

      it('forwards the txSubmitProvider health response', async () => {
        const res = await axios.post(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
    });
  });

  describe('TxSubmitProvider with service discovery and RabbitMQ server failover', () => {
    let mockServer: http.Server;
    let connection: Connection;
    let provider: TxSubmitProvider;
    let txSubmitWorker: RunningTxSubmitWorker;
    const ogmiosPortDefault = 1337;
    const rabbitmqPortDedault = 5672;

    beforeEach(async () => {
      connection = Ogmios.createConnectionObject({ port: ogmiosPortDefault });
      // Setup working a default Ogmios with submitTx operation throwing a non-connection error
      mockServer = createMockOgmiosServer({
        healthCheck: { response: { networkSynchronization: 0.999, success: true } },
        submitTx: { response: { failWith: { type: 'eraMismatch' }, success: false } }
      });
      await listenPromise(mockServer, connection);
      await ogmiosServerReady(connection);

      txSubmitWorker = await loadAndStartTxWorker(
        {
          options: {
            loggerMinSeverity: 'error',
            ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME,
            parallel: true,
            rabbitmqSrvServiceName: process.env.RABBITMQ_SRV_SERVICE_NAME,
            serviceDiscoveryBackoffFactor: 1.1,
            serviceDiscoveryTimeout: 1000
          }
        },
        dummyLogger
      );
    });

    afterEach(async () => {
      if (mockServer !== undefined) {
        await serverClosePromise(mockServer);
      }
      if (txSubmitWorker !== undefined) {
        await txSubmitWorker.stop();
      }
    });

    it('should initially fail with a connection error, then re-resolve the port and propagate the correct non-connection error to the caller', async () => {
      const srvRecord = { name: 'localhost', port: rabbitmqPortDedault, priority: 1, weight: 1 };
      const failingRabbitMqMockPort = await getRandomPort();
      let resolverAlreadyCalled = false;

      // Initially resolves with a failing rabbitmq port, then swap to the default one
      const dnsResolverMock = jest.fn().mockImplementation(async () => {
        if (!resolverAlreadyCalled) {
          resolverAlreadyCalled = true;
          return { ...srvRecord, port: failingRabbitMqMockPort };
        }
        return srvRecord;
      });

      provider = await getRabbitMqTxSubmitProvider(dnsResolverMock, logger, {
        rabbitmqSrvServiceName: process.env.RABBITMQ_SRV_SERVICE_NAME!,
        serviceDiscoveryBackoffFactor: 1.1,
        serviceDiscoveryTimeout: 1000
      });

      const txs = await txsPromise;
      await expect(provider.submitTx(txs[0].txBodyUint8Array)).rejects.toBeInstanceOf(
        Cardano.TxSubmissionErrors.EraMismatchError
      );
      expect(dnsResolverMock).toBeCalledTimes(2);
    });

    it('should execute a provider operation without to intercept it', async () => {
      provider = await getRabbitMqTxSubmitProvider(dnsResolver, logger, {
        rabbitmqSrvServiceName: process.env.RABBITMQ_SRV_SERVICE_NAME,
        serviceDiscoveryBackoffFactor: 1.1,
        serviceDiscoveryTimeout: 1000
      });

      await expect(provider.healthCheck()).resolves.toEqual({ ok: true });
    });
  });
});
