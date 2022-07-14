#!/usr/bin/env node
/* eslint-disable max-statements */
import * as envalid from 'envalid';
import {
  API_URL_DEFAULT,
  OGMIOS_URL_DEFAULT,
  RABBITMQ_URL_DEFAULT,
  SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT,
  SERVICE_DISCOVERY_TIMEOUT_DEFAULT,
  ServiceNames,
  loadHttpServer
} from './Program';
import { CACHE_TTL_DEFAULT } from './InMemoryCache';
import { ENABLE_METRICS_DEFAULT, USE_QUEUE_DEFAULT } from './ProgramsCommon';
import { EPOCH_POLL_INTERVAL_DEFAULT } from './NetworkInfo';
import { LogLevel } from 'bunyan';
import { URL } from 'url';
import { cacheTtlValidator } from './util/validators';
import { config } from 'dotenv';
import { loggerMethodNames } from './util';
import fs from 'fs';
import onDeath from 'death';

const existingFileValidator = envalid.makeValidator((filePath: string) => {
  if (fs.existsSync(filePath)) {
    return filePath;
  }
  throw new envalid.EnvError(`No file exists at ${filePath}`);
});

const envSpecs = {
  API_URL: envalid.url({ default: API_URL_DEFAULT }),
  CACHE_TTL: envalid.makeValidator(cacheTtlValidator)(envalid.num({ default: CACHE_TTL_DEFAULT })),
  CARDANO_NODE_CONFIG_PATH: envalid.str({ default: undefined }),
  DB_CONNECTION_STRING: envalid.str({ default: undefined }),
  ENABLE_METRICS: envalid.bool({ default: ENABLE_METRICS_DEFAULT }),
  EPOCH_POLL_INTERVAL: envalid.num({ default: EPOCH_POLL_INTERVAL_DEFAULT }),
  LOGGER_MIN_SEVERITY: envalid.str({ choices: loggerMethodNames as string[], default: 'info' }),
  OGMIOS_SRV_SERVICE_NAME: envalid.str({ default: undefined }),
  OGMIOS_URL: envalid.url({ default: OGMIOS_URL_DEFAULT }),
  POSTGRES_DB: envalid.str({ default: undefined }),
  POSTGRES_DB_FILE: existingFileValidator({ default: undefined }),
  POSTGRES_HOST: envalid.host({ default: undefined }),
  POSTGRES_PASSWORD: envalid.str({ default: undefined }),
  POSTGRES_PASSWORD_FILE: existingFileValidator({ default: undefined }),
  POSTGRES_PORT: envalid.num({ default: undefined }),
  POSTGRES_SRV_SERVICE_NAME: envalid.str({ default: undefined }),
  POSTGRES_USER: envalid.str({ default: undefined }),
  POSTGRES_USER_FILE: existingFileValidator({ default: undefined }),
  RABBITMQ_SRV_SERVICE_NAME: envalid.str({ default: undefined }),
  RABBITMQ_URL: envalid.url({ default: RABBITMQ_URL_DEFAULT }),
  SERVICE_DISCOVERY_BACKOFF_FACTOR: envalid.num({ default: SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT }),
  SERVICE_DISCOVERY_TIMEOUT: envalid.num({ default: SERVICE_DISCOVERY_TIMEOUT_DEFAULT }),
  SERVICE_NAMES: envalid.str({ example: Object.values(ServiceNames).toString() }),
  USE_QUEUE: envalid.bool({ default: USE_QUEUE_DEFAULT })
};

const loadSecret = (path: string) => fs.readFileSync(path, 'utf8').toString();

void (async () => {
  config();
  const env = envalid.cleanEnv(process.env, envSpecs);
  const apiUrl = new URL(env.API_URL);
  const ogmiosUrl = new URL(env.OGMIOS_URL);
  const ogmiosSrvServiceName = env.OGMIOS_SRV_SERVICE_NAME;
  const rabbitmqUrl = new URL(env.RABBITMQ_URL);
  const rabbitmqSrvServiceName = env.RABBITMQ_SRV_SERVICE_NAME;
  const cardanoNodeConfigPath = env.CARDANO_NODE_CONFIG_PATH;
  const serviceDiscoveryBackoffFactor = env.SERVICE_DISCOVERY_BACKOFF_FACTOR;
  const serviceDiscoveryTimeout = env.SERVICE_DISCOVERY_TIMEOUT;
  const postgresSrvServiceName = env.POSTGRES_SRV_SERVICE_NAME;
  const postgresDb = env.POSTGRES_DB;
  const postgresUser = env.POSTGRES_USER;
  const postgresPassword = env.POSTGRES_PASSWORD;
  const cacheTtl = env.CACHE_TTL;
  const epochPollInterval = env.EPOCH_POLL_INTERVAL;
  const dbName = env.POSTGRES_DB_FILE ? loadSecret(env.POSTGRES_DB_FILE) : undefined;
  const dbPassword = env.POSTGRES_PASSWORD_FILE ? loadSecret(env.POSTGRES_PASSWORD_FILE) : undefined;
  const dbUser = env.POSTGRES_USER_FILE ? loadSecret(env.POSTGRES_USER_FILE) : undefined;
  // Setting the connection string takes preference over secrets.
  // It can also remain undefined since there is a default value.
  let dbConnectionString;
  if (env.DB_CONNECTION_STRING) {
    dbConnectionString = new URL(env.DB_CONNECTION_STRING).toString();
  } else if (dbName && dbPassword && dbUser && env.POSTGRES_HOST && env.POSTGRES_PORT) {
    dbConnectionString = `postgresql://${dbUser}:${dbPassword}@${env.POSTGRES_HOST}:${env.POSTGRES_PORT}/${dbName}`;
  }
  const metricsEnabled = env.ENABLE_METRICS;
  const serviceNames = env.SERVICE_NAMES.split(',') as ServiceNames[];

  try {
    const server = await loadHttpServer({
      apiUrl,
      options: {
        cacheTtl,
        cardanoNodeConfigPath,
        dbConnectionString,
        epochPollInterval,
        loggerMinSeverity: env.LOGGER_MIN_SEVERITY as LogLevel,
        metricsEnabled,
        ogmiosSrvServiceName,
        ogmiosUrl,
        postgresDb,
        postgresPassword,
        postgresSrvServiceName,
        postgresUser,
        rabbitmqSrvServiceName,
        rabbitmqUrl,
        serviceDiscoveryBackoffFactor,
        serviceDiscoveryTimeout,
        useQueue: env.USE_QUEUE
      },
      serviceNames
    });
    await server.initialize();
    await server.start();
    onDeath(async () => {
      await server.shutdown();
      // eslint-disable-next-line unicorn/no-process-exit
      process.exit(1);
    });
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error(error);
    process.exit(1);
  }
})();
