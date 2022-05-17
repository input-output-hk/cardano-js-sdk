#!/usr/bin/env node
/* eslint-disable import/imports-first */
require('../scripts/patchRequire');
import * as envalid from 'envalid';
import { API_URL_DEFAULT, OGMIOS_URL_DEFAULT, RABBITMQ_URL_DEFAULT, ServiceNames, loadHttpServer } from './Program';
import { LogLevel } from 'bunyan';
import { URL } from 'url';
import { config } from 'dotenv';
import { loggerMethodNames } from './util';
import onDeath from 'death';

const envSpecs = {
  API_URL: envalid.url({ default: API_URL_DEFAULT }),
  DB_CONNECTION_STRING: envalid.str({ default: undefined }),
  LOGGER_MIN_SEVERITY: envalid.str({ choices: loggerMethodNames as string[], default: 'info' }),
  OGMIOS_URL: envalid.url({ default: OGMIOS_URL_DEFAULT }),
  RABBITMQ_URL: envalid.url({ default: RABBITMQ_URL_DEFAULT }),
  SERVICE_NAMES: envalid.str({ example: Object.values(ServiceNames).toString() }),
  USE_QUEUE: envalid.bool({ default: false })
};

void (async () => {
  config();
  const env = envalid.cleanEnv(process.env, envSpecs);
  const apiUrl = new URL(env.API_URL);
  const ogmiosUrl = new URL(env.OGMIOS_URL);
  const rabbitmqUrl = new URL(env.RABBITMQ_URL);
  const dbConnectionString = env.DB_CONNECTION_STRING ? new URL(env.DB_CONNECTION_STRING).toString() : undefined;
  const serviceNames = env.SERVICE_NAMES.split(',') as ServiceNames[];

  try {
    const server = await loadHttpServer({
      apiUrl,
      options: {
        dbConnectionString,
        loggerMinSeverity: env.LOGGER_MIN_SEVERITY as LogLevel,
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
  }
})();
