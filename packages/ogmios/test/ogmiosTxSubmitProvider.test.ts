/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */
import { Connection, createConnectionObject } from '@cardano-ogmios/client';
import { TxSubmitProvider } from '@cardano-sdk/core';
import { createMockOgmiosServer } from './mocks/mockOgmiosServer';
import { getPort } from 'get-port-please';
import { ogmiosTxSubmitProvider } from '../src';
import http from 'http';

const listenPromise = (server: http.Server, port: number, hostname?: string): Promise<http.Server> =>
  new Promise((resolve, reject) => {
    server.listen(port, hostname, () => resolve(server));
    server.on('error', reject);
  });

const serverClosePromise = (server: http.Server): Promise<void> =>
  new Promise((resolve, reject) => {
    server.close((error) => {
      if (error !== undefined) {
        reject(error);
      }
      resolve();
    });
  });

describe('ogmiosTxSubmitProvider', () => {
  let mockServer: http.Server;
  let connection: Connection;
  let provider: TxSubmitProvider;

  beforeAll(async () => {
    connection = createConnectionObject({ port: await getPort() });
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
      afterAll(async () => {
        await serverClosePromise(mockServer);
      });

      it('rejects with errors thrown by the service', async () => {
        mockServer = createMockOgmiosServer({
          submitTx: { response: { failWith: { type: 'eraMismatch' }, success: false } }
        });
        await listenPromise(mockServer, connection.port);
        provider = ogmiosTxSubmitProvider(connection);

        try {
          await provider.submitTx(new Uint8Array());
        } catch (error) {
          expect(error[0].name).toBe('EraMismatchError');
        }
      });
    });
  });
});
