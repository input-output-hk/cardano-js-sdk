import * as envalid from 'envalid';
import { Cardano } from '@cardano-sdk/core';
import { FaucetProvider } from '../../src/FaucetProvider';
import { KeyManagement, SingleAddressWallet } from '@cardano-sdk/wallet';
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

  it('will do tADA transfer between two wallets.', async () => {
    // Arrange
    const amountFromFaucet = 100_000_000;
    const tAdaToSend = 50_000_000n;

    const wallet1: SingleAddressWallet = await getWallet(env);
    const wallet2: SingleAddressWallet = await getWallet(env);

    await firstValueFrom(wallet1.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)));
    await firstValueFrom(wallet2.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)));

    const sendingAddress: Cardano.Address = (
      await wallet1.keyAgent.deriveAddress({
        index: 0,
        type: KeyManagement.AddressType.External
      })
    ).address;

    const receivingAddress: Cardano.Address = (
      await wallet2.keyAgent.deriveAddress({
        index: 0,
        type: KeyManagement.AddressType.External
      })
    ).address;

    // Act

    logger.debug(`Address ${sendingAddress.toString()} will be funded with ${amountFromFaucet} tLovelace.`);

    // Request 100 tADA from faucet. This will block until the transaction is in the ledger,
    // and has the given amount of confirmation, which means the funds can be used immediately after
    // this call.
    await _faucetProvider.request(sendingAddress.toString(), amountFromFaucet, 3);

    logger.debug(
      `Address ${sendingAddress.toString()} will send ${tAdaToSend} tLovelace to address ${sendingAddress.toString()}.`
    );

    // Send 50 tADA to second address derivative.
    const unsignedTx = await wallet1.initializeTx({
      outputs: new Set([{ address: receivingAddress, value: { coins: tAdaToSend } }])
    });

    const signedTx = await wallet1.finalizeTx(unsignedTx);
    await wallet1.submitTx(signedTx);

    // Wait until transaction is in the chain history
    let txFoundInHistory;

    while (txFoundInHistory === undefined) {
      txFoundInHistory = await firstValueFrom(
        wallet2.transactions.history$
          .pipe(filter((txs) => txs.filter((tx) => tx.id === signedTx.id).length === 1))
          .pipe(map((txs) => (txs.length > 0 ? txs.find((tx) => tx.id === signedTx.id) : undefined)))
      );
    }

    // Assert

    expect(txFoundInHistory).toBeDefined();
    expect(txFoundInHistory.id).toEqual(signedTx.id);

    wallet1.shutdown();
    wallet2.shutdown();
  });
});
