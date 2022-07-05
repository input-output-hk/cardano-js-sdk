#!/usr/bin/env node
import * as envalid from 'envalid';
import {
  API_URL_DEFAULT,
  OGMIOS_URL_DEFAULT,
  RABBITMQ_URL_DEFAULT,
  SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT,
  SERVICE_DISCOVERY_BACKOFF_TIMEOUT_DEFAULT,
  ServiceNames,
  loadHttpServer
} from './Program';
import { CACHE_TTL_DEFAULT } from './InMemoryCache';
import { DB_POLL_INTERVAL_DEFAULT } from './NetworkInfo';
import { LogLevel } from 'bunyan';
import { URL } from 'url';
import { USE_QUEUE_DEFAULT } from './ProgramsCommon';
import { cacheTtlValidator } from './util/validators';
import { config } from 'dotenv';
import { loggerMethodNames } from './util';
import onDeath from 'death';

const envSpecs = {
  API_URL: envalid.url({ default: API_URL_DEFAULT }),
  CARDANO_NODE_CONFIG_PATH: envalid.str({ default: undefined }),
  DB_CONNECTION_STRING: envalid.str({ default: undefined }),
  DB_POLL_INTERVAL: envalid.num({ default: DB_POLL_INTERVAL_DEFAULT }),
  DB_QUERIES_CACHE_TTL: envalid.makeValidator(cacheTtlValidator)(envalid.num({ default: CACHE_TTL_DEFAULT })),
  LOGGER_MIN_SEVERITY: envalid.str({ choices: loggerMethodNames as string[], default: 'info' }),
  OGMIOS_SRV_SERVICE_NAME: envalid.str({ default: undefined }),
  OGMIOS_URL: envalid.url({ default: OGMIOS_URL_DEFAULT }),
  POSTGRES_NAME: envalid.str({ default: undefined }),
  POSTGRES_PASSWORD: envalid.str({ default: undefined }),
  POSTGRES_SRV_SERVICE_NAME: envalid.str({ default: undefined }),
  POSTGRES_USER: envalid.str({ default: undefined }),
  RABBITMQ_SRV_SERVICE_NAME: envalid.str({ default: undefined }),
  RABBITMQ_URL: envalid.url({ default: RABBITMQ_URL_DEFAULT }),
  SERVICE_DISCOVERY_BACKOFF_FACTOR: envalid.num({ default: SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT }),
  SERVICE_DISCOVERY_BACKOFF_TIMEOUT: envalid.num({ default: SERVICE_DISCOVERY_BACKOFF_TIMEOUT_DEFAULT }),
  SERVICE_NAMES: envalid.str({ example: Object.values(ServiceNames).toString() }),
  USE_QUEUE: envalid.bool({ default: USE_QUEUE_DEFAULT })
};

void (async () => {
  config();
  const env = envalid.cleanEnv(process.env, envSpecs);
  const apiUrl = new URL(env.API_URL);
  const ogmiosUrl = new URL(env.OGMIOS_URL);
  const ogmiosSrvServiceName = env.OGMIOS_SRV_SERVICE_NAME;
  const rabbitmqUrl = new URL(env.RABBITMQ_URL);
  const rabbitmqSrvServiceName = env.RABBITMQ_SRV_SERVICE_NAME;
  const cardanoNodeConfigPath = env.CARDANO_NODE_CONFIG_PATH;
  const dbQueriesCacheTtl = env.DB_QUERIES_CACHE_TTL;
  const dbPollInterval = env.DB_POLL_INTERVAL;
  const dbConnectionString = env.DB_CONNECTION_STRING ? new URL(env.DB_CONNECTION_STRING).toString() : undefined;
  const serviceDiscoveryBackoffFactor = env.SERVICE_DISCOVERY_BACKOFF_FACTOR;
  const serviceDiscoveryTimeout = env.SERVICE_DISCOVERY_BACKOFF_TIMEOUT;
  const postgresSrvServiceName = env.POSTGRES_SRV_SERVICE_NAME;
  const postgresName = env.POSTGRES_NAME;
  const postgresUser = env.POSTGRES_USER;
  const postgresPassword = env.POSTGRES_PASSWORD;
  const serviceNames = env.SERVICE_NAMES.split(',') as ServiceNames[];

  try {
    const server = await loadHttpServer({
      apiUrl,
      options: {
        cardanoNodeConfigPath,
        dbConnectionString,
        dbPollInterval,
        dbQueriesCacheTtl,
        loggerMinSeverity: env.LOGGER_MIN_SEVERITY as LogLevel,
        ogmiosSrvServiceName,
        ogmiosUrl,
        postgresName,
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
