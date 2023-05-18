import { Cardano } from '@cardano-sdk/core';
import { SingleAddressWallet } from '@cardano-sdk/wallet';
import { TestWallet, getEnv, getWallet, walletVariables } from '../../src';
import { firstValueFrom } from 'rxjs';
import {
  getTxConfirmationEpoch,
  requestCoins,
  runningAgainstLocalNetwork,
  submitAndConfirm,
  transferCoins,
  waitForEpoch
} from '../util';
import { logger } from '@cardano-sdk/util-dev';
import { waitForWalletStateSettle } from '../../../wallet/test/util';

const env = getEnv(walletVariables);

describe('delegation rewards', () => {
  let providers: TestWallet['providers'];
  let wallet1: SingleAddressWallet;
  let wallet2: SingleAddressWallet;

  const initializeWallets = async () => {
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
  };

  afterAll(() => {
    wallet1?.shutdown();
    wallet2?.shutdown();
  });

  it('will receive rewards for delegated tADA and can spend them', async () => {
    if (!(await runningAgainstLocalNetwork())) {
      return logger.fatal(
        "Skipping test 'will receive rewards for delegated tADA' as it should only run with a fast test network"
      );
    }

    // This has to be done inside the test (instead of beforeAll)
    // so that it doesn't fail when running against non-local networks
    await initializeWallets();

    // Arrange
    const activePools = await providers.stakePoolProvider.queryStakePools({
      filters: { pledgeMet: true, status: [Cardano.StakePoolStatus.Active] },
      pagination: { limit: 1, startAt: 0 }
    });
    expect(activePools.totalResultCount).toBeGreaterThan(0);
    const poolId = activePools.pageResults[0].id;
    expect(poolId).toBeDefined();
    logger.info(`Wallet funds will be staked to pool ${poolId}.`);

    const submitDelegationTx = async () => {
      logger.info(`Creating delegation tx at epoch #${(await firstValueFrom(wallet1.currentEpoch$)).epochNo}`);
      const { tx: signedTx } = await wallet1.createTxBuilder().delegate(poolId).build().sign();
      await wallet1.submitTx(signedTx);
      const { epochNo } = await firstValueFrom(wallet1.currentEpoch$);
      logger.info(`Delegation tx ${signedTx.id} submitted at epoch #${epochNo}`);

      return signedTx;
    };

    const generateTxs = async () => {
      logger.info('Sending 100 txs to generate reward fees');

      const tAdaToSend = 5_000_000n;
      const [{ address: receivingAddress }] = await firstValueFrom(wallet2.addresses$);

      for (let i = 0; i < 100; i++) {
        const txBuilder = wallet1.createTxBuilder();
        const txOut = await txBuilder.buildOutput().address(receivingAddress).coin(tAdaToSend).build();
        const { tx: signedTx } = await txBuilder.addOutput(txOut).build().sign();
        await wallet1.submitTx(signedTx);
      }
    };

    const buildSpendRewardTx = async () => {
      const tAdaToSend = 5_000_000n;
      const [{ address: receivingAddress }] = await firstValueFrom(wallet2.addresses$);
      const txBuilder = wallet1.createTxBuilder();
      const txOut = await txBuilder.buildOutput().address(receivingAddress).coin(tAdaToSend).build();
      const tx = await txBuilder.addOutput(txOut).build();
      const { body } = await tx.inspect();
      logger.debug('Body of tx before sign');
      logger.debug(body);
      const { tx: signedTx } = await tx.sign();
      logger.debug('Body of tx after sign');
      logger.debug(signedTx.body);

      return signedTx;
    };

    // Stake and wait for reward

    const signedTx = await submitDelegationTx();

    const delegationTxConfirmedAtEpoch = await getTxConfirmationEpoch(wallet1, signedTx);

    logger.info(`Delegation tx confirmed at epoch #${delegationTxConfirmedAtEpoch}`);

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
    expect(spendRewardTx.body.withdrawals?.length).toBeGreaterThan(0);
    await submitAndConfirm(wallet1, spendRewardTx);
  });
});
