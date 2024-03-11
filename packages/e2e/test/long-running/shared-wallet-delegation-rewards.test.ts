import { BaseWallet } from '@cardano-sdk/wallet';
import { Cardano, StakePoolProvider } from '@cardano-sdk/core';
import { buildSharedWallets } from '../wallet/SharedWallet/ultils';
import { filter, firstValueFrom, map, take } from 'rxjs';
import {
  getEnv,
  getTxConfirmationEpoch,
  getWallet,
  runningAgainstLocalNetwork,
  submitAndConfirm,
  waitForEpoch,
  walletReady,
  walletVariables
} from '../../src';
import { isNotNil } from '@cardano-sdk/util';
import { logger } from '@cardano-sdk/util-dev';
import { waitForWalletStateSettle } from '../../../wallet/test/util';

const env = getEnv(walletVariables);

const submitDelegationTx = async (alice: BaseWallet, bob: BaseWallet, charlotte: BaseWallet, pool: Cardano.PoolId) => {
  logger.info(`Creating delegation tx at epoch #${(await firstValueFrom(alice.currentEpoch$)).epochNo}`);
  let tx = (await alice.createTxBuilder().delegateFirstStakeCredential(pool).build().sign()).tx;

  tx = await bob.updateWitness({ sender: { id: 'e2e' }, tx });
  tx = await charlotte.updateWitness({ sender: { id: 'e2e' }, tx });
  await alice.submitTx(tx);

  const { epochNo } = await firstValueFrom(alice.currentEpoch$);
  logger.info(`Delegation tx ${tx.id} submitted at epoch #${epochNo}`);

  return tx;
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

const buildSpendRewardTx = async (
  alice: BaseWallet,
  bob: BaseWallet,
  charlotte: BaseWallet,
  receivingWallet: BaseWallet
) => {
  const tAdaToSend = 5_000_000n;
  const [{ address: receivingAddress }] = await firstValueFrom(receivingWallet.addresses$);
  const txBuilder = alice.createTxBuilder();
  const txOut = await txBuilder.buildOutput().address(receivingAddress).coin(tAdaToSend).build();
  const tx = txBuilder.addOutput(txOut).build();

  const { body } = await tx.inspect();
  logger.debug('Body of tx before sign');
  logger.debug(body);
  let signedTx = (await tx.sign()).tx;

  signedTx = await bob.updateWitness({ sender: { id: 'e2e' }, tx: signedTx });
  signedTx = await charlotte.updateWitness({ sender: { id: 'e2e' }, tx: signedTx });

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

describe('delegation rewards', () => {
  let fundingTx: Cardano.Tx<Cardano.TxBody>;
  let faucetWallet: BaseWallet;
  let faucetAddress: Cardano.PaymentAddress;
  let aliceMultiSigWallet: BaseWallet;
  let bobMultiSigWallet: BaseWallet;
  let charlotteMultiSigWallet: BaseWallet;
  let stakePoolProvider: StakePoolProvider;

  const initialFunds = 10_000_000n;

  beforeAll(async () => {
    jest.setTimeout(180_000);

    ({
      wallet: faucetWallet,
      providers: { stakePoolProvider }
    } = await getWallet({ env, logger, name: 'Sending Wallet', polling: { interval: 50 } }));

    // Make sure the wallet has sufficient funds to run this test
    await walletReady(faucetWallet, initialFunds);

    faucetAddress = (await firstValueFrom(faucetWallet.addresses$))[0].address;

    ({ aliceMultiSigWallet, bobMultiSigWallet, charlotteMultiSigWallet } = await buildSharedWallets(
      env,
      await firstValueFrom(faucetWallet.genesisParameters$),
      logger
    ));

    await Promise.all([
      waitForWalletStateSettle(aliceMultiSigWallet),
      waitForWalletStateSettle(bobMultiSigWallet),
      waitForWalletStateSettle(charlotteMultiSigWallet)
    ]);

    const [{ address: receivingAddress }] = await firstValueFrom(aliceMultiSigWallet.addresses$);

    logger.info(`Address ${faucetAddress} will send ${initialFunds} lovelace to address ${receivingAddress}.`);

    // Send 10 tADA to the shared wallet.
    const txBuilder = faucetWallet.createTxBuilder();
    const txOutput = await txBuilder.buildOutput().address(receivingAddress).coin(initialFunds).build();
    fundingTx = (await txBuilder.addOutput(txOutput).build().sign()).tx;
    await faucetWallet.submitTx(fundingTx);

    logger.info(
      `Submitted transaction id: ${fundingTx.id}, inputs: ${JSON.stringify(
        fundingTx.body.inputs.map((txIn) => [txIn.txId, txIn.index])
      )} and outputs:${JSON.stringify(
        fundingTx.body.outputs.map((txOut) => [txOut.address, Number.parseInt(txOut.value.coins.toString())])
      )}.`
    );
  });

  afterAll(() => {
    faucetWallet.shutdown();
    aliceMultiSigWallet.shutdown();
    bobMultiSigWallet.shutdown();
    charlotteMultiSigWallet.shutdown();
    faucetWallet.shutdown();
  });

  it('will receive rewards for delegated tADA and can spend them', async () => {
    if (!(await runningAgainstLocalNetwork())) {
      return logger.fatal(
        "Skipping test 'will receive rewards for delegated tADA' as it should only run with a fast test network"
      );
    }

    const txFoundInHistory = await firstValueFrom(
      aliceMultiSigWallet.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === fundingTx.id)),
        filter(isNotNil),
        take(1)
      )
    );

    expect(txFoundInHistory?.id).toEqual(fundingTx.id);

    // Arrange
    const [poolId] = await getPoolIds(stakePoolProvider, 1);

    // Stake and wait for reward
    const signedTx = await submitDelegationTx(aliceMultiSigWallet, bobMultiSigWallet, charlotteMultiSigWallet, poolId);

    const delegationTxConfirmedAtEpoch = await getTxConfirmationEpoch(aliceMultiSigWallet, signedTx);

    logger.info(`Delegation tx confirmed at epoch #${delegationTxConfirmedAtEpoch}`);

    await waitForEpoch(aliceMultiSigWallet, delegationTxConfirmedAtEpoch + 2);

    await generateTxs(faucetWallet, aliceMultiSigWallet);
    await waitForEpoch(aliceMultiSigWallet, delegationTxConfirmedAtEpoch + 4);

    // Check reward
    await waitForWalletStateSettle(aliceMultiSigWallet);
    const rewards = await firstValueFrom(aliceMultiSigWallet.balance.rewardAccounts.rewards$);
    expect(rewards).toBeGreaterThan(0n);

    logger.info(`Generated rewards: ${rewards} tLovelace`);

    // Spend reward
    const spendRewardTx = await buildSpendRewardTx(
      aliceMultiSigWallet,
      bobMultiSigWallet,
      charlotteMultiSigWallet,
      faucetWallet
    );
    expect(spendRewardTx.body.withdrawals?.length).toBeGreaterThan(0);
    await submitAndConfirm(aliceMultiSigWallet, spendRewardTx);
  });
});
