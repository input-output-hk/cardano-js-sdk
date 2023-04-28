import { Cardano } from '@cardano-sdk/core';
import {
  ConnectionConfig,
  InteractionContext,
  InteractionType,
  ServerHealth,
  createInteractionContext
} from '@cardano-ogmios/client';
import { Logger } from 'ts-log';

/**
 * Converts an Ogmios connection URL to an Ogmios ConnectionConfig Object
 *
 * @param {URL} connectionURL Ogmios connection URL
 * @returns {ConnectionConfig} the ConnectionConfig Object
 */
export const urlToConnectionConfig = (connectionURL?: URL): ConnectionConfig => ({
  host: connectionURL?.hostname,
  port: connectionURL ? Number.parseInt(connectionURL.port) : undefined,
  tls: connectionURL?.protocol === 'wss'
});

type CreateInteractionContextOptions = {
  connection?: ConnectionConfig;
  interactionType?: InteractionType;
};

/**
 * Creates an Ogmios InteractionContext with close logic
 *
 * @param {Logger} logger Logger instance
 * @param {CreateInteractionContextOptions} options Options passed to the createInteractionContext function
 * @param {Function} onUnexpectedClose Optional callback to trigger an action when an unexpected close event occurs
 * @returns {Promise<InteractionContext>} Promise resolving an Ogmios InteractionContext
 */
export const createInteractionContextWithLogger = (
  logger: Logger,
  options?: CreateInteractionContextOptions,
  onUnexpectedClose?: () => Promise<void>
): Promise<InteractionContext> =>
  createInteractionContext(
    (error) => {
      logger.error({ error }, error.message);
    },
    async (code, reason) => {
      if (code === 1000) {
        logger.info({ code }, reason);
      } else {
        logger.error({ code }, 'Connection closed');
        await onUnexpectedClose?.();
      }
    },
    options
  );

export const ogmiosServerHealthToHealthCheckResponse = ({ lastKnownTip, networkSynchronization }: ServerHealth) => ({
  localNode: {
    ledgerTip: lastKnownTip,
    networkSync: Cardano.Percent(networkSynchronization)
  },
  ok: networkSynchronization > 0.99
});
