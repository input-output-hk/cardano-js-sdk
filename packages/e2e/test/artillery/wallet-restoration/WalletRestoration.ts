import { AddressType, util } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { Pool } from 'pg';
import {
  createMockKeyAgent,
  getEnv,
  getWallet,
  waitForWalletStateSettle,
  walletVariables
} from '../../../src/index.js';
import { findAddressesWithRegisteredStakeKey } from './queries.js';
import { logger } from '@cardano-sdk/util-dev';
import type { AddressesModel, WalletVars } from './types.js';
import type { FunctionHook } from '../artillery.js';
import type { GroupedAddress } from '@cardano-sdk/key-management';

export const mapToGroupedAddress = (addrModel: AddressesModel): GroupedAddress => ({
  accountIndex: 0,
  address: Cardano.PaymentAddress(addrModel.address),
  index: 0,
  networkId: addrModel.address.startsWith('addr_test') ? Cardano.NetworkId.Testnet : Cardano.NetworkId.Mainnet,
  rewardAccount: Cardano.RewardAccount(addrModel.stake_address),
  type: AddressType.External
});

const env = getEnv([
  ...walletVariables,
  'DB_SYNC_CONNECTION_STRING',
  'ARRIVAL_PHASE_DURATION_IN_SECS',
  'VIRTUAL_USERS_COUNT',
  'WALLET_SYNC_TIMEOUT_IN_MS'
]);

const operationName = 'wallet-restoration';
const syncTimeout = env.WALLET_SYNC_TIMEOUT_IN_MS;

const getNetworkName = ({ networkMagic }: Cardano.ChainId) => {
  switch (networkMagic) {
    case Cardano.NetworkMagics.Mainnet:
      return 'mainnet';
    case Cardano.NetworkMagics.Preprod:
      return 'preprod';
    default:
  }
};

/**
 * Extract addresses from predefined dump if specified network exists,
 * otherwise fallback extraction using DB query (mainly to support local network env).
 *
 * @param {number} count Number of addresses to extract
 * @returns {AddressesModel[]} Addresses subset
 */
const extractAddresses = async (count: number): Promise<AddressesModel[]> => {
  let result: AddressesModel[] = [];
  const network = getNetworkName(env.KEY_MANAGEMENT_PARAMS.chainId);
  try {
    if (network) {
      const dump = require(`../../dump/addresses/${network}.json`);
      if (dump.length < count) {
        throw new Error(`You can not restore more than ${dump.length} distinct wallets for ${network} network.`);
      }
      result = dump.slice(0, count);
      logger.info(`Selected subset of predefined ${network} addresses with count: ${result.length}.`);
    } else if (env.DB_SYNC_CONNECTION_STRING) {
      const db = new Pool({ connectionString: env.DB_SYNC_CONNECTION_STRING });
      logger.info('About to query db for distinct addresses.');
      result = (await db.query(findAddressesWithRegisteredStakeKey, [count])).rows;
      if (result.length < count) {
        throw new Error(`Addresses found from db are less than desired wallets count of ${count}`);
      }
      logger.info(`Found DB addresses count: ${result.length}`);
    } else {
      throw new Error('Please provide a valid KEY_MANAGEMENT_PARAMS or DB_SYNC_CONNECTION_STRING env variable.');
    }
  } catch (error) {
    throw new Error(`Error was thrown while extracting addresses due to: ${error}`);
  }
  return result;
};

export const getAddresses: FunctionHook<WalletVars> = async ({ vars }, _, done) => {
  vars.walletLoads = Number(env.VIRTUAL_USERS_COUNT);
  const result = await extractAddresses(vars.walletLoads);
  vars.addresses = result.map(mapToGroupedAddress);
  done();
};

/** The current index of found addresses list */
let index = 0;

export const walletRestoration: FunctionHook<WalletVars> = async ({ vars, _uid }, ee, done) => {
  const currentAddress = vars.addresses[index];
  logger.info(`Current address: ${currentAddress.address}`);
  ++index;

  try {
    // Creates Stub KeyAgent
    const keyAgent = util.createAsyncKeyAgent(createMockKeyAgent([currentAddress]));

    // Start to measure wallet restoration time
    const startedAt = Date.now();
    const { wallet } = await getWallet({
      env,
      idx: 0,
      keyAgent,
      logger,
      name: `Test Wallet of VU with id: ${_uid}`,
      polling: { interval: 50 }
    });

    vars.currentWallet = wallet;
    await waitForWalletStateSettle(wallet, syncTimeout);

    // Emit custom metrics
    ee.emit('histogram', `${operationName}.time`, Date.now() - startedAt);
    ee.emit('counter', operationName, 1);

    logger.info(
      `Wallet with name ${vars.currentWallet.name} and address ${currentAddress.address} was successfully restored`
    );
  } catch (error) {
    ee.emit('counter', `${operationName}.error`, 1);
    logger.error(
      `Error was thrown while wallet restoration for ${vars.currentWallet.name} with address ${currentAddress.address} caused by: ${error}`
    );
  }

  done();
};

export const shutdownWallet: FunctionHook<WalletVars> = async ({ vars, _uid }, _ee, done) => {
  vars.currentWallet?.shutdown();
  logger.info(`Wallet with VU id ${_uid} was shutdown`);
  done();
};
