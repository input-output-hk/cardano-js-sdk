import { containerExec, imageExists, pullImageAsync } from 'dockerode-utils';
import Docker from 'dockerode';

export { Docker };
export { containerExec } from 'dockerode-utils';

const CONTAINER_IMAGE = 'postgres:12.16-alpine';
const CONTAINER_NAME = 'cardano-test';

export const removePostgresContainer = async (): Promise<void> => {
  const docker = new Docker();
  try {
    const container = docker.getContainer(CONTAINER_NAME);
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

const ensurePgServiceReadiness = async (container: Docker.Container, user: string, db: string) => {
  await containerExec(container, [
    'bash',
    '-c',
    `until psql -U ${user} ${db} -c "SELECT 1" > /dev/null 2>&1 ; do echo "waiting pg service to be ready"; sleep 1; done`
  ]);
};

export const setupPostgresContainer = async (
  user: string,
  password: string,
  port: string,
  binds: Docker.HostConfig['Binds'],
  checkDb: string
) => {
  const docker = new Docker();
  const needsToPull = !(await imageExists(docker, CONTAINER_IMAGE));

  if (needsToPull) await pullImageAsync(docker, CONTAINER_IMAGE);

  await removePostgresContainer();

  const container = await docker.createContainer({
    Env: [`POSTGRES_PASSWORD=${password}`, `POSTGRES_USER=${user}`],
    HostConfig: {
      Binds: binds,
      PortBindings: {
        '5432/tcp': [
          {
            HostPort: port
          }
        ]
      }
    },
    Image: CONTAINER_IMAGE,
    name: CONTAINER_NAME
  });
  await container.start();

  await ensurePgServiceReadiness(container, user, checkDb);
  return container;
};
