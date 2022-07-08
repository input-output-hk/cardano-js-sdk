import { ConnectionConfig } from '@cardano-ogmios/client';

/**
 * Converts an Ogmios connection URL to a Ogmios ConnectionConfig Object
 *
 * @param {URL} connectionURL Ogmios connection URL
 * @returns {ConnectionConfig} the ConnectionConfig Object
 */
export const urlToConnectionConfig = (connectionURL?: URL): ConnectionConfig => ({
  host: connectionURL?.hostname,
  port: connectionURL ? Number.parseInt(connectionURL.port) : undefined,
  tls: connectionURL?.protocol === 'wss'
});
