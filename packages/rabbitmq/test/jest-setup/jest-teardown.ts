import { RabbitMQContainer } from '../docker';

const removeContainer = async () => {
  const container = new RabbitMQContainer();

  await container.stop();
};

export default removeContainer;
