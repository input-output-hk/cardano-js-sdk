import { Cardano, ProviderError, TxSubmitProvider } from '@cardano-sdk/core';
import { Connection, createConnectionObject } from '@cardano-ogmios/client';
import { createMockOgmiosServer, listenPromise, serverClosePromise } from '../../mocks/mockOgmiosServer';
import { getRandomPort } from 'get-port-please';
import { ogmiosTxSubmitProvider } from '../../../src';
import http from 'http';

describe('ogmiosTxSubmitProvider', () => {
  let mockServer: http.Server;
  let connection: Connection;
  let provider: TxSubmitProvider;

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
      provider = ogmiosTxSubmitProvider(connection);
      const res = await provider.healthCheck();
      expect(res).toEqual({ ok: false });
    });

    it('is ok if node is close to the network tip', async () => {
      mockServer = createMockOgmiosServer({
        healthCheck: { response: { networkSynchronization: 0.999, success: true } },
        submitTx: { response: { success: true } }
      });
      await listenPromise(mockServer, connection.port);
      provider = ogmiosTxSubmitProvider(connection);
      const res = await provider.healthCheck();
      expect(res).toEqual({ ok: true });
    });

    it('is not ok if node is not close to the network tip', async () => {
      mockServer = createMockOgmiosServer({
        healthCheck: { response: { networkSynchronization: 0.8, success: true } },
        submitTx: { response: { success: true } }
      });
      await listenPromise(mockServer, connection.port);
      provider = ogmiosTxSubmitProvider(connection);
      const res = await provider.healthCheck();
      expect(res).toEqual({ ok: false });
    });

    it('throws a typed error if caught during the service interaction', async () => {
      mockServer = createMockOgmiosServer({
        healthCheck: { response: { failWith: new Error('Some error'), success: false } },
        submitTx: { response: { success: true } }
      });
      await listenPromise(mockServer, connection.port);
      provider = ogmiosTxSubmitProvider(connection);
      await expect(provider.healthCheck()).rejects.toThrowError(ProviderError);
    });
  });

  describe('submitTx', () => {
    describe('success', () => {
      beforeAll(async () => {
        mockServer = createMockOgmiosServer({ submitTx: { response: { success: true } } });
        await listenPromise(mockServer, connection.port);
        provider = ogmiosTxSubmitProvider(connection);
      });

      afterAll(async () => {
        await serverClosePromise(mockServer);
      });

      it('resolves if successful', async () => {
        try {
          const res = await provider.submitTx(new Uint8Array());
          expect(res).toBeUndefined();
        } catch (error) {
          expect(error).toBeUndefined();
        }
      });
    });

    describe('failure', () => {
      afterEach(async () => {
        await serverClosePromise(mockServer);
      });

      it('rejects with errors thrown by the service', async () => {
        mockServer = createMockOgmiosServer({
          submitTx: { response: { failWith: { type: 'eraMismatch' }, success: false } }
        });
        await listenPromise(mockServer, connection.port);
        provider = ogmiosTxSubmitProvider(connection);
        await expect(provider.submitTx(new Uint8Array())).rejects.toThrowError(
          Cardano.TxSubmissionErrors.EraMismatchError
        );
      });
    });
  });
});
