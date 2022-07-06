import * as envalid from 'envalid';
import { Cardano } from '@cardano-sdk/core';
import { FaucetProvider } from '../../src/FaucetProvider';
import { KeyManagement, SingleAddressWallet } from '@cardano-sdk/wallet';
import {
  assetProviderFactory,
  chainHistoryProviderFactory,
  faucetProviderFactory,
  getKeyAgent,
  getLogger,
  networkInfoProviderFactory,
  rewardsProviderFactory,
  stakePoolProviderFactory,
  txSubmitProviderFactory,
  utxoProviderFactory
} from '../../src/factories';
import { filter, firstValueFrom, map } from 'rxjs';

// Verify environment.
export const env = envalid.cleanEnv(process.env, {
  ASSET_PROVIDER: envalid.str(),
  ASSET_PROVIDER_PARAMS: envalid.json({ default: {} }),
  CHAIN_HISTORY_PROVIDER: envalid.str(),
  CHAIN_HISTORY_PROVIDER_PARAMS: envalid.json({ default: {} }),
  FAUCET_PROVIDER: envalid.str(),
  FAUCET_PROVIDER_PARAMS: envalid.json({ default: {} }),
  KEY_MANAGEMENT_PARAMS: envalid.json({ default: {} }),
  KEY_MANAGEMENT_PROVIDER: envalid.str(),
  LOGGER_MIN_SEVERITY: envalid.str({ default: 'info' }),
  NETWORK_INFO_PROVIDER: envalid.str(),
  NETWORK_INFO_PROVIDER_PARAMS: envalid.json({ default: {} }),
  REWARDS_PROVIDER: envalid.str(),
  REWARDS_PROVIDER_PARAMS: envalid.json({ default: {} }),
  STAKE_POOL_PROVIDER: envalid.str(),
  STAKE_POOL_PROVIDER_PARAMS: envalid.json({ default: {} }),
  TX_SUBMIT_PROVIDER: envalid.str(),
  TX_SUBMIT_PROVIDER_PARAMS: envalid.json({ default: {} }),
  UTXO_PROVIDER: envalid.str(),
  UTXO_PROVIDER_PARAMS: envalid.json({ default: {} })
});

const logger = getLogger(env.LOGGER_MIN_SEVERITY);

const getWallet = async () =>
  new SingleAddressWallet(
    { name: 'Test Wallet' },
    {
      assetProvider: await assetProviderFactory.create(env.ASSET_PROVIDER, env.ASSET_PROVIDER_PARAMS),
      chainHistoryProvider: await chainHistoryProviderFactory.create(
        env.CHAIN_HISTORY_PROVIDER,
        env.CHAIN_HISTORY_PROVIDER_PARAMS
      ),
      keyAgent: await getKeyAgent(env.KEY_MANAGEMENT_PROVIDER, env.KEY_MANAGEMENT_PARAMS),
      networkInfoProvider: await networkInfoProviderFactory.create(
        env.NETWORK_INFO_PROVIDER,
        env.NETWORK_INFO_PROVIDER_PARAMS
      ),
      rewardsProvider: await rewardsProviderFactory.create(env.REWARDS_PROVIDER, env.REWARDS_PROVIDER_PARAMS),
      stakePoolProvider: await stakePoolProviderFactory.create(env.STAKE_POOL_PROVIDER, env.STAKE_POOL_PROVIDER_PARAMS),
      txSubmitProvider: await txSubmitProviderFactory.create(env.TX_SUBMIT_PROVIDER, env.TX_SUBMIT_PROVIDER_PARAMS),
      utxoProvider: await utxoProviderFactory.create(env.UTXO_PROVIDER, env.UTXO_PROVIDER_PARAMS)
    }
  );

describe('CardanoWalletFaucetProvider', () => {
  let _faucetProvider: FaucetProvider;

  beforeAll(async () => {
    _faucetProvider = await faucetProviderFactory.create(env.FAUCET_PROVIDER, env.FAUCET_PROVIDER_PARAMS);

    await _faucetProvider.start();

    const healthCheck = await _faucetProvider.healthCheck();

    if (!healthCheck.ok) throw new Error('Faucet provider could not be started.');
  });

  afterAll(async () => {
    await _faucetProvider.close();
  });

  it('will do an intra wallet tADA transfer.', async (done) => {
    logger.debug('waiting');
    const wallet: SingleAddressWallet = await getWallet();
    logger.debug('wait over');
    await firstValueFrom(wallet.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)));

    const sendingAddress: Cardano.Address = (
      await wallet.keyAgent.deriveAddress({
        index: 0,
        type: KeyManagement.AddressType.External
      })
    ).address;

    const receivingAddress: Cardano.Address = (
      await wallet.keyAgent.deriveAddress({
        index: 1,
        type: KeyManagement.AddressType.External
      })
    ).address;

    // Request 100 tADA from faucet. This will block until the transaction is in the ledger, which means
    // the funds can be used immediately after.
    await _faucetProvider.request(sendingAddress.toString(), 100_000_000);

    // Send 50 tADA to second address derivative.
    const unsignedTx = await wallet.initializeTx({
      outputs: new Set([{ address: receivingAddress, value: { coins: 50_000_000n } }])
    });

    const signedTx = await wallet.finalizeTx(unsignedTx);
    await wallet.submitTx(signedTx);

    wallet.transactions.history$
      .pipe(filter((txs) => txs.filter((tx) => tx.id === signedTx.id).length === 1))
      .pipe(map((txs) => txs[0]))
      .subscribe((transaction) => {
        logger.debug(transaction);
        done();
      });
  });
});
