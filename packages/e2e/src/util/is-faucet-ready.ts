/* eslint-disable no-console */
/* eslint-disable @typescript-eslint/no-floating-promises */
import * as Process from 'process';
import { faucetProviderFactory, getLogger } from '../factories';

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

/**
 * Waits until the faucet is ready.
 */
(async () => {
  if (Process.env.FAUCET_PROVIDER === undefined) {
    console.error('The FAUCET_PROVIDER env variable must be defined');
    return -1;
  }

  if (Process.env.FAUCET_PROVIDER_PARAMS === undefined) {
    console.error('The FAUCET_PROVIDER_PARAMS env variable must be defined');
    return -1;
  }

  const logSeverity = Process.env.LOGGER_MIN_SEVERITY ? Process.env.LOGGER_MIN_SEVERITY : 'debug';

  const faucetProvider = await faucetProviderFactory.create(
    Process.env.FAUCET_PROVIDER,
    JSON.parse(Process.env.FAUCET_PROVIDER_PARAMS),
    getLogger(logSeverity)
  );

  await faucetProvider.start();

  const start = Date.now() / 1000;
  const waitTime = Process.env.LOCAL_NETWORK_READY_WAIT_TIME ? Process.env.LOCAL_NETWORK_READY_WAIT_TIME : 1200;
  let isReady = false;
  let currentElapsed = 0;

  while (!isReady && currentElapsed < waitTime) {
    try {
      console.log('Waiting for faucet...');
      isReady = (await faucetProvider.healthCheck()).ok;
    } catch {
      // continue
    } finally {
      currentElapsed = Date.now() / 1000 - start;
      await sleep(5000);
    }
  }

  if (currentElapsed > waitTime) {
    console.error('Wait time expired. The faucet was not ready on time.');
    return -1;
  }

  console.log('Faucet ready!');
})();
