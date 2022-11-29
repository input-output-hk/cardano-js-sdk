/* eslint-disable max-len */
import { containerExec, imageExists, pullImageAsync } from 'dockerode-utils';
import Docker from 'dockerode';
import path from 'path';

const CONTAINER_IMAGE = 'postgres:11.5-alpine';
const CONTAINER_TEMP_DIR = '/tmp';
const CONTAINER_NAME = 'cardano-test';

const databaseConfigs = {
  localnetwork: {
    database: 'localnetwork',
    fixture: false,
    snapshot: true
  }
};

export const removePostgresContainer = async (): Promise<void> => {
  const docker = new Docker();
  try {
    const container = await docker.getContainer(CONTAINER_NAME);
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

interface DatabaseConfig {
  database: string;
  snapshot: boolean;
  fixture: boolean;
}

const ensureDatabaseExistence = async (container: Docker.Container, user: string, database: string) => {
  await containerExec(container, [
    'bash',
    '-c',
    `until psql -U ${user} -t -c "SELECT datname FROM pg_catalog.pg_database WHERE datname='${database}'" | grep ${database} ; do echo "waiting ${database} db to be created"; sleep 1 ; done`
  ]);
};

const ensurePgServiceReadiness = async (container: Docker.Container, user: string) => {
  await containerExec(container, [
    'bash',
    '-c',
    `until psql -U ${user} -c "SELECT 1" > /dev/null 2>&1 ; do echo "waiting pg service to be ready"; sleep 1; done`
  ]);
};

const setupDBData = async (databaseConfig: DatabaseConfig, user: string, container: Docker.Container) => {
  const { database, snapshot, fixture } = databaseConfig;

  await containerExec(container, ['bash', '-c', `psql -U ${user} -c "CREATE DATABASE ${database}"`]);

  if (snapshot) {
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

  if (fixture) {
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

  await ensureDatabaseExistence(container, user, database);
};

export const setupPostgresContainer = async (user: string, password: string, port: string): Promise<void> => {
  const docker = new Docker();
  const needsToPull = !(await imageExists(docker, CONTAINER_IMAGE));

  if (needsToPull) await pullImageAsync(docker, CONTAINER_IMAGE);

  await removePostgresContainer();

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

  await ensurePgServiceReadiness(container, user);
  await setupDBData(databaseConfigs.localnetwork, user, container);
};
