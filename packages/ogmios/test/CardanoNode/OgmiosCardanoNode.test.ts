/* eslint-disable sonarjs/no-duplicate-string */
import { CardanoNodeErrors } from '@cardano-sdk/core';
import { InvalidModuleState } from '@cardano-sdk/util';
import { OgmiosCardanoNode } from '../../src/index.js';
import { createConnectionObject } from '@cardano-ogmios/client';
import { createMockOgmiosServer, listenPromise, serverClosePromise } from '../mocks/mockOgmiosServer.js';
import { getRandomPort } from 'get-port-please';
import { dummyLogger as logger } from 'ts-log';
import type { Connection } from '@cardano-ogmios/client';
import type http from 'http';
describe('OgmiosCardanoNode', () => {
  let mockServer: http.Server;
  let connection: Connection;
  let node: OgmiosCardanoNode;
  const moduleName = 'OgmiosCardanoNode';

  beforeAll(async () => {
    connection = createConnectionObject({ port: await getRandomPort() });
  });
  describe('not initialized and started', () => {
    beforeAll(async () => {
      mockServer = createMockOgmiosServer({
        stateQuery: { eraSummaries: { response: { success: true } }, systemStart: { response: { success: true } } }
      });
      await listenPromise(mockServer, connection.port);
      node = new OgmiosCardanoNode(connection, logger);
    });
    afterAll(async () => {
      await serverClosePromise(mockServer);
    });

    it('eraSummaries rejects with not initialized error', async () => {
      await expect(node.eraSummaries()).rejects.toThrowError(
        new CardanoNodeErrors.NotInitializedError('eraSummaries', moduleName)
      );
    });
    it('systemStart rejects with not initialized error', async () => {
      await expect(node.systemStart()).rejects.toThrowError(
        new CardanoNodeErrors.NotInitializedError('systemStart', moduleName)
      );
    });
    it('stakeDistribution rejects with not initialized error', async () => {
      await expect(node.stakeDistribution()).rejects.toThrowError(
        new CardanoNodeErrors.NotInitializedError('stakeDistribution', moduleName)
      );
    });
    it('shutdown rejects with not initialized error', async () => {
      await expect(node.shutdown()).rejects.toThrowError(InvalidModuleState);
    });
  });
  describe('initialized and started', () => {
    describe('eraSummaries', () => {
      describe('success', () => {
        beforeAll(async () => {
          mockServer = createMockOgmiosServer({
            stateQuery: { eraSummaries: { response: { success: true } }, systemStart: { response: { success: true } } }
          });
          await listenPromise(mockServer, connection.port);
          node = new OgmiosCardanoNode(connection, logger);
          await node.initialize();
          await node.start();
        });
        afterAll(async () => {
          await node.shutdown();
          await serverClosePromise(mockServer);
        });
        it('resolves if successful', async () => {
          const res = await node.eraSummaries();
          expect(res).toMatchSnapshot();
        });
      });
      describe('failure', () => {
        beforeAll(async () => {
          mockServer = createMockOgmiosServer({
            stateQuery: {
              eraSummaries: { response: { failWith: { type: 'unknownResultError' }, success: false } },
              systemStart: { response: { success: true } }
            }
          });
          await listenPromise(mockServer, connection.port);
          node = new OgmiosCardanoNode(connection, logger);
          await node.initialize();
          await node.start();
        });
        afterAll(async () => {
          await node.shutdown();
          await serverClosePromise(mockServer);
        });

        it('rejects with errors thrown by the service', async () => {
          await expect(node.eraSummaries()).rejects.toThrowError(
            CardanoNodeErrors.CardanoClientErrors.UnknownResultError
          );
        });
      });
    });
    describe('systemStart', () => {
      describe('success', () => {
        beforeAll(async () => {
          mockServer = createMockOgmiosServer({ stateQuery: { systemStart: { response: { success: true } } } });
          await listenPromise(mockServer, connection.port);
          node = new OgmiosCardanoNode(connection, logger);
          await node.initialize();
          await node.start();
        });
        afterAll(async () => {
          await node.shutdown();
          await serverClosePromise(mockServer);
        });
        it('resolves if successful', async () => {
          const res = await node.systemStart();
          expect(res).toMatchSnapshot();
        });
      });
      describe('failure', () => {
        beforeAll(async () => {
          mockServer = createMockOgmiosServer({
            stateQuery: { systemStart: { response: { failWith: { type: 'queryUnavailableInEra' }, success: false } } }
          });
          await listenPromise(mockServer, connection.port);
          node = new OgmiosCardanoNode(connection, logger);
          await node.initialize();
          await node.start();
        });
        afterAll(async () => {
          await node.shutdown();
          await serverClosePromise(mockServer);
        });

        it('rejects with errors thrown by the service', async () => {
          await expect(node.systemStart()).rejects.toThrowError(
            CardanoNodeErrors.CardanoClientErrors.QueryUnavailableInCurrentEraError
          );
        });
      });
    });
    describe('healthCheck', () => {
      describe('success', () => {
        beforeAll(async () => {
          mockServer = createMockOgmiosServer({
            healthCheck: { response: { success: true } }
          });
          await listenPromise(mockServer, connection.port);
          node = new OgmiosCardanoNode(connection, logger);
          await node.initialize();
          await node.start();
        });
        afterAll(async () => {
          await node.shutdown();
          await serverClosePromise(mockServer);
        });
        it('returns ok if successful', async () => {
          const res = await node.healthCheck();
          expect(res.ok).toBe(true);
        });
      });
      describe('failure', () => {
        beforeAll(async () => {
          mockServer = createMockOgmiosServer({
            healthCheck: {
              response: {
                failWith: new Error('Some error'),
                success: false
              },
              skipInvocations: 1
            }
          });
          await listenPromise(mockServer, connection.port);
          node = new OgmiosCardanoNode(connection, logger);
          await node.initialize();
          await node.start();
        });
        afterAll(async () => {
          await node.shutdown();
          await serverClosePromise(mockServer);
        });

        it('returns not ok if the Ogmios server throws an error', async () => {
          const res = await node.healthCheck();
          expect(res.ok).toBe(false);
        });
      });
    });
    describe('stakeDistribution', () => {
      describe('success', () => {
        beforeAll(async () => {
          mockServer = createMockOgmiosServer({
            stateQuery: { stakeDistribution: { response: { success: true } } }
          });
          await listenPromise(mockServer, connection.port);
          node = new OgmiosCardanoNode(connection, logger);
          await node.initialize();
          await node.start();
        });
        afterAll(async () => {
          await node.shutdown();
          await serverClosePromise(mockServer);
        });
        it('resolves if successful', async () => {
          const res = await node.stakeDistribution();
          expect(res).toMatchSnapshot();
        });
      });
      describe('failure', () => {
        beforeAll(async () => {
          mockServer = createMockOgmiosServer({
            stateQuery: {
              stakeDistribution: { response: { failWith: { type: 'queryUnavailableInEra' }, success: false } },
              systemStart: { response: { success: true } }
            }
          });
          await listenPromise(mockServer, connection.port);
          node = new OgmiosCardanoNode(connection, logger);
          await node.initialize();
          await node.start();
        });
        afterAll(async () => {
          await node.shutdown();
          await serverClosePromise(mockServer);
        });

        it('rejects with errors thrown by the service', async () => {
          await expect(node.stakeDistribution()).rejects.toThrowError(
            CardanoNodeErrors.CardanoClientErrors.QueryUnavailableInCurrentEraError
          );
        });
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
        node = new OgmiosCardanoNode(connection, logger);
        await node.initialize();
        await node.start();
      });
      it('shuts down successfully', async () => {
        await expect(node.shutdown()).resolves.not.toThrow();
      });

      it('throws when querying after shutting down', async () => {
        await node.shutdown();
        await expect(node.systemStart()).rejects.toThrow(CardanoNodeErrors.NotInitializedError);
      });
    });
  });
});
