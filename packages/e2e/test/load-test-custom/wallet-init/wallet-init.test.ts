/* eslint-disable import/imports-first */
import * as dotenv from 'dotenv';
import path from 'path';

// This line must come before loading the env, to configure the location of the .env file
dotenv.config({ path: path.join(__dirname, '../../../.env') });

import { BaseWallet, createPersonalWallet } from '@cardano-sdk/wallet';
import { Logger } from 'ts-log';
import { bufferCount, bufferTime, from, mergeAll, tap } from 'rxjs';
import { logger } from '@cardano-sdk/util-dev';

import { Bip32Account, util } from '@cardano-sdk/key-management';
import {
  MeasurementUtil,
  assetProviderFactory,
  bip32Ed25519Factory,
  chainHistoryProviderFactory,
  getEnv,
  getLoadTestScheduler,
  keyManagementFactory,
  networkInfoProviderFactory,
  rewardsProviderFactory,
  stakePoolProviderFactory,
  txSubmitProviderFactory,
  utxoProviderFactory,
  waitForWalletStateSettle,
  walletVariables
} from '../../../src';

// Example call that creates 5000 wallets in 10 minutes:
// VIRTUAL_USERS_GENERATE_DURATION=600 VIRTUAL_USERS_COUNT=5000 yarn load-test-custom:wallet-init

const env = getEnv([...walletVariables, 'VIRTUAL_USERS_COUNT', 'VIRTUAL_USERS_GENERATE_DURATION']);
const intermediateResultsInterval = 10_000;
const walletsShutdownBatchSize = 100;
const testLogger: Logger = console;

enum MeasureTarget {
  keyAgent = 'keyAgent',
  wallet = 'wallet'
}

const measurementUtil = new MeasurementUtil<keyof typeof MeasureTarget>();

// Utility methods to help setup the test. They could be part of another file
const getProviders = async () => ({
  assetProvider: await assetProviderFactory.create(env.ASSET_PROVIDER, env.ASSET_PROVIDER_PARAMS, logger),
  chainHistoryProvider: await chainHistoryProviderFactory.create(
    env.CHAIN_HISTORY_PROVIDER,
    env.CHAIN_HISTORY_PROVIDER_PARAMS,
    logger
  ),
  networkInfoProvider: await networkInfoProviderFactory.create(
    env.NETWORK_INFO_PROVIDER,
    env.NETWORK_INFO_PROVIDER_PARAMS,
    logger
  ),
  rewardsProvider: await rewardsProviderFactory.create(env.REWARDS_PROVIDER, env.REWARDS_PROVIDER_PARAMS, logger),
  stakePoolProvider: await stakePoolProviderFactory.create(
    env.STAKE_POOL_PROVIDER,
    env.STAKE_POOL_PROVIDER_PARAMS,
    logger
  ),
  txSubmitProvider: await txSubmitProviderFactory.create(env.TX_SUBMIT_PROVIDER, env.TX_SUBMIT_PROVIDER_PARAMS, logger),
  utxoProvider: await utxoProviderFactory.create(env.UTXO_PROVIDER, env.UTXO_PROVIDER_PARAMS, logger)
});

const getKeyAgent = async (accountIndex: number) => {
  const createKeyAgent = await keyManagementFactory.create(
    env.KEY_MANAGEMENT_PROVIDER,
    { ...env.KEY_MANAGEMENT_PARAMS, accountIndex },
    logger
  );
  const bip32Ed25519 = await bip32Ed25519Factory.create(env.KEY_MANAGEMENT_PARAMS.bip32Ed25519, null, logger);
  const keyAgent = await createKeyAgent({ bip32Ed25519, logger });
  return { keyAgent };
};

const createWallet = async (accountIndex: number): Promise<BaseWallet> => {
  measurementUtil.addStartMarker(MeasureTarget.keyAgent, accountIndex);
  const providers = await getProviders();
  const { keyAgent } = await getKeyAgent(accountIndex);
  measurementUtil.addMeasureMarker(MeasureTarget.keyAgent, accountIndex);

  measurementUtil.addStartMarker(MeasureTarget.wallet, accountIndex);
  return createPersonalWallet(
    { name: `Wallet ${accountIndex}` },
    {
      ...providers,
      bip32Account: await Bip32Account.fromAsyncKeyAgent(keyAgent),
      logger,
      witnesser: util.createBip32Ed25519Witnesser(keyAgent)
    }
  );
};

const initWallet = async (idx: number) => {
  const wallet = await createWallet(idx);
  await waitForWalletStateSettle(wallet);
  measurementUtil.addMeasureMarker(MeasureTarget.wallet, idx);
  return wallet;
};

// A very simple print function. Measurement util returns an object that could be used in any way.
const showResults = () => {
  testLogger.info('Measurements:', measurementUtil.getMeasurements([MeasureTarget.wallet, MeasureTarget.keyAgent]));
};

// Starts observing measurement markers. If this method is not called, no measurements are done.
measurementUtil.start();

// Simple scheduler that distributes the requested number of calls evenly in the duration time
getLoadTestScheduler<BaseWallet>(
  {
    // callUnderTest must be a method returning an observable
    callUnderTest: (id) => from(initWallet(id)),
    callsPerDuration: env.VIRTUAL_USERS_COUNT,
    duration: env.VIRTUAL_USERS_GENERATE_DURATION
  },
  { logger: testLogger }
)
  .pipe(
    bufferTime(intermediateResultsInterval),
    tap(() => {
      testLogger.info(`\nPartial results every ${intermediateResultsInterval}ms:`);
      showResults();
    }),
    mergeAll(),
    bufferCount(walletsShutdownBatchSize)
  )
  .subscribe({
    complete: () => {
      testLogger.info('--------- Final results -----------------');
      showResults();
      measurementUtil.stop();
    },
    next: (wallets) => {
      testLogger.info(`Shutting down ${wallets.length} wallets`);
      for (const wallet of wallets) wallet.shutdown();
    }
  });
