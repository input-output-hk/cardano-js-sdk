/* eslint-disable max-len */
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-empty-function */
import { Connection } from '@cardano-ogmios/client';
import { Ogmios } from '@cardano-sdk/ogmios';
import { RABBITMQ_URL_DEFAULT, createDnsResolver, getOgmiosTxSubmitProvider } from '../../src';
import {
  RunningTxSubmitWorker,
  getRunningTxSubmitWorker,
  startTxSubmitWorkerWithDiscovery
} from '../../src/TxWorker/utils';
import { SrvRecord } from 'dns';
import { TxSubmitProvider } from '@cardano-sdk/core';
import { createLogger } from 'bunyan';
import { createMockOgmiosServer } from '../../../ogmios/test/mocks/mockOgmiosServer';
import { listenPromise, serverClosePromise } from '../../src/util';
import { ogmiosServerReady } from '../util';
import http from 'http';

const flushPromises = () => new Promise((resolve) => setImmediate(resolve));

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

describe('TxSubmitWorker abstraction', () => {
  describe('getRunningTxSubmitWorker', () => {
    let mockServer: http.Server;
    let connection: Connection;
    let txSubmitWorker: RunningTxSubmitWorker;
    let txSubmitProvider: TxSubmitProvider;
    const ogmiosPortDefault = 1337;
    const rabbitmqPortDefault = 5672;
    const logger = createLogger({ level: 'error', name: 'test' });
    const dnsResolver = createDnsResolver({ factor: 1.1, maxRetryTime: 1000 }, logger);
    const srvRecord = { name: 'localhost', port: rabbitmqPortDefault, priority: 1, weight: 1 };

    beforeEach(async () => {
      connection = Ogmios.createConnectionObject({ port: ogmiosPortDefault });
      mockServer = createMockOgmiosServer({
        healthCheck: { response: { networkSynchronization: 0.999, success: true } }
      });
      await listenPromise(mockServer, connection);
      await ogmiosServerReady(connection);
    });

    afterEach(async () => {
      if (mockServer !== undefined) {
        await serverClosePromise(mockServer);
      }

      await txSubmitWorker.stop();
    });

    it('should instantiate a running worker without service discovery', async () => {
      const dnsResolverMock = jest.fn();

      txSubmitProvider = await getOgmiosTxSubmitProvider(dnsResolver, logger, {
        cacheTtl: 10_000,
        ogmiosUrl: new URL(connection.address.webSocket)
      });

      txSubmitWorker = await getRunningTxSubmitWorker(dnsResolverMock, txSubmitProvider, logger, {
        cacheTtl: 10_000,
        rabbitmqUrl: new URL(RABBITMQ_URL_DEFAULT)
      });

      await expect(dnsResolverMock).toBeCalledTimes(0);
      expect(txSubmitWorker.getStatus()).toEqual('connected');
    });

    it('should instantiate a running worker with service discovery', async () => {
      const dnsResolverMock = jest.fn().mockResolvedValueOnce(srvRecord);
      txSubmitProvider = await getOgmiosTxSubmitProvider(dnsResolver, logger, {
        cacheTtl: 10_000,
        ogmiosSrvServiceName: process.env.OGMIOS_SRV_SERVICE_NAME,
        serviceDiscoveryBackoffFactor: 1.1,
        serviceDiscoveryTimeout: 1000
      });

      txSubmitWorker = await getRunningTxSubmitWorker(dnsResolverMock, txSubmitProvider, logger, {
        cacheTtl: 10_000,
        rabbitmqSrvServiceName: process.env.RABBITMQ_SRV_SERVICE_NAME,
        serviceDiscoveryBackoffFactor: 1.1,
        serviceDiscoveryTimeout: 1000
      });

      await expect(dnsResolverMock).toBeCalledTimes(1);
      expect(txSubmitWorker.getStatus()).toEqual('connected');
    });
  });

  describe('startTxSubmitWorkerWithDiscovery', () => {
    it('returns a started worker, which can then be stopped', async () => {
      const start = jest.fn().mockResolvedValueOnce(void 0);
      const stop = jest.fn().mockResolvedValueOnce(void 0);
      const workerFactory = jest.fn().mockImplementation(async () => ({
        on(_: string, __: any) {},
        start,
        stop
      }));

      const runnableWorker = await startTxSubmitWorkerWithDiscovery(workerFactory);
      await runnableWorker.stop();

      expect(start).toBeCalledTimes(1);
      expect(stop).toBeCalledTimes(1);
      expect(workerFactory).toBeCalledTimes(1);
    });

    it('should create and start a new instance of TxSubmitWorker when a broker connection error event is received', async () => {
      let simulateConnectionError: any = jest.fn();
      const firstStart = jest.fn().mockResolvedValueOnce(void 0);
      const secondStart = jest.fn().mockResolvedValueOnce(void 0);
      const workerFactory = jest
        .fn()
        .mockImplementationOnce(async () => ({
          on(_: string, listener: any) {
            simulateConnectionError = listener;
          },
          start: firstStart
        }))
        .mockImplementationOnce(async () => ({
          on(__: string, ___: any) {},
          start: secondStart
        }));

      await startTxSubmitWorkerWithDiscovery(workerFactory);

      expect(firstStart).toBeCalledTimes(1);
      expect(workerFactory).toBeCalledTimes(1);

      simulateConnectionError();
      await flushPromises();

      expect(secondStart).toBeCalledTimes(1);
      expect(workerFactory).toBeCalledTimes(2);
    });
  });

  it('should stop the correct worker instance when a broker connection error event is received', async () => {
    let simulateConnectionError: any = jest.fn();
    const stopSecondWorker = jest.fn().mockResolvedValueOnce(void 0);
    const workerFactory = jest
      .fn()
      .mockImplementationOnce(async () => ({
        on(_: string, listener: any) {
          simulateConnectionError = listener;
        },
        start: jest.fn().mockResolvedValueOnce(void 0)
      }))
      .mockImplementationOnce(async () => ({
        on(__: string, ___: any) {},
        start: jest.fn().mockResolvedValueOnce(void 0),
        stop: stopSecondWorker
      }));

    const runningTxSubmitWorker = await startTxSubmitWorkerWithDiscovery(workerFactory);

    simulateConnectionError();
    await flushPromises();

    expect(stopSecondWorker).toBeCalledTimes(0);

    await runningTxSubmitWorker.stop();
    expect(stopSecondWorker).toBeCalledTimes(1);
    expect(workerFactory).toBeCalledTimes(2);
  });
});
