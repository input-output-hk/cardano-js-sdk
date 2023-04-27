/* eslint-disable sonarjs/no-duplicate-string */
import { CardanoNodeErrors, Milliseconds } from '@cardano-sdk/core';
import { Connection, createConnectionObject } from '@cardano-ogmios/client';
import {
  MockOgmiosServerConfig,
  createMockOgmiosServer,
  listenPromise,
  mockGenesisConfig,
  serverClosePromise,
  waitForWsClientsDisconnect
} from '../mocks/mockOgmiosServer';
import { OgmiosObservableCardanoNode } from '../../src';
import { combineLatest, delay as delayEmission, firstValueFrom, mergeMap, of, take, toArray } from 'rxjs';
import { getRandomPort } from 'get-port-please';
import { logger } from '@cardano-sdk/util-dev';
import delay from 'delay';

const defaultConfig: MockOgmiosServerConfig = {
  chainSync: {
    requestNext: {
      responses: ['135.json']
    }
  },
  findIntersect: () => ({
    IntersectionFound: {
      point: 'origin',
      tip: 'origin'
    }
  }),
  maxConnections: 1,
  stateQuery: {
    eraSummaries: { response: { success: true } },
    genesisConfig: { response: { success: true } },
    systemStart: { response: { success: true } }
  }
};
const startMockOgmiosServer = async (port: number, configOverrides: Partial<MockOgmiosServerConfig> = {}) => {
  const mockServer = createMockOgmiosServer({
    ...defaultConfig,
    ...configOverrides
  });
  await listenPromise(mockServer, port);
  return mockServer;
};

describe('ObservableOgmiosCardanoNode', () => {
  let connection: Connection;

  beforeAll(async () => {
    connection = createConnectionObject({ port: await getRandomPort() });
  });

  describe('subscribing to all observables', () => {
    it('shares a single lazily created connection & emits well-formed data', async () => {
      const server = await startMockOgmiosServer(connection.port);
      const node = new OgmiosObservableCardanoNode({ connectionConfig$: of(connection) }, { logger });
      // Doesn't connect until any observable is subscribed
      await delay(100);
      expect(server.wss.clients.size).toBe(0);

      // Shares a single connection for all observables
      const res = await firstValueFrom(
        combineLatest([
          node.eraSummaries$,
          node.genesisParameters$,
          node.findIntersect(['origin']).pipe(mergeMap(({ chainSync$ }) => chainSync$))
        ])
      );
      // Data is well formed
      expect(res).toMatchSnapshot();
      // Websocket close() should be already called at this point,
      // but it takes some time to disconnect
      expect(server.wss.clients.size).toBe(1);

      // this will not resolve until all clients disconnect -
      // test will fail if OgmiosObservableCardanoNode
      // fails to cleanup connections when all observables are unsubscribed.
      await waitForWsClientsDisconnect(server, Milliseconds(500));
      await serverClosePromise(server);
    });
  });

  it('opaquely reconnects when connection is refused', async () => {
    const node = new OgmiosObservableCardanoNode({ connectionConfig$: of(connection) }, { logger });
    // Server is not started yet
    const result = firstValueFrom(node.genesisParameters$);
    // Observable emits once it can connect to the server
    await delay(100);
    const server = await startMockOgmiosServer(connection.port);
    // Once the server is started, it emits something that looks like genesis config
    expect(typeof (await result).epochLength).toBe('number');
    await serverClosePromise(server);
  });

  it('opaquely reconnects when websocket is closed by the server', async () => {
    const server = await startMockOgmiosServer(connection.port, {
      stateQuery: {
        ...defaultConfig.stateQuery,
        genesisConfig: {
          response: [
            {
              config: mockGenesisConfig,
              success: true
            },
            {
              config: {
                ...mockGenesisConfig,
                epochLength: mockGenesisConfig.epochLength + 1
              },
              success: true
            }
          ]
        }
      }
    });
    const node = new OgmiosObservableCardanoNode({ connectionConfig$: of(connection) }, { logger });
    const genesisParameters$ = node.genesisParameters$.pipe(take(2));
    const bothEmissions = firstValueFrom(genesisParameters$.pipe(toArray()));
    // connect and get genesis parameters
    await firstValueFrom(genesisParameters$);
    // simulate a non-"Normal Closure" event
    for (const client of server.wss.clients) {
      client.close(1001);
    }
    // it has to reconnect in order to emit the 2nd time
    const [{ epochLength: epochLength1 }, { epochLength: epochLength2 }] = await bothEmissions;
    expect(epochLength1).toEqual(mockGenesisConfig.epochLength);
    expect(epochLength2).toEqual(mockGenesisConfig.epochLength + 1);
    await serverClosePromise(server);
  });
  describe('healthCheck', () => {
    it('is ok if node is close to the network tip', async () => {
      const server = await startMockOgmiosServer(connection.port, {
        healthCheck: { response: { networkSynchronization: 0.999, success: true } }
      });
      const node = new OgmiosObservableCardanoNode({ connectionConfig$: of(connection) }, { logger });
      const res = await firstValueFrom(node.healthCheck$);
      expect(res.ok).toBe(true);
      await serverClosePromise(server);
    });
    it('simultaneous healthChecks share a single health request to ogmios', async () => {
      const server = await startMockOgmiosServer(connection.port, {
        healthCheck: { response: { networkSynchronization: 0.999, success: true } }
      });
      const node = new OgmiosObservableCardanoNode({ connectionConfig$: of(connection) }, { logger });
      const [res1, res2] = await firstValueFrom(combineLatest([node.healthCheck$, node.healthCheck$]));
      expect(res1.ok).toBe(true);
      expect(res1).toEqual(res2);
      expect(server.invocations.health).toBe(1);
      await serverClosePromise(server);
    });
    it('is not ok if node is not close to the network tip', async () => {
      const server = await startMockOgmiosServer(connection.port, {
        healthCheck: { response: { networkSynchronization: 0.8, success: true } }
      });
      const node = new OgmiosObservableCardanoNode({ connectionConfig$: of(connection) }, { logger });
      const res = await firstValueFrom(node.healthCheck$);
      expect(res.ok).toBe(false);
      await serverClosePromise(server);
    });
    it('is not ok when ogmios responds with an unknown result', async () => {
      const server = await startMockOgmiosServer(connection.port, {
        healthCheck: {
          response: { failWith: new CardanoNodeErrors.CardanoClientErrors.UnknownResultError(''), success: false }
        }
      });
      const node = new OgmiosObservableCardanoNode({ connectionConfig$: of(connection) }, { logger });
      const res = await firstValueFrom(node.healthCheck$);
      expect(res.ok).toBe(false);
      await serverClosePromise(server);
    });
    it('is not ok when connection is refused', async () => {
      const node = new OgmiosObservableCardanoNode({ connectionConfig$: of(connection) }, { logger });
      // Server is not started
      const result = await firstValueFrom(node.healthCheck$);
      expect(result.ok).toBe(false);
    });
    it('is ok when connectionConfig$ emits within "healthCheckTimeout" duration', async () => {
      const server = await startMockOgmiosServer(connection.port, {
        healthCheck: { response: { networkSynchronization: 0.999, success: true } }
      });
      const node = new OgmiosObservableCardanoNode(
        { connectionConfig$: of(connection).pipe(delayEmission(25)), healthCheckTimeout: Milliseconds(50) },
        { logger }
      );
      const result = await firstValueFrom(node.healthCheck$);
      expect(result.ok).toBe(true);
      await serverClosePromise(server);
    });
    it('is not ok when connectionConfig$ takes longer than "healthCheckTimeout" to emit', async () => {
      const server = await startMockOgmiosServer(connection.port, {
        healthCheck: { response: { networkSynchronization: 0.999, success: true } }
      });
      const node = new OgmiosObservableCardanoNode(
        { connectionConfig$: of(connection).pipe(delayEmission(50)), healthCheckTimeout: Milliseconds(25) },
        { logger }
      );
      const result = await firstValueFrom(node.healthCheck$);
      expect(result.ok).toBe(false);
      await serverClosePromise(server);
    });
  });
});
