import { removePostgresContainer } from './docker';
import { removeRabbitMQContainer } from '../../../rabbitmq/test/jest-setup/docker';

module.exports = async () => {
  await removePostgresContainer();
  await removeRabbitMQContainer();
};
