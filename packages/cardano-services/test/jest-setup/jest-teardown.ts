import { DockerUtil } from '@cardano-sdk/util-dev';
import { RabbitMQContainer } from '../TxSubmit/rabbitmq/docker';

module.exports = async () => {
  const container = new RabbitMQContainer();

  await DockerUtil.removePostgresContainer();
  await container.stop();
};
