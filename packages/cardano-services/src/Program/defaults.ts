import { createConnectionObject } from '@cardano-sdk/ogmios';

export const API_URL_DEFAULT = 'http://localhost:3000';

export const OGMIOS_URL_DEFAULT = (() => {
  const connection = createConnectionObject();
  return connection.address.webSocket;
})();

export const RABBITMQ_URL_DEFAULT = 'amqp://localhost:5672';
