import { RabbitMQContainer } from '../docker';

const setupContainer = async () => {
  const container = new RabbitMQContainer();

  await container.start();
  await container.save();
};

export default setupContainer;
