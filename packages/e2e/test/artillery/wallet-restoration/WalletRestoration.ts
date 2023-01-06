import { AddressType, GroupedAddress, util } from '@cardano-sdk/key-management';
import { AddressesModel, WalletVars } from './types';
import { Cardano } from '@cardano-sdk/core';
import { FunctionHook } from '../artillery';
import { Pool, QueryResult } from 'pg';
import { StubKeyAgent, getEnv, getWallet, walletVariables } from '../../../src';
import { findAddressesWithRegisteredStakeKey } from './queries';
import { logger } from '@cardano-sdk/util-dev';
import { walletReady } from '../../util';

const env = getEnv([
  ...walletVariables,
  'DB_SYNC_CONNECTION_STRING',
  'ARRIVAL_PHASE_DURATION_IN_SECS',
  'VIRTUAL_USERS_COUNT'
]);

const operationName = 'wallet-restoration';
const SHORTAGE_OF_WALLETS_FOUND_ERROR_MESSAGE = 'Addresses found from db are less than desired wallets count';

const mapToGroupedAddress = (addrModel: AddressesModel): GroupedAddress => ({
  accountIndex: 0,
  address: Cardano.Address(addrModel.address),
  index: 0,
  networkId: addrModel.address.startsWith('addr_test') ? Cardano.NetworkId.Testnet : Cardano.NetworkId.Mainnet,
  rewardAccount: Cardano.RewardAccount(addrModel.stake_address),
  type: AddressType.External
});

export const findAddresses: FunctionHook<WalletVars> = async ({ vars }, ee, done) => {
  vars.walletsCount = Number(env.VIRTUAL_USERS_COUNT);
  const db: Pool = new Pool({ connectionString: env.DB_SYNC_CONNECTION_STRING });

  try {
    logger.info('About to query db for distinct addresses');
    const result: QueryResult<AddressesModel> = await db.query(findAddressesWithRegisteredStakeKey, [
      vars.walletsCount
    ]);
    logger.info('Found addresses count', result.rowCount);

    vars.addresses = result.rows.map(mapToGroupedAddress);
  } catch (error) {
    ee.emit('counter', 'findAddresses.error', 1);
    logger.error('Error thrown while performing findAddresses db sync query', error);
  }

  if (vars.addresses.length < vars.walletsCount) {
    logger.error(SHORTAGE_OF_WALLETS_FOUND_ERROR_MESSAGE);
    throw new Error(SHORTAGE_OF_WALLETS_FOUND_ERROR_MESSAGE);
  }
  done();
};

export const walletRestoration: FunctionHook<WalletVars> = async ({ vars, _uid }, ee, done) => {
  let index = 0;
  return (async () => {
    const currentAddress = vars.addresses[index];

    try {
      const keyAgent = util.createAsyncKeyAgent(new StubKeyAgent(currentAddress));

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
      await walletReady(wallet);
      vars.currentWallet = wallet;

      // Emit custom metrics
      ee.emit('histogram', `${operationName}.time`, Date.now() - startedAt);
      ee.emit('counter', operationName, 1);

      logger.info(`Wallet with name ${wallet.name} is successfully restored`);
    } catch (error) {
      ee.emit('counter', `${operationName}.error`, 1);
      logger.error(error);
    }
    ++index;
    done();
  })();
};

export const shutdownWallet: FunctionHook<WalletVars> = async ({ vars }, _ee, done) => {
  vars.currentWallet.shutdown();
  done();
};
