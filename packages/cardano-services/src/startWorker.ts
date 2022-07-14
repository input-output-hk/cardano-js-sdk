#!/usr/bin/env node
import * as envalid from 'envalid';
import { CACHE_TTL_DEFAULT } from './InMemoryCache';
import { LogLevel } from 'bunyan';
import {
  OGMIOS_URL_DEFAULT,
  PARALLEL_MODE_DEFAULT,
  PARALLEL_TXS_DEFAULT,
  POLLING_CYCLE_DEFAULT,
  RABBITMQ_URL_DEFAULT,
  loadTxWorker
} from './TxWorker';
import { SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT, SERVICE_DISCOVERY_TIMEOUT_DEFAULT } from './Program';
import { URL } from 'url';
import { cacheTtlValidator } from './util/validators';
import { config } from 'dotenv';
import { loggerMethodNames } from './util';
import onDeath from 'death';

const envSpecs = {
  CACHE_TTL: envalid.makeValidator(cacheTtlValidator)(envalid.num({ default: CACHE_TTL_DEFAULT })),
  LOGGER_MIN_SEVERITY: envalid.str({ choices: loggerMethodNames as string[], default: 'info' }),
  OGMIOS_SRV_SERVICE_NAME: envalid.str({ default: undefined }),
  OGMIOS_URL: envalid.url({ default: OGMIOS_URL_DEFAULT }),
  PARALLEL: envalid.bool({ default: PARALLEL_MODE_DEFAULT }),
  PARALLEL_TXS: envalid.num({ default: PARALLEL_TXS_DEFAULT }),
  POLLING_CYCLE: envalid.num({ default: POLLING_CYCLE_DEFAULT }),
  RABBITMQ_SRV_SERVICE_NAME: envalid.str({ default: undefined }),
  RABBITMQ_URL: envalid.url({ default: RABBITMQ_URL_DEFAULT }),
  SERVICE_DISCOVERY_BACKOFF_FACTOR: envalid.num({ default: SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT }),
  SERVICE_DISCOVERY_TIMEOUT: envalid.num({ default: SERVICE_DISCOVERY_TIMEOUT_DEFAULT })
};

void (async () => {
  config();
  const env = envalid.cleanEnv(process.env, envSpecs);

  try {
    const worker = await loadTxWorker({
      options: {
        cacheTtl: env.CACHE_TTL,
        loggerMinSeverity: env.LOGGER_MIN_SEVERITY as LogLevel,
        ogmiosSrvServiceName: env.OGMIOS_SRV_SERVICE_NAME,
        ogmiosUrl: new URL(env.OGMIOS_URL),
        parallel: env.PARALLEL,
        parallelTxs: env.PARALLEL_TXS,
        pollingCycle: env.POLLING_CYCLE,
        rabbitmqSrvServiceName: env.RABBITMQ_SRV_SERVICE_NAME,
        rabbitmqUrl: new URL(env.RABBITMQ_URL),
        serviceDiscoveryBackoffFactor: env.SERVICE_DISCOVERY_BACKOFF_FACTOR,
        serviceDiscoveryTimeout: env.SERVICE_DISCOVERY_TIMEOUT
      }
    });
    await worker.start();
    onDeath(async () => {
      await worker.stop();
      // eslint-disable-next-line unicorn/no-process-exit
      process.exit(1);
    });
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error(error);
    // eslint-disable-next-line unicorn/no-process-exit
    process.exit(1);
  }
})();
