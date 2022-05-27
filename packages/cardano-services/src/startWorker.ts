#!/usr/bin/env node
/* eslint-disable import/imports-first */
require('../scripts/patchRequire');
import * as envalid from 'envalid';
import { LogLevel } from 'bunyan';
import {
  OGMIOS_URL_DEFAULT,
  PARALLEL_MODE_DEFAULT,
  PARALLEL_TXS_DEFAULT,
  POLLING_CYCLE_DEFAULT,
  RABBITMQ_URL_DEFAULT,
  loadTxWorker
} from './TxWorker';
import { URL } from 'url';
import { config } from 'dotenv';
import { loggerMethodNames } from './util';
import onDeath from 'death';

const envSpecs = {
  LOGGER_MIN_SEVERITY: envalid.str({ choices: loggerMethodNames as string[], default: 'info' }),
  OGMIOS_URL: envalid.url({ default: OGMIOS_URL_DEFAULT }),
  PARALLEL: envalid.bool({ default: PARALLEL_MODE_DEFAULT }),
  PARALLEL_TXS: envalid.num({ default: PARALLEL_TXS_DEFAULT }),
  POLLING_CYCLE: envalid.num({ default: POLLING_CYCLE_DEFAULT }),
  RABBITMQ_URL: envalid.url({ default: RABBITMQ_URL_DEFAULT })
};

void (async () => {
  config();
  const env = envalid.cleanEnv(process.env, envSpecs);

  try {
    const worker = await loadTxWorker({
      options: {
        loggerMinSeverity: env.LOGGER_MIN_SEVERITY as LogLevel,
        ogmiosUrl: new URL(env.OGMIOS_URL),
        parallel: env.PARALLEL,
        parallelTxs: env.PARALLEL_TXS,
        pollingCycle: env.POLLING_CYCLE,
        rabbitmqUrl: new URL(env.RABBITMQ_URL)
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
