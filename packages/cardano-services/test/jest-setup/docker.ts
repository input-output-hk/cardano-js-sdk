import { containerExec, imageExists, pullImageAsync } from 'dockerode-utils';
import Docker from 'dockerode';
import path from 'path';

const CONTAINER_IMAGE = 'postgres:11.5-alpine';
const CONTAINER_TEMP_DIR = '/tmp';
const CONTAINER_NAME = 'cardano-test';

export const removePostgresContainer = async (): Promise<void> => {
  const docker = new Docker();
  const container = await docker.getContainer(CONTAINER_NAME);
  await container.stop();
  await container.remove({ v: true });
};

interface DatabaseConfig {
  database: string;
  snapshot: boolean;
  fixture: boolean;
}

const setupDBData = async (databaseConfig: DatabaseConfig, user: string, container: Docker.Container) => {
  const database = databaseConfig.database;

  await containerExec(container, ['bash', '-c', `psql -U ${user} -c "CREATE DATABASE ${database}"`]);

  if (databaseConfig.snapshot) {
    await container.putArchive(path.join(__dirname, `${database}-db-snapshot.tar`), {
      User: 'root',
      path: CONTAINER_TEMP_DIR
    });
    // Execute backup restore
    await containerExec(container, [
      'bash',
      '-c',
      `cat ${CONTAINER_TEMP_DIR}/${database}.bak | psql -U ${user} ${database}`
    ]);
  }

  if (databaseConfig.fixture) {
    await container.putArchive(path.join(__dirname, `${database}-fixture-data.tar`), {
      User: 'root',
      path: CONTAINER_TEMP_DIR
    });

    await containerExec(container, [
      'bash',
      '-c',
      `cat ${CONTAINER_TEMP_DIR}/${database}-fixture-data.sql | psql -U ${user} ${database}`
    ]);
  }
};

export const setupPostgresContainer = async (user: string, password: string, port: string): Promise<void> => {
  const docker = new Docker();
  const needsToPull = !(await imageExists(docker, CONTAINER_IMAGE));
  if (needsToPull) await pullImageAsync(docker, CONTAINER_IMAGE);

  const container = await docker.createContainer({
    Env: [`POSTGRES_PASSWORD=${password}`, `POSTGRES_USER=${user}`],
    HostConfig: {
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

  // Wait for the db service to be running (container started event is not enough)
  await containerExec(container, [
    'bash',
    '-c',
    `until psql -U ${user} -c "select 1" > /dev/null 2>&1 ; do sleep 1; done`
  ]);

  const databaseConfigs = [
    {
      database: 'testnet',
      fixture: true,
      snapshot: true
    }
  ];

  for (const databaseConfig of databaseConfigs) {
    await setupDBData(databaseConfig, user, container);
  }
};
