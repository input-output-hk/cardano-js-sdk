import * as envalid from 'envalid';
import { Cardano, createSlotEpochCalc } from '@cardano-sdk/core';
import { FaucetProvider, TestWallet, faucetProviderFactory, getWallet } from '../../../src';
import { SignedTx, SingleAddressWallet, buildTx } from '@cardano-sdk/wallet';
import { assertTxIsValid, waitForWalletStateSettle } from '../../../../wallet/test/util';
import { filter, firstValueFrom, map, take } from 'rxjs';
import { isNotNil } from '@cardano-sdk/util';
import { logger } from '@cardano-sdk/util-dev';

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

describe('delegation rewards', () => {
  let faucetProvider: FaucetProvider;
  let providers: TestWallet['providers'];
  let wallet1: SingleAddressWallet;
  let wallet2: SingleAddressWallet;

  beforeAll(async () => {
    faucetProvider = await faucetProviderFactory.create(env.FAUCET_PROVIDER, env.FAUCET_PROVIDER_PARAMS, logger);

    await faucetProvider.start();

    const healthCheck = await faucetProvider.healthCheck();

    if (!healthCheck.ok) throw new Error('Faucet provider could not be started.');
  });

  afterAll(async () => {
    await faucetProvider.close();
  });

  beforeEach(async () => {
    ({ wallet: wallet1, providers } = await getWallet({
      env,
      logger,
      name: 'Sending Wallet',
      polling: { interval: 50 }
    }));
    ({ wallet: wallet2 } = await getWallet({ env, logger, name: 'Receiving Wallet', polling: { interval: 50 } }));

    await waitForWalletStateSettle(wallet1);
    await waitForWalletStateSettle(wallet2);
  });

  afterEach(() => {
    wallet1.shutdown();
    wallet2.shutdown();
  });

  it('will do tADA transfer between two wallets.', async () => {
    // Arrange
    const amountFromFaucet = 100_000_000;
    const tAdaToSend = 50_000_000n;

    const [{ address: sendingAddress }] = await firstValueFrom(wallet1.addresses$);
    const [{ address: receivingAddress }] = await firstValueFrom(wallet2.addresses$);

    // Act

    logger.info(`Address ${sendingAddress.toString()} will be funded with ${amountFromFaucet} tLovelace.`);

    // Request 100 tADA from faucet. This will block until the transaction is in the ledger,
    // and has the given amount of confirmation, which means the funds can be used immediately after
    // this call.
    await faucetProvider.request(sendingAddress.toString(), amountFromFaucet, 1);

    // Wait until wallet one is aware of the funds.
    await firstValueFrom(wallet1.balance.utxo.total$.pipe(filter(({ coins }) => coins >= amountFromFaucet)));

    logger.info(
      `Address ${sendingAddress.toString()} will send ${tAdaToSend} lovelace to address ${receivingAddress.toString()}.`
    );

    // Send 50 tADA to second wallet.
    const txBuilder = buildTx({ logger, observableWallet: wallet1 });
    const txOut = txBuilder.buildOutput().address(receivingAddress).coin(tAdaToSend).toTxOut();
    const unsignedTx = await txBuilder.addOutput(txOut).build();
    assertTxIsValid(unsignedTx);
    const signedTx = await unsignedTx.sign();
    await signedTx.submit();

    // Wait until wallet two is aware of the funds.
    await firstValueFrom(wallet2.balance.utxo.total$.pipe(filter(({ coins }) => coins >= tAdaToSend)));

    // Search chain history to see if the transaction is there.
    const txFoundInHistory = await firstValueFrom(
      wallet2.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === signedTx.tx.id)),
        filter(isNotNil),
        take(1)
      )
    );

    // Assert

    expect(txFoundInHistory).toBeDefined();
    expect(txFoundInHistory.id).toEqual(signedTx.tx.id);
  });

  it('will receive rewards for delegated tADA and can spend them', async () => {
    const { epochLength, slotLength } = await providers.networkInfoProvider.genesisParameters();

    // If the estimated test duration (4 times the duration of an epoch) is greater than 5 minutes
    if (epochLength * slotLength * 4 > 300) {
      logger.fatal("Skipping test 'will receive rewards for delegated tADA' as it will take more than 5 minutes");

      return;
    }

    // Arrange
    const amountFromFaucet = 100_000_000_000;

    const [{ address: sendingAddress }] = await firstValueFrom(wallet1.addresses$);

    await faucetProvider.request(sendingAddress.toString(), amountFromFaucet, 1);
    await firstValueFrom(wallet1.balance.utxo.total$.pipe(filter(({ coins }) => coins >= amountFromFaucet)));

    const activePools = await providers.stakePoolProvider.queryStakePools({
      filters: { status: [Cardano.StakePoolStatus.Active] },
      pagination: { limit: 2, startAt: 0 }
    });
    expect(activePools.totalResultCount).toBeGreaterThan(0);
    const poolId = activePools.pageResults[0].id;
    expect(poolId).toBeDefined();
    logger.info(`Wallet funds will be staked to pool ${poolId}.`);

    const createDelegationTx = async () => {
      logger.info(`Creating delegation tx at epoch #${(await firstValueFrom(wallet1.currentEpoch$)).epochNo}`);
      const tx = await buildTx({ logger, observableWallet: wallet1 }).delegate(poolId).build();
      assertTxIsValid(tx);
      const signedTx = await tx.sign();
      await signedTx.submit();
      const { epochNo } = await firstValueFrom(wallet1.currentEpoch$);
      logger.info(`Delegation tx ${signedTx.tx.id} submitted at epoch #${epochNo}`);

      return signedTx;
    };

    const getTxConfirmationEpoch = async (tx: SignedTx) => {
      const txs = await firstValueFrom(
        wallet1.transactions.history$.pipe(filter((_) => _.some(({ id }) => id === tx.tx.id)))
      );
      const delegationTx = txs.find(({ id }) => id === tx.tx.id);
      const slotEpochCalc = createSlotEpochCalc(await firstValueFrom(wallet1.eraSummaries$));
      const delegationTxConfirmedAtEpoch = slotEpochCalc(delegationTx!.blockHeader.slot);
      logger.info(`Delegation tx confirmed at epoch #${delegationTxConfirmedAtEpoch}`);

      return delegationTxConfirmedAtEpoch;
    };

    const waitForEpoch = (epochNo: number) => {
      logger.info(`Waiting for epoch #${epochNo}`);

      return firstValueFrom(wallet1.currentEpoch$.pipe(filter((_) => _.epochNo >= epochNo)));
    };

    const generateTxs = async () => {
      logger.info('Sending 100 txs to generate reward fees');

      const tAdaToSend = 5_000_000n;
      const [{ address: receivingAddress }] = await firstValueFrom(wallet2.addresses$);

      for (let i = 0; i < 100; i++) {
        const txBuilder = buildTx({ logger, observableWallet: wallet1 });
        const txOut = txBuilder.buildOutput().address(receivingAddress).coin(tAdaToSend).toTxOut();
        const tx = await txBuilder.addOutput(txOut).build();
        assertTxIsValid(tx);
        await (await tx.sign()).submit();
      }
    };

    const spendReward = async () => {
      const tAdaToSend = 5_000_000n;
      const [{ address: receivingAddress }] = await firstValueFrom(wallet2.addresses$);
      const txBuilder = buildTx({ logger, observableWallet: wallet1 });
      const txOut = txBuilder.buildOutput().address(receivingAddress).coin(tAdaToSend).toTxOut();
      const tx = await txBuilder.addOutput(txOut).build();
      assertTxIsValid(tx);
      logger.info('Body of tx before sign');
      logger.info(tx.body);
      const signedTx = await tx.sign();
      logger.info('Body of tx after sign');
      logger.info(tx.body);
      await signedTx.submit();
      await firstValueFrom(
        wallet1.transactions.history$.pipe(filter((_) => _.some(({ id }) => id === signedTx.tx.id)))
      );

      return signedTx;
    };

    // Stake and wait for reward

    const signedTx = await createDelegationTx();
    const delegationTxConfirmedAtEpoch = await getTxConfirmationEpoch(signedTx);
    await waitForEpoch(delegationTxConfirmedAtEpoch + 2);
    await generateTxs();
    await waitForEpoch(delegationTxConfirmedAtEpoch + 4);

    // Check reward

    const reward = await firstValueFrom(wallet1.balance.rewardAccounts.rewards$.pipe(filter((r) => r > 0)));
    logger.info(`Generated rewards: ${reward} tLovelace`);
    expect(reward).toBeGreaterThan(0);

    // Spend reward
    const tx = await spendReward();
    logger.info(`TODO: Perform assertions on tx: ${tx.tx.id}`);
  });
});
