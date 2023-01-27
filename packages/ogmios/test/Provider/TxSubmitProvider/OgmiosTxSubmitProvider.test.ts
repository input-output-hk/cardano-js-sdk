import { CardanoNodeErrors, ProviderError } from '@cardano-sdk/core';
import { Connection, createConnectionObject } from '@cardano-ogmios/client';
import { OgmiosTxSubmitProvider } from '../../../src';
import { bufferToHexString } from '@cardano-sdk/util';
import { createMockOgmiosServer, listenPromise, serverClosePromise } from '../../mocks/mockOgmiosServer';
import { getRandomPort } from 'get-port-please';
import { healthCheckResponseMock } from '../../../../core/test/CardanoNode/mocks';
import { dummyLogger as logger } from 'ts-log';
import http from 'http';

const emptyUintArrayAsHexString = bufferToHexString(Buffer.from(new Uint8Array()));

describe('OgmiosTxSubmitProvider', () => {
  let mockServer: http.Server;
  let connection: Connection;
  let provider: OgmiosTxSubmitProvider;

  const responseWithServiceState = healthCheckResponseMock({ withTip: false });

  beforeAll(async () => {
    connection = createConnectionObject({ port: await getRandomPort() });
  });

  describe('healthCheck', () => {
    afterEach(async () => {
      if (mockServer !== undefined) {
        await serverClosePromise(mockServer);
      }
    });

    it('is not ok if cannot connect', async () => {
      provider = new OgmiosTxSubmitProvider(connection, { logger });
      const res = await provider.healthCheck();
      expect(res).toEqual({ ok: false });
    });

    it('is ok if node is close to the network tip', async () => {
      mockServer = createMockOgmiosServer({
        healthCheck: { response: { networkSynchronization: 0.999, success: true } },
        submitTx: { response: { success: true } }
      });
      await listenPromise(mockServer, connection.port);
      provider = new OgmiosTxSubmitProvider(connection, { logger });
      const res = await provider.healthCheck();
      expect(res).toEqual(responseWithServiceState);
    });

    it('is not ok if node is not close to the network tip', async () => {
      mockServer = createMockOgmiosServer({
        healthCheck: { response: { networkSynchronization: 0.8, success: true } },
        submitTx: { response: { success: true } }
      });
      await listenPromise(mockServer, connection.port);
      provider = new OgmiosTxSubmitProvider(connection, { logger });
      const res = await provider.healthCheck();
      expect(res).toEqual({
        ...responseWithServiceState,
        localNode: { ...responseWithServiceState.localNode, networkSync: 0.8 },
        ok: false
      });
    });

    it('throws a typed error if caught during the service interaction', async () => {
      mockServer = createMockOgmiosServer({
        healthCheck: { response: { failWith: new Error('Some error'), success: false } },
        submitTx: { response: { success: true } }
      });
      await listenPromise(mockServer, connection.port);
      provider = new OgmiosTxSubmitProvider(connection, { logger });
      await expect(provider.healthCheck()).rejects.toThrowError(ProviderError);
    });
  });

  describe('submitTx', () => {
    afterEach(async () => {
      await provider.shutdown();
      await serverClosePromise(mockServer);
    });
    it('resolves if successful', async () => {
      mockServer = createMockOgmiosServer({ submitTx: { response: { success: true } } });
      await listenPromise(mockServer, connection.port);
      provider = new OgmiosTxSubmitProvider(connection, { logger });
      await provider.initialize();
      await provider.start();

      const res = await provider.submitTx({ signedTransaction: emptyUintArrayAsHexString });
      expect(res).toBeUndefined();
    });

    it('rejects with errors thrown by the service', async () => {
      mockServer = createMockOgmiosServer({
        submitTx: { response: { failWith: { type: 'eraMismatch' }, success: false } }
      });
      await listenPromise(mockServer, connection.port);
      provider = new OgmiosTxSubmitProvider(connection, { logger });
      await provider.initialize();
      await provider.start();

      await expect(provider.submitTx({ signedTransaction: emptyUintArrayAsHexString })).rejects.toThrowError(
        CardanoNodeErrors.TxSubmissionErrors.EraMismatchError
      );
    });
  });

  describe('shutdown', () => {
    beforeAll(async () => {
      mockServer = createMockOgmiosServer({ stateQuery: { systemStart: { response: { success: true } } } });
      await listenPromise(mockServer, connection.port);
    });

    afterAll(async () => {
      await serverClosePromise(mockServer);
    });

    beforeEach(async () => {
      provider = new OgmiosTxSubmitProvider(connection, { logger });
      await provider.initialize();
      await provider.start();
    });

    it('shuts down successfully', async () => {
      await expect(provider.shutdown()).resolves.not.toThrow();
    });

    it('throws when querying after shutting down', async () => {
      await provider.shutdown();
      await expect(provider.submitTx({ signedTransaction: emptyUintArrayAsHexString })).rejects.toThrowError(
        CardanoNodeErrors.NotInitializedError
      );
    });
  });
});
