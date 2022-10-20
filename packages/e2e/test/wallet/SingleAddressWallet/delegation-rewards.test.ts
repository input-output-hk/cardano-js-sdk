import * as envalid from 'envalid';
import { Cardano, createSlotEpochCalc } from '@cardano-sdk/core';
import { SignedTx, SingleAddressWallet, buildTx } from '@cardano-sdk/wallet';
import { TestWallet, getWallet } from '../../../src';
import { assertTxIsValid, waitForWalletStateSettle } from '../../../../wallet/test/util';
import { filter, firstValueFrom } from 'rxjs';
import { logger } from '@cardano-sdk/util-dev';
import { requestCoins, submitAndConfirm, transferCoins, waitForEpoch } from '../util';

// Verify environment.
export const env = envalid.cleanEnv(process.env, {
  ASSET_PROVIDER: envalid.str(),
  ASSET_PROVIDER_PARAMS: envalid.json({ default: {} }),
  CHAIN_HISTORY_PROVIDER: envalid.str(),
  CHAIN_HISTORY_PROVIDER_PARAMS: envalid.json({ default: {} }),
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
  let providers: TestWallet['providers'];
  let wallet1: SingleAddressWallet;
  let wallet2: SingleAddressWallet;

  beforeAll(async () => {
    const amountFromFaucet = 100_000_000_000n;
    const tAdaToSend = 50_000_000n;

    ({ wallet: wallet1, providers } = await getWallet({
      env,
      logger,
      name: 'Sending Wallet',
      polling: { interval: 50 }
    }));
    ({ wallet: wallet2 } = await getWallet({ env, logger, name: 'Receiving Wallet', polling: { interval: 50 } }));

    await requestCoins({ coins: amountFromFaucet, wallet: wallet1 });
    await transferCoins({ coins: tAdaToSend, fromWallet: wallet1, toWallet: wallet2 });

    await waitForWalletStateSettle(wallet1);
    await waitForWalletStateSettle(wallet2);
  });

  afterAll(() => {
    wallet1.shutdown();
    wallet2.shutdown();
  });

  it('will receive rewards for delegated tADA and can spend them', async () => {
    const { epochLength, slotLength } = await providers.networkInfoProvider.genesisParameters();

    const estimatedTestDurationInEpochs = 4;
    const localNetworkEpochDuration = 1000 * 0.2;
    const estimatedTestDuration = epochLength * slotLength * estimatedTestDurationInEpochs;
    if (estimatedTestDuration > localNetworkEpochDuration * estimatedTestDurationInEpochs) {
      return logger.fatal(
        "Skipping test 'will receive rewards for delegated tADA' as it should only run with a fast test network"
      );
    }

    // Arrange
    const activePools = await providers.stakePoolProvider.queryStakePools({
      filters: { status: [Cardano.StakePoolStatus.Active] },
      pagination: { limit: 1, startAt: 0 }
    });
    expect(activePools.totalResultCount).toBeGreaterThan(0);
    const poolId = activePools.pageResults[0].id;
    expect(poolId).toBeDefined();
    logger.info(`Wallet funds will be staked to pool ${poolId}.`);

    const submitDelegationTx = async () => {
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

    const buildSpendRewardTx = async () => {
      const tAdaToSend = 5_000_000n;
      const [{ address: receivingAddress }] = await firstValueFrom(wallet2.addresses$);
      const txBuilder = buildTx({ logger, observableWallet: wallet1 });
      const txOut = txBuilder.buildOutput().address(receivingAddress).coin(tAdaToSend).toTxOut();
      const tx = await txBuilder.addOutput(txOut).build();
      assertTxIsValid(tx);
      logger.debug('Body of tx before sign');
      logger.info(tx.body);
      const signedTx = await tx.sign();
      logger.debug('Body of tx after sign');
      logger.info(tx.body);

      return signedTx;
    };

    // Stake and wait for reward

    const signedTx = await submitDelegationTx();
    const delegationTxConfirmedAtEpoch = await getTxConfirmationEpoch(signedTx);
    await waitForEpoch(wallet1, delegationTxConfirmedAtEpoch + 2);
    await generateTxs();
    await waitForEpoch(wallet1, delegationTxConfirmedAtEpoch + 4);

    // Check reward
    await waitForWalletStateSettle(wallet1);
    const rewards = await firstValueFrom(wallet1.balance.rewardAccounts.rewards$);
    expect(rewards).toBeGreaterThan(0n);

    logger.info(`Generated rewards: ${rewards} tLovelace`);

    // Spend reward
    const spendRewardTx = await buildSpendRewardTx();
    expect(spendRewardTx.tx.body.withdrawals?.length).toBeGreaterThan(0);
    await submitAndConfirm(wallet1, spendRewardTx);
  });
});
