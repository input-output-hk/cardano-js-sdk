import { HEALTH_RESPONSE_BODY } from './mocks/util.js';
import { Percent } from '@cardano-sdk/util';
import { createInteractionContextWithLogger, ogmiosServerHealthToHealthCheckResponse } from '../src/index.js';
import { createLogger } from '@cardano-sdk/util-dev';
import { createMockOgmiosServer, listenPromise, serverClosePromise } from './mocks/mockOgmiosServer.js';
import { getRandomPort } from 'get-port-please';
import type { InteractionContext, ServerHealth } from '@cardano-ogmios/client';
import type { Logger } from 'ts-log';
import type WebSocket from 'ws';
import type http from 'http';

const closeWithCode = (socket: WebSocket, code: number) =>
  new Promise((resolve, reject) => {
    socket.on('error', reject);
    socket.on('close', resolve);
    socket.close(code);
  });

describe('util', () => {
  describe('createInteractionContextWithLogger', () => {
    let interactionContext: InteractionContext;
    let logger: Logger;
    let mockServer: http.Server;
    let port: number;

    beforeEach(async () => {
      logger = createLogger({ record: true });
      port = await getRandomPort();
      mockServer = createMockOgmiosServer({
        healthCheck: { response: { networkSynchronization: 0.999, success: true } },
        submitTx: { response: { success: true } }
      });
      await listenPromise(mockServer, port);
    });

    afterEach(async () => {
      if (mockServer !== undefined) {
        await serverClosePromise(mockServer);
      }
    });

    it('will use Ogmios defaults if no configuration is passed', async () => {
      await expect(async () => await createInteractionContextWithLogger(logger)).rejects.toThrowError('ECONNREFUSED');
    });

    describe('logging', () => {
      beforeEach(async () => {
        interactionContext = await createInteractionContextWithLogger(logger, { connection: { port } });
        expect(interactionContext.socket.readyState).toEqual(interactionContext.socket.OPEN);
      });

      it('logs an info message if the WebSocket is closed normally', async () => {
        await closeWithCode(interactionContext.socket, 1000);
        expect(logger.messages).toEqual([{ level: 'info', message: [{ code: 1000 }, ''] }]);
      });

      it('logs an error if the WebSocket is closed due to the server going down', async () => {
        await closeWithCode(interactionContext.socket, 1001);
        expect(logger.messages).toEqual([{ level: 'error', message: [{ code: 1001 }, 'Connection closed'] }]);
      });
    });

    describe('onUnexpectedClose callback', () => {
      let onUnexpectedClose: jest.Mock;
      beforeEach(async () => {
        onUnexpectedClose = jest.fn();
        interactionContext = await createInteractionContextWithLogger(
          logger,
          { connection: { port } },
          onUnexpectedClose
        );
        expect(interactionContext.socket.readyState).toEqual(interactionContext.socket.OPEN);
      });

      it('does not invoke the function if the close is normal', async () => {
        await closeWithCode(interactionContext.socket, 1000);
        expect(onUnexpectedClose).not.toHaveBeenCalled();
      });

      it('invokes the onUnexpectedClose callback if the socket is closed unexpectedly', async () => {
        await closeWithCode(interactionContext.socket, 1001);
        expect(onUnexpectedClose).toHaveBeenCalledTimes(1);
      });
    });
    describe('ogmiosServerHealthToHealthCheckResponse', () => {
      // The upstream type is missing some properties, so just casting for now
      const serverHealth = HEALTH_RESPONSE_BODY as ServerHealth;

      it('reports as healthy if sync percentage is greater than 0.99', async () => {
        const networkSynchronization = 0.991;
        expect(ogmiosServerHealthToHealthCheckResponse({ ...serverHealth, networkSynchronization })).toEqual({
          localNode: {
            ledgerTip: serverHealth.lastKnownTip,
            networkSync: Percent(networkSynchronization)
          },
          ok: true
        });
      });

      it('reports as unhealthy if sync percentage is equal to 0.99', async () => {
        const networkSynchronization = 0.99;
        expect(ogmiosServerHealthToHealthCheckResponse({ ...serverHealth, networkSynchronization }).ok).toBe(false);
      });

      it('reports as unhealthy if sync percentage is less than 0.99', async () => {
        const networkSynchronization = 0.98;
        expect(ogmiosServerHealthToHealthCheckResponse({ ...serverHealth, networkSynchronization }).ok).toBe(false);
      });
    });
  });
});
