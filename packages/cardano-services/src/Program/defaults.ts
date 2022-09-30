import { Ogmios } from '@cardano-sdk/ogmios';

export const OGMIOS_URL_DEFAULT = (() => {
  const connection = Ogmios.createConnectionObject();
  return connection.address.webSocket;
})();

export const RABBITMQ_URL_DEFAULT = 'amqp://localhost:5672';

export const USE_QUEUE_DEFAULT = false;

export const ENABLE_METRICS_DEFAULT = false;
// http-server
export const API_URL_DEFAULT = 'http://localhost:3000';
export const PAGINATION_PAGE_SIZE_LIMIT_DEFAULT = 25;

// tx-worker
export const PARALLEL_MODE_DEFAULT = false;
export const PARALLEL_TXS_DEFAULT = 3;
export const POLLING_CYCLE_DEFAULT = 500;
