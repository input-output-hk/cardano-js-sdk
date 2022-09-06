import { Cardano, HealthCheckResponse, ProviderError, TxSubmitProvider } from '@cardano-sdk/core';
import { Connection, createConnectionObject } from '@cardano-ogmios/client';
import { bufferToHexString } from '@cardano-sdk/util';
import { createMockOgmiosServer, listenPromise, serverClosePromise } from '../../mocks/mockOgmiosServer';
import { getRandomPort } from 'get-port-please';
import { dummyLogger as logger } from 'ts-log';
import { ogmiosTxSubmitProvider } from '../../../src';
import http from 'http';

const emptyUintArrayAsHexString = bufferToHexString(Buffer.from(new Uint8Array()));

describe('ogmiosTxSubmitProvider', () => {
  let mockServer: http.Server;
  let connection: Connection;
  let provider: TxSubmitProvider;

  const responseWithServiceState: HealthCheckResponse = {
    localNode: {
      ledgerTip: {
        blockNo: 3_391_731,
        hash: '9ef43ab6e234fcf90d103413096c7da752da2f45b15e1259f43d476afd12932c',
        slot: 52_819_355
      },
      networkSync: 0.999
    },
    ok: true
  };

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
      provider = ogmiosTxSubmitProvider(connection, logger);
      const res = await provider.healthCheck();
      expect(res).toEqual({ ok: false });
    });

    it('is ok if node is close to the network tip', async () => {
      mockServer = createMockOgmiosServer({
        healthCheck: { response: { networkSynchronization: 0.999, success: true } },
        submitTx: { response: { success: true } }
      });
      await listenPromise(mockServer, connection.port);
      provider = ogmiosTxSubmitProvider(connection, logger);
      const res = await provider.healthCheck();
      expect(res).toEqual(responseWithServiceState);
    });

    it('is not ok if node is not close to the network tip', async () => {
      mockServer = createMockOgmiosServer({
        healthCheck: { response: { networkSynchronization: 0.8, success: true } },
        submitTx: { response: { success: true } }
      });
      await listenPromise(mockServer, connection.port);
      provider = ogmiosTxSubmitProvider(connection, logger);
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
      provider = ogmiosTxSubmitProvider(connection, logger);
      await expect(provider.healthCheck()).rejects.toThrowError(ProviderError);
    });
  });

  describe('submitTx', () => {
    describe('success', () => {
      beforeAll(async () => {
        mockServer = createMockOgmiosServer({ submitTx: { response: { success: true } } });
        await listenPromise(mockServer, connection.port);
        provider = ogmiosTxSubmitProvider(connection, logger);
      });

      afterAll(async () => {
        await serverClosePromise(mockServer);
      });

      it('resolves if successful', async () => {
        try {
          const res = await provider.submitTx({ signedTransaction: emptyUintArrayAsHexString });
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
        provider = ogmiosTxSubmitProvider(connection, logger);
        await expect(provider.submitTx({ signedTransaction: emptyUintArrayAsHexString })).rejects.toThrowError(
          Cardano.TxSubmissionErrors.EraMismatchError
        );
      });
    });
  });
});
