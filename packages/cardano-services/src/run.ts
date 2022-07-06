#!/usr/bin/env node
import * as envalid from 'envalid';
import { API_URL_DEFAULT, OGMIOS_URL_DEFAULT, RABBITMQ_URL_DEFAULT, ServiceNames, loadHttpServer } from './Program';
import { CACHE_TTL_DEFAULT } from './InMemoryCache';
import { DB_POLL_INTERVAL_DEFAULT } from './NetworkInfo';
import { ENABLE_METRICS_DEFAULT, USE_QUEUE_DEFAULT } from './ProgramsCommon';
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
  CARDANO_NODE_CONFIG_PATH: envalid.str({ default: undefined }),
  DB_CONNECTION_STRING: envalid.str({ default: undefined }),
  DB_POLL_INTERVAL: envalid.num({ default: DB_POLL_INTERVAL_DEFAULT }),
  DB_QUERIES_CACHE_TTL: envalid.makeValidator(cacheTtlValidator)(envalid.num({ default: CACHE_TTL_DEFAULT })),
  ENABLE_METRICS: envalid.bool({ default: ENABLE_METRICS_DEFAULT }),
  LOGGER_MIN_SEVERITY: envalid.str({ choices: loggerMethodNames as string[], default: 'info' }),
  OGMIOS_URL: envalid.url({ default: OGMIOS_URL_DEFAULT }),
  POSTGRES_DB_FILE: existingFileValidator({ default: undefined }),
  POSTGRES_HOST: envalid.host({ default: undefined }),
  POSTGRES_PASSWORD_FILE: existingFileValidator({ default: undefined }),
  POSTGRES_PORT: envalid.num({ default: undefined }),
  POSTGRES_USER_FILE: existingFileValidator({ default: undefined }),
  RABBITMQ_URL: envalid.url({ default: RABBITMQ_URL_DEFAULT }),
  SERVICE_NAMES: envalid.str({ example: Object.values(ServiceNames).toString() }),
  USE_QUEUE: envalid.bool({ default: USE_QUEUE_DEFAULT })
};

const loadSecret = (path: string) => fs.readFileSync(path, 'utf8').toString();

void (async () => {
  config();
  const env = envalid.cleanEnv(process.env, envSpecs);
  const apiUrl = new URL(env.API_URL);
  const ogmiosUrl = new URL(env.OGMIOS_URL);
  const rabbitmqUrl = new URL(env.RABBITMQ_URL);
  const cardanoNodeConfigPath = env.CARDANO_NODE_CONFIG_PATH;
  const dbQueriesCacheTtl = env.DB_QUERIES_CACHE_TTL;
  const dbPollInterval = env.DB_POLL_INTERVAL;
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
        cardanoNodeConfigPath,
        dbConnectionString,
        dbPollInterval,
        dbQueriesCacheTtl,
        loggerMinSeverity: env.LOGGER_MIN_SEVERITY as LogLevel,
        metricsEnabled,
        ogmiosUrl,
        rabbitmqUrl,
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
