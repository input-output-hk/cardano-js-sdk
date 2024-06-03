import { BaseWallet } from '@cardano-sdk/wallet';
import { Cardano, StakePoolProvider } from '@cardano-sdk/core';
import {
  TestWallet,
  getEnv,
  getTxConfirmationEpoch,
  getWallet,
  runningAgainstLocalNetwork,
  submitAndConfirm,
  waitForEpoch,
  walletVariables
} from '../../src';
import { firstValueFrom } from 'rxjs';
import { logger } from '@cardano-sdk/util-dev';
import { waitForWalletStateSettle } from '../../../wallet/test/util';

const env = getEnv(walletVariables);

const submitDelegationTx = async (wallet: BaseWallet, pools: Cardano.PoolId[]) => {
  logger.info(`Creating delegation tx at epoch #${(await firstValueFrom(wallet.currentEpoch$)).epochNo}`);
  const { tx: signedTx } = await wallet
    .createTxBuilder()
    .delegatePortfolio({
      name: 'Test Portfolio',
      pools: pools.map((poolId) => ({ id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolId)), weight: 1 }))
    })
    .build()
    .sign();
  await wallet.submitTx(signedTx);
  const { epochNo } = await firstValueFrom(wallet.currentEpoch$);
  logger.info(`Delegation tx ${signedTx.id} submitted at epoch #${epochNo}`);

  return signedTx;
};

const generateTxs = async (sendingWallet: BaseWallet, receivingWallet: BaseWallet) => {
  logger.info('Sending 100 txs to generate reward fees');

  const tAdaToSend = 5_000_000n;
  const [{ address: receivingAddress }] = await firstValueFrom(receivingWallet.addresses$);

  for (let i = 0; i < 100; i++) {
    const txBuilder = sendingWallet.createTxBuilder();
    const txOut = await txBuilder.buildOutput().address(receivingAddress).coin(tAdaToSend).build();
    const { tx: signedTx } = await txBuilder.addOutput(txOut).build().sign();
    await sendingWallet.submitTx(signedTx);
  }
};

const buildSpendRewardTx = async (sendingWallet: BaseWallet, receivingWallet: BaseWallet) => {
  const tAdaToSend = 5_000_000n;
  const [{ address: receivingAddress }] = await firstValueFrom(receivingWallet.addresses$);
  const txBuilder = sendingWallet.createTxBuilder();
  const txOut = await txBuilder.buildOutput().address(receivingAddress).coin(tAdaToSend).build();
  const tx = txBuilder.addOutput(txOut).build();
  const { body } = await tx.inspect();
  logger.debug('Body of tx before sign');
  logger.debug(body);
  const { tx: signedTx } = await tx.sign();
  logger.debug('Body of tx after sign');
  logger.debug(signedTx.body);

  return signedTx;
};

const getPoolIds = async (stakePoolProvider: StakePoolProvider, count: number) => {
  const activePools = await stakePoolProvider.queryStakePools({
    filters: { pledgeMet: true, status: [Cardano.StakePoolStatus.Active] },
    pagination: { limit: count, startAt: 0 }
  });
  expect(activePools.totalResultCount).toBeGreaterThanOrEqual(count);
  const poolIds = activePools.pageResults.map(({ id }) => id);
  expect(poolIds.every((poolId) => poolId !== undefined)).toBeTruthy();
  logger.info('Wallet funds will be staked to pools:', poolIds);
  return poolIds;
};

describe('simple delegation rewards', () => {
  let providers: TestWallet['providers'];
  let wallet1: BaseWallet;
  let wallet2: BaseWallet;

  const initializeWallets = async () => {
    ({ wallet: wallet1, providers } = await getWallet({
      env,
      logger,
      name: 'Sending Wallet',
      polling: { interval: 50 }
    }));
    ({ wallet: wallet2 } = await getWallet({ env, logger, name: 'Receiving Wallet' }));

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
    const [poolId] = await getPoolIds(providers.stakePoolProvider, 1);

    // Stake and wait for reward

    const signedTx = await submitDelegationTx(wallet1, [poolId]);

    const delegationTxConfirmedAtEpoch = await getTxConfirmationEpoch(wallet1, signedTx);

    logger.info(`Delegation tx confirmed at epoch #${delegationTxConfirmedAtEpoch}`);

    await waitForEpoch(wallet1, delegationTxConfirmedAtEpoch + 2);

    await generateTxs(wallet1, wallet2);
    await waitForEpoch(wallet1, delegationTxConfirmedAtEpoch + 4);

    // Check reward
    await waitForWalletStateSettle(wallet1);
    const rewards = await firstValueFrom(wallet1.balance.rewardAccounts.rewards$);
    expect(rewards).toBeGreaterThan(0n);

    logger.info(`Generated rewards: ${rewards} tLovelace`);

    // Spend reward
    const spendRewardTx = await buildSpendRewardTx(wallet1, wallet2);
    expect(spendRewardTx.body.withdrawals?.length).toBeGreaterThan(0);
    await submitAndConfirm(wallet1, spendRewardTx);
  });

  it('can spend rewards from multiple accounts', async () => {
    if (!(await runningAgainstLocalNetwork())) {
      return logger.fatal(
        "Skipping test 'will receive rewards for delegated tADA' as it should only run with a fast test network"
      );
    }

    // This has to be done inside the test (instead of beforeAll)
    // so that it doesn't fail when running against non-local networks
    await initializeWallets();

    const [poolId1, poolId2] = await getPoolIds(providers.stakePoolProvider, 2);
    const signedTx = await submitDelegationTx(wallet1, [poolId1, poolId2]);

    const delegationTxConfirmedAtEpoch = await getTxConfirmationEpoch(wallet1, signedTx);

    logger.info(`Delegation tx confirmed at epoch #${delegationTxConfirmedAtEpoch}`);

    await waitForEpoch(wallet1, delegationTxConfirmedAtEpoch + 2);

    await generateTxs(wallet1, wallet2);
    await waitForEpoch(wallet1, delegationTxConfirmedAtEpoch + 4);

    // Check reward
    await waitForWalletStateSettle(wallet1);
    const rewardsPerAcct = await firstValueFrom(wallet1.delegation.rewardAccounts$);
    const rewards = await firstValueFrom(wallet1.balance.rewardAccounts.rewards$);

    logger.info(`Generated rewards: ${rewards} tLovelace`);
    logger.info('Generated rewards per account:', rewardsPerAcct);

    expect(rewards).toBeGreaterThan(0n);

    // Spend reward
    const spendRewardTx = await buildSpendRewardTx(wallet1, wallet2);
    logger.info('transaction Withdrawals', spendRewardTx.body.withdrawals);

    expect(spendRewardTx.body.withdrawals?.length).toBeGreaterThanOrEqual(2);
    await submitAndConfirm(wallet1, spendRewardTx);
  });
});
