import { HEALTH_RESPONSE_BODY } from './mocks/util';
import { Logger } from 'ts-log';
import { Percent } from '@cardano-sdk/util';
import { WebSocketCloseHandler, WebSocketErrorHandler, createInteractionContext } from '@cardano-ogmios/client';
import { createInteractionContextWithLogger, ogmiosServerHealthToHealthCheckResponse } from '../src/util';
import { createLogger } from '@cardano-sdk/util-dev';

let testErrorHandler: WebSocketErrorHandler;
let testCloseHandler: WebSocketCloseHandler;

jest.mock('@cardano-ogmios/client', () => ({
  ...jest.requireActual('@cardano-ogmios/client'),
  createInteractionContext: jest.fn((errorHandler: WebSocketErrorHandler, closeHandler: WebSocketCloseHandler) => {
    testErrorHandler = errorHandler;
    testCloseHandler = closeHandler;
  })
}));

describe('util', () => {
  describe('createInteractionContextWithLogger', () => {
    let logger: Logger;
    let port: number;

    beforeEach(async () => {
      testErrorHandler = () => void 0;
      testCloseHandler = () => void 0;
      logger = createLogger({ record: true });
    });

    describe('logging', () => {
      beforeEach(async () => {
        await createInteractionContextWithLogger(logger);
        expect(createInteractionContext).toHaveBeenCalled();
        expect(testErrorHandler).toBeDefined();
      });

      it('logs an info message if the WebSocket is closed normally', async () => {
        testCloseHandler(1000, '');
        expect(logger.messages).toEqual([{ level: 'info', message: [{ code: 1000 }, ''] }]);
      });

      it('logs an error if the WebSocket is closed due to the server going down', async () => {
        testCloseHandler(1001, '');
        expect(logger.messages).toEqual([{ level: 'error', message: [{ code: 1001 }, 'Connection closed'] }]);
      });
    });

    describe('onUnexpectedClose callback', () => {
      let onUnexpectedClose: jest.Mock;
      beforeEach(async () => {
        onUnexpectedClose = jest.fn();
        await createInteractionContextWithLogger(logger, { connection: { port } }, onUnexpectedClose);
      });

      it('does not invoke the function if the close is normal', () => {
        testCloseHandler(1000, '');
        expect(onUnexpectedClose).not.toHaveBeenCalled();
      });

      it('invokes the onUnexpectedClose callback if the socket is closed unexpectedly', async () => {
        testCloseHandler(1001, '');
        expect(onUnexpectedClose).toHaveBeenCalledTimes(1);
      });
    });

    describe('ogmiosServerHealthToHealthCheckResponse', () => {
      const serverHealth = HEALTH_RESPONSE_BODY;

      it('reports as healthy if sync percentage is greater than 0.99', async () => {
        const networkSynchronization = 0.991;
        const { height: blockNo, id: hash, slot } = serverHealth.lastKnownTip;
        expect(ogmiosServerHealthToHealthCheckResponse({ ...serverHealth, networkSynchronization })).toEqual({
          localNode: {
            ledgerTip: { blockNo, hash, slot },
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
