import * as envalid from 'envalid';
import { FaucetProvider } from '../../src/FaucetProvider';
import { SingleAddressWallet } from '@cardano-sdk/wallet';
import { faucetProviderFactory, getLogger, getWallet } from '../../src/factories';
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

describe('Local Network', () => {
  let faucetProvider: FaucetProvider;

  beforeAll(async () => {
    faucetProvider = await faucetProviderFactory.create(
      env.FAUCET_PROVIDER,
      env.FAUCET_PROVIDER_PARAMS,
      getLogger(env.LOGGER_MIN_SEVERITY)
    );

    await faucetProvider.start();

    const healthCheck = await faucetProvider.healthCheck();

    if (!healthCheck.ok) throw new Error('Faucet provider could not be started.');
  });

  afterAll(async () => {
    await faucetProvider.close();
  });

  it('will do tADA transfer between two wallets.', async () => {
    // Arrange
    const amountFromFaucet = 100_000_000;
    const tAdaToSend = 50_000_000n;

    const wallet1: SingleAddressWallet = await getWallet({ env, name: 'Sending Wallet', polling: { interval: 50 } });
    const wallet2: SingleAddressWallet = await getWallet({ env, name: 'Receiving Wallet', polling: { interval: 50 } });

    await firstValueFrom(wallet1.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)));
    await firstValueFrom(wallet2.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)));

    const [{ address: sendingAddress }] = await firstValueFrom(wallet1.addresses$);
    const [{ address: receivingAddress }] = await firstValueFrom(wallet2.addresses$);

    // Act

    logger.debug(`Address ${sendingAddress.toString()} will be funded with ${amountFromFaucet} tLovelace.`);

    // Request 100 tADA from faucet. This will block until the transaction is in the ledger,
    // and has the given amount of confirmation, which means the funds can be used immediately after
    // this call.
    await faucetProvider.request(sendingAddress.toString(), amountFromFaucet, 1);

    // Wait until wallet one is aware of the funds.
    await firstValueFrom(wallet1.balance.utxo.total$.pipe(filter(({ coins }) => coins >= amountFromFaucet)));

    logger.debug(
      `Address ${sendingAddress.toString()} will send ${tAdaToSend} lovelace to address ${receivingAddress.toString()}.`
    );

    // Send 50 tADA to second wallet.
    const unsignedTx = await wallet1.initializeTx({
      outputs: new Set([{ address: receivingAddress, value: { coins: tAdaToSend } }])
    });

    const signedTx = await wallet1.finalizeTx(unsignedTx);
    await wallet1.submitTx(signedTx);

    // Wait until wallet two is aware of the funds.
    await firstValueFrom(wallet2.balance.utxo.total$.pipe(filter(({ coins }) => coins >= tAdaToSend)));

    // Search chain history to see if the transaction is there.
    const txFoundInHistory = await firstValueFrom(
      wallet2.transactions.history$
        .pipe(filter((txs) => txs.filter((tx) => tx.id === signedTx.id).length === 1))
        .pipe(map((txs) => (txs.length > 0 ? txs.find((tx) => tx.id === signedTx.id) : undefined)))
    );

    // Assert

    expect(txFoundInHistory).toBeDefined();
    expect(txFoundInHistory?.id).toEqual(signedTx.id);

    wallet1.shutdown();
    wallet2.shutdown();
  });
});
