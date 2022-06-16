import { connect } from 'amqplib';
import { imageExists, pullImageAsync } from 'dockerode-utils';
import Docker from 'dockerode';

const CONTAINER_IMAGE = 'rabbitmq:3.10-management';
const CONTAINER_NAME = 'cardano-rabbitmq-test';

export const removeRabbitMQContainer = async (containerName = CONTAINER_NAME) => {
  const docker = new Docker();

  try {
    const container = docker.getContainer(containerName);

    try {
      await container.stop();
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      // 304 = container already stopped
      if (error.statusCode !== 304) throw error;
    }
    await container.remove({ v: true });
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } catch (error: any) {
    // 404 = container not found
    if (error.statusCode !== 404) throw error;
  }
};

export const setupRabbitMQContainer = async (containerName = CONTAINER_NAME, port = 5672) => {
  const docker = new Docker();
  const needsToPull = !(await imageExists(docker, CONTAINER_IMAGE));

  if (needsToPull) await pullImageAsync(docker, CONTAINER_IMAGE);
  await removeRabbitMQContainer(containerName);

  const container = await docker.createContainer({
    HostConfig: { PortBindings: { '5672/tcp': [{ HostPort: `${port}` }], '15672/tcp': [{ HostPort: '15672' }] } },
    Image: CONTAINER_IMAGE,
    name: containerName
  });
  await container.start();

  // Once the container starts it is not immediately ready to accept connections
  // this waits for that short delay
  await new Promise<void>(async (resolve) => {
    // eslint-disable-next-line no-constant-condition
    while (true)
      try {
        // eslint-disable-next-line @typescript-eslint/no-shadow
        await new Promise((resolve) => setTimeout(resolve, 1000));
        await connect(`amqp://localhost:${port}`);
        return resolve();
        // eslint-disable-next-line no-empty
      } catch {}
  });
};
