import { DockerUtil } from '@cardano-sdk/util-dev';
import { RabbitMQContainer } from '../TxSubmit/rabbitmq/docker';
import { parse } from 'pg-connection-string';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.join(__dirname, '../../.env.test') });

module.exports = async () => {
  const {
    user = 'postgres',
    password = 'mysecretpassword',
    port
  } = parse(
    process.env.POSTGRES_CONNECTION_STRING_DB_SYNC
      ? process.env.POSTGRES_CONNECTION_STRING_DB_SYNC
      : 'postgresql://postgres:mysecretpassword@127.0.0.1:5432/cardano'
  );

  await DockerUtil.setupPostgresContainer(
    user,
    password,
    port || '5432',
    [`${path.join(__dirname, 'snapshots')}:/docker-entrypoint-initdb.d`],
    'dump_check'
  );

  const container = new RabbitMQContainer();

  await container.start();
  await container.save();
};
