import { parse } from 'pg-connection-string';
import { setupPostgresContainer } from './docker';
import { setupRabbitMQContainer } from '../../../rabbitmq/test/jest-setup/docker';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.join(__dirname, '../../.env.test') });

module.exports = async () => {
  const { user, password, port } = parse(
    process.env.DB_CONNECTION_STRING
      ? process.env.DB_CONNECTION_STRING
      : 'postgresql://postgres:mysecretpassword@127.0.0.1:5432/cardano'
  );
  await setupPostgresContainer(
    user ? user : 'postgres',
    password ? password : 'mysecretpassword',
    port ? port : '5432'
  );
  await setupRabbitMQContainer();
};
