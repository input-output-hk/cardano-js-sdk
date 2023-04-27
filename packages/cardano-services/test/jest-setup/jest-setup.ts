import { DockerUtil } from '@cardano-sdk/util-dev';
import { RabbitMQContainer } from '../TxSubmit/rabbitmq/docker';
import { parse } from 'pg-connection-string';
import dotenv from 'dotenv';
import path from 'path';

const CONTAINER_TEMP_DIR = '/tmp';

dotenv.config({ path: path.join(__dirname, '../../.env.test') });

interface DatabaseConfig {
  database: string;
  snapshot: boolean;
  fixture: boolean;
}

const databaseConfigs = {
  localnetwork: {
    database: 'localnetwork',
    fixture: false,
    snapshot: true
  }
};

const createDatabase = async (container: DockerUtil.Docker.Container, user: string, database: string) => {
  const create = await DockerUtil.containerExec(container, [
    'bash',
    '-c',
    `psql -U ${user} -c "CREATE DATABASE ${database}"`
  ]);
  if (create.length !== 1 || !create[0].match('CREATE DATABASE'))
    throw new Error(`Error while creating the DB ${JSON.stringify(create)}`);
  await DockerUtil.ensureDatabaseExistence(container, user, database);
};

const setupDBData = async (databaseConfig: DatabaseConfig, user: string, container: DockerUtil.Docker.Container) => {
  const { database, snapshot, fixture } = databaseConfig;

  await createDatabase(container, user, database);

  if (snapshot) {
    await container.putArchive(path.join(__dirname, `${database}-db-snapshot.tar`), {
      User: 'root',
      path: CONTAINER_TEMP_DIR
    });

    // Execute backup restore
    await DockerUtil.containerExec(container, [
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

    await DockerUtil.containerExec(container, [
      'bash',
      '-c',
      `cat ${CONTAINER_TEMP_DIR}/${database}-fixture-data.sql | psql -U ${user} ${database}`
    ]);
  }
};

module.exports = async () => {
  const {
    user = 'postgres',
    password = 'mysecretpassword',
    port
  } = parse(
    process.env.POSTGRES_CONNECTION_STRING
      ? process.env.POSTGRES_CONNECTION_STRING
      : 'postgresql://postgres:mysecretpassword@127.0.0.1:5432/cardano'
  );

  const pgContainer = await DockerUtil.setupPostgresContainer(user, password, port || '5432');
  await setupDBData(databaseConfigs.localnetwork, user, pgContainer);
  await createDatabase(pgContainer, user, 'projection');

  const container = new RabbitMQContainer();

  await container.start();
  await container.save();
};
