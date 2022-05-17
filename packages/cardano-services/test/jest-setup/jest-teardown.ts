import { removePostgresContainer } from './docker';
import { removeRabbitMQContainer } from '@cardano-sdk/rabbitmq/test/jest-setup/docker';

module.exports = async () => {
  await removePostgresContainer();
  await removeRabbitMQContainer();
};
