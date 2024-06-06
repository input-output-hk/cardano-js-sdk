/* eslint-disable import/imports-first */
// This line must come before loading the env, to configure the location of the .env file
import * as dotenv from 'dotenv';
import path from 'path';
dotenv.config({ path: path.join(__dirname, '../../../.env') });
import {
  MINUTE,
  createMockKeyAgent,
  getEnv,
  getWallet,
  waitForWalletStateSettle,
  walletVariables
} from '../../../src/index.js';
import { logger } from '@cardano-sdk/util-dev';
import { mapToGroupedAddress } from '../../artillery/wallet-restoration/WalletRestoration.js';
import { util } from '@cardano-sdk/key-management';
import type { BaseWallet } from '@cardano-sdk/wallet';
import type { Cardano } from '@cardano-sdk/core';
import type { GroupedAddress } from '@cardano-sdk/key-management';
import type { Logger } from 'ts-log';

/** Env var MAX_USERS sets the maximum number of concurrent users to measure default value 100 */
const RESTORATION_TIMEOUT = process.env.RESTORATION_TIMEOUT
  ? Number.parseInt(process.env.RESTORATION_TIMEOUT)
  : 5 * MINUTE;
const resultsFilePrefix = 'restoration'; // group suffix and extension will be added to file name
// user groups with different numbers of tx in wallet
const groups = [
  [1, 10],
  [10, 100],
  [100, 1000]
];
const fs = require('fs');
const env = getEnv([...walletVariables, 'DB_SYNC_CONNECTION_STRING']);
const testLogger: Logger = console;
const formattedDate = new Date().toISOString().split('T')[0];
const dirName = `./${formattedDate}/`;
const range = (toNum: number) => {
  // [1 ... toNum]
  const resArr = [...Array.from({ length: toNum + 1 }).keys()];
  resArr.shift();
  return resArr;
};

const initWallets = async (walletsNum: number, addresses: GroupedAddress[]): Promise<BaseWallet[]> => {
  testLogger.info('Number of concurrent users: ', walletsNum);
  let currentAddress;
  const wallets = [];
  for (let i = 0; i < walletsNum; i++) {
    currentAddress = addresses[i];
    testLogger.info('  address:', currentAddress.address);
    const keyAgent = util.createAsyncKeyAgent(createMockKeyAgent([currentAddress]));
    const { wallet } = await getWallet({
      env,
      idx: 0,
      keyAgent,
      logger,
      name: 'Test Wallet',
      polling: { interval: 50 }
    });
    wallets.push(wallet);
  }
  return wallets;
};

const measureRestorationTime = async (maxUsers: number, addresses: GroupedAddress[], resultsFile: string) => {
  for (let users = 1; users <= maxUsers; users++) {
    const wallets = await initWallets(users, addresses.slice(0, maxUsers));
    addresses.splice(0, maxUsers);
    try {
      const start = Date.now();
      const resp = await Promise.all(wallets.map(async (w) => await waitForWalletStateSettle(w, RESTORATION_TIMEOUT)));
      if (resp.some((r) => !r)) testLogger.error('Restoration failed');
      const stop = Date.now();
      const time = (stop - start) / 1000;
      testLogger.info('Restoration time - ', time);
      await fs.appendFile(resultsFile, `${wallets.length},${time}\n`, { flag: 'a' }, (err: never) => {
        if (err) {
          testLogger.error(err);
        }
      });
      for (const w of wallets) w.shutdown();
    } catch (error) {
      testLogger.error(error);
    }
  }
};

type TestData = {
  tx_count: number;
  address: Cardano.PaymentAddress;
  stake_address: Cardano.RewardAddress;
};

// Test measures response time for increasing number of concurrent users up to MAX-USERS
const runTest = async () => {
  if (!fs.existsSync(dirName)) {
    fs.mkdirSync(dirName);
  }
  const maxUsers = process.env.MAX_USERS ? Number.parseInt(process.env.MAX_USERS) : 100;
  // calculate number of addresses needed for `maxUsers` measurements
  const numAddresses = range(maxUsers).reduce((a, b) => a + b);
  const result = require('../../dump/addresses/mainnet.json');
  for (const group of groups) {
    testLogger.info(`Measurements or addresses with ${group[0]} to ${group[1]} txs`);
    const filteredAddr = result.filter((e: TestData) => e.tx_count > group[0] && e.tx_count < group[1]);
    if (filteredAddr < numAddresses) throw new Error('Not enough addresses!');
    const addresses: GroupedAddress[] = filteredAddr.map(mapToGroupedAddress);
    const creationTime = new Date().toISOString().split('T')[1];
    const resultsFile = `${dirName}${resultsFilePrefix}-${group[0]}-${group[1]}-${creationTime}.csv`;
    await measureRestorationTime(maxUsers, addresses, resultsFile);
    testLogger.info('Results appended to file - ', resultsFile);
  }
};
runTest().catch(() => {
  testLogger.error('Execution failed');
});
