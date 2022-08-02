import { RabbitMQContainer } from '../../../rabbitmq/test/docker';
import { removePostgresContainer } from './docker';

module.exports = async () => {
  const container = new RabbitMQContainer();

  await removePostgresContainer();
  await container.stop();
};
