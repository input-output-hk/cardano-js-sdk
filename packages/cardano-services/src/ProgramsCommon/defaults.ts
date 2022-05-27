import { createConnectionObject } from '@cardano-sdk/ogmios';

export const OGMIOS_URL_DEFAULT = (() => {
  const connection = createConnectionObject();
  return connection.address.webSocket;
})();

export const RABBITMQ_URL_DEFAULT = 'amqp://localhost:5672';
