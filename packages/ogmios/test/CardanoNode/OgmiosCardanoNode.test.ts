/* eslint-disable sonarjs/no-duplicate-string */
import { CardanoNode, CardanoNodeErrors } from '@cardano-sdk/core';
import { Connection, createConnectionObject } from '@cardano-ogmios/client';
import { OgmiosCardanoNode } from '../../src';
import { createMockOgmiosServer, listenPromise, serverClosePromise } from '../mocks/mockOgmiosServer';
import { getRandomPort } from 'get-port-please';
import http from 'http';

describe('OgmiosCardanoNode', () => {
  let mockServer: http.Server;
  let connection: Connection;
  let node: CardanoNode;

  beforeAll(async () => {
    connection = createConnectionObject({ port: await getRandomPort() });
  });

  describe('not initialized', () => {
    beforeAll(async () => {
      mockServer = createMockOgmiosServer({
        stateQuery: { eraSummaries: { response: { success: true } }, systemStart: { response: { success: true } } }
      });
      node = new OgmiosCardanoNode(connection);
      await listenPromise(mockServer, connection.port);
    });
    afterAll(async () => {
      await serverClosePromise(mockServer);
    });

    it('eraSummaries rejects with not initialized error', async () => {
      await expect(node.eraSummaries()).rejects.toThrowError(
        new CardanoNodeErrors.CardanoNodeNotInitializedError('eraSummaries')
      );
    });
    it('systemStart rejects with not initialized error', async () => {
      await expect(node.systemStart()).rejects.toThrowError(
        new CardanoNodeErrors.CardanoNodeNotInitializedError('systemStart')
      );
    });
    it('stakeDistribution rejects with not initialized error', async () => {
      await expect(node.stakeDistribution()).rejects.toThrowError(
        new CardanoNodeErrors.CardanoNodeNotInitializedError('stakeDistribution')
      );
    });
    it('shutdown rejects with not initialized error', async () => {
      await expect(node.shutdown()).rejects.toThrowError(
        new CardanoNodeErrors.CardanoNodeNotInitializedError('shutdown')
      );
    });
  });

  describe('initialized', () => {
    describe('eraSummaries', () => {
      describe('success', () => {
        beforeAll(async () => {
          mockServer = createMockOgmiosServer({
            stateQuery: { eraSummaries: { response: { success: true } }, systemStart: { response: { success: true } } }
          });
          await listenPromise(mockServer, connection.port);
          node = new OgmiosCardanoNode(connection);
          await node.initialize();
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
          node = new OgmiosCardanoNode(connection);
          await node.initialize();
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
          node = new OgmiosCardanoNode(connection);
          await node.initialize();
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
          node = new OgmiosCardanoNode(connection);
          await node.initialize();
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

    describe('stakeDistribution', () => {
      describe('success', () => {
        beforeAll(async () => {
          mockServer = createMockOgmiosServer({
            stateQuery: { stakeDistribution: { response: { success: true } } }
          });
          await listenPromise(mockServer, connection.port);
          node = new OgmiosCardanoNode(connection);
          await node.initialize();
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
          node = new OgmiosCardanoNode(connection);
          await node.initialize();
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
        node = new OgmiosCardanoNode(connection);
      });
      afterAll(async () => {
        await serverClosePromise(mockServer);
      });

      beforeEach(async () => {
        await node.initialize();
      });

      it('shuts down successfully', async () => {
        await expect(node.shutdown()).resolves.not.toThrow();
      });
      it('throws when querying after shutting down', async () => {
        await node.shutdown();
        await expect(node.systemStart()).rejects.toThrow(CardanoNodeErrors.CardanoNodeNotInitializedError);
      });
    });
  });
});
