/* eslint-disable max-statements */
import { Awaited } from '@cardano-sdk/util';
import { Cardano } from '@cardano-sdk/core';
import { ObservableWallet, StakeKeyStatus, buildTx } from '@cardano-sdk/wallet';
import { TX_TIMEOUT, firstValueFromTimed, waitForWalletStateSettle } from '../util';
import { assertTxIsValid, assertTxOutIsValid } from '../../../../wallet/test/util';
import { env } from '../environment';
import { getWallet } from '../../../src/factories';
import { logger } from '@cardano-sdk/util-dev';

import { combineLatest, filter, firstValueFrom } from 'rxjs';

const getWalletStateSnapshot = async (wallet: ObservableWallet) => {
  const [rewardAccount] = await firstValueFrom(wallet.delegation.rewardAccounts$);
  const balanceAvailable = await firstValueFrom(wallet.balance.utxo.available$);
  const balanceTotal = await firstValueFrom(wallet.balance.utxo.total$);
  const deposit = await firstValueFrom(wallet.balance.rewardAccounts.deposit$);
  const epoch = await firstValueFrom(wallet.currentEpoch$);
  const utxoTotal = await firstValueFrom(wallet.utxo.total$);
  const utxoAvailable = await firstValueFrom(wallet.utxo.available$);
  return {
    balance: { available: balanceAvailable, deposit, total: balanceTotal },
    epoch: epoch.epochNo,
    isStakeKeyRegistered: rewardAccount.keyStatus === StakeKeyStatus.Registered,
    rewardAccount,
    utxo: { available: utxoTotal, total: utxoAvailable }
  };
};

const waitForTx = async (wallet: ObservableWallet, hash: Cardano.TransactionId) => {
  await firstValueFromTimed(
    combineLatest([
      wallet.transactions.history$.pipe(filter((txs) => txs.some(({ id }) => id === hash))),
      // test that confirmed$ works
      wallet.transactions.outgoing.confirmed$.pipe(filter(({ id }) => id === hash))
    ]),
    'Tx not confirmed for too long',
    TX_TIMEOUT
  );
  await waitForWalletStateSettle(wallet);
};

describe('SingleAddressWallet/delegation', () => {
  let wallet1: Awaited<ReturnType<typeof getWallet>>;
  let wallet2: Awaited<ReturnType<typeof getWallet>>;

  beforeAll(async () => {
    jest.setTimeout(180_000);
    wallet1 = await getWallet({ env, idx: 0, logger, name: 'Test Wallet 1' });
    wallet2 = await getWallet({ env, idx: 1, logger, name: 'Test Wallet 2' });

    await Promise.all([waitForWalletStateSettle(wallet1.wallet), waitForWalletStateSettle(wallet2.wallet)]);
  });

  afterAll(() => {
    wallet1.wallet.shutdown();
    wallet2.wallet.shutdown();
  });

  const chooseWallets = async (): Promise<[ObservableWallet, ObservableWallet]> => {
    const wallet1Balance = await firstValueFrom(wallet1.wallet.balance.utxo.available$);
    const wallet2Balance = await firstValueFrom(wallet2.wallet.balance.utxo.available$);
    return wallet1Balance.coins > wallet2Balance.coins
      ? [wallet1.wallet, wallet2.wallet]
      : [wallet2.wallet, wallet1.wallet];
  };

  const chooseDifferentPoolIdRandomly = async (delegateeBefore1stTx?: Cardano.PoolId): Promise<Cardano.PoolId> => {
    const activePools = await wallet1.providers.stakePoolProvider.queryStakePools({
      filters: { status: [Cardano.StakePoolStatus.Active] },
      pagination: { limit: 2, startAt: 0 }
    });
    const filteredPools = activePools.pageResults.filter(({ id }) => id !== delegateeBefore1stTx);
    return filteredPools[Math.round(Math.random() * (filteredPools.length - 1))]?.id;
  };

  test('delegation preconditions', async () => {
    const addresses = await firstValueFrom(wallet1.wallet.addresses$);
    const currentEpoch = await firstValueFrom(wallet1.wallet.currentEpoch$);
    expect(addresses[0].rewardAccount).toBeTruthy();
    expect(currentEpoch.epochNo).toBeGreaterThan(0);
  });

  test('balance & transaction', async () => {
    // source wallet has the highest balance to begin with
    const [sourceWallet, destWallet] = await chooseWallets();
    const [{ rewardAccount }] = await firstValueFrom(sourceWallet.addresses$);

    const protocolParameters = await firstValueFrom(sourceWallet.protocolParameters$);
    const stakeKeyDeposit = BigInt(protocolParameters.stakeKeyDeposit);
    const initialState = await getWalletStateSnapshot(sourceWallet);
    expect(initialState.balance.total.coins).toBeGreaterThan(0n);
    expect(initialState.balance.total.coins).toBe(initialState.balance.available.coins);
    const tx1OutputCoins = 1_000_000n;
    const poolId = await chooseDifferentPoolIdRandomly(initialState.rewardAccount.delegatee?.nextNextEpoch?.id);
    expect(poolId).toBeDefined();
    const initialDeposit = initialState.isStakeKeyRegistered ? stakeKeyDeposit : 0n;
    expect(initialState.balance.deposit).toBe(initialDeposit);

    // Make a 1st tx with key registration (if not already registered) and stake delegation
    // Also send some coin to another wallet
    const destAddresses = (await firstValueFrom(destWallet.addresses$))[0].address;
    const txBuilder = await buildTx(sourceWallet).delegate(poolId);
    const maybeValidTxOut = await txBuilder.buildOutput().address(destAddresses).coin(tx1OutputCoins).build();
    assertTxOutIsValid(maybeValidTxOut);

    const tx = await txBuilder.addOutput(maybeValidTxOut.txOut).build();
    assertTxIsValid(tx);

    const signedTx = await tx.sign();
    await signedTx.submit();

    // Test it locks available balance after tx is submitted
    await firstValueFromTimed(
      sourceWallet.transactions.outgoing.inFlight$.pipe(filter((inFlight) => inFlight.length === 1)),
      'No tx in flight'
    );

    const tx1PendingState = await getWalletStateSnapshot(sourceWallet);

    // Updates total and available balance right after tx is submitted
    const coinsSpentOnDeposit = initialState.isStakeKeyRegistered ? 0n : stakeKeyDeposit;
    const expectedCoinsAfterTx1 = initialState.balance.total.coins - tx1OutputCoins - tx.body.fee - coinsSpentOnDeposit;
    expect(tx1PendingState.balance.total.coins).toEqual(expectedCoinsAfterTx1);
    expect(tx1PendingState.balance.available.coins).toEqual(expectedCoinsAfterTx1);
    expect(tx1PendingState.balance.deposit).toEqual(stakeKeyDeposit);

    await waitForTx(sourceWallet, signedTx.tx.id);
    const tx1ConfirmedState = await getWalletStateSnapshot(sourceWallet);

    // Updates total and available balance after tx is confirmed
    expect(tx1ConfirmedState.balance.total.coins).toBe(expectedCoinsAfterTx1);
    expect(tx1ConfirmedState.balance.total).toEqual(tx1ConfirmedState.balance.available);
    expect(tx1PendingState.balance.deposit).toEqual(stakeKeyDeposit);

    expect(tx1ConfirmedState.rewardAccount.delegatee?.nextNextEpoch!.id).toEqual(poolId);
    // nothing changes for 2 epochs
    expect(tx1ConfirmedState.rewardAccount.delegatee?.nextEpoch).toEqual(
      initialState.rewardAccount?.delegatee?.nextEpoch
    );
    expect(tx1ConfirmedState.rewardAccount.delegatee?.currentEpoch).toEqual(
      initialState.rewardAccount?.delegatee?.currentEpoch
    );

    // Make a 2nd tx with key deregistration
    const tx2Internals = await sourceWallet.initializeTx({
      certificates: [
        {
          __typename: Cardano.CertificateType.StakeKeyDeregistration,
          stakeKeyHash: Cardano.Ed25519KeyHash.fromRewardAccount(rewardAccount)
        }
      ]
    });
    await sourceWallet.submitTx(await sourceWallet.finalizeTx({ tx: tx2Internals }));
    await waitForTx(sourceWallet, tx2Internals.hash);
    const tx2ConfirmedState = await getWalletStateSnapshot(sourceWallet);

    // No longer delegating
    expect(tx2ConfirmedState.rewardAccount.delegatee?.nextNextEpoch?.id).toBeUndefined();

    // Deposit is returned to wallet balance
    const expectedCoinsAfterTx2 = expectedCoinsAfterTx1 + stakeKeyDeposit - tx2Internals.body.fee;
    expect(tx2ConfirmedState.balance.total.coins).toBe(expectedCoinsAfterTx2);
    expect(tx2ConfirmedState.balance.total).toEqual(tx2ConfirmedState.balance.available);
    expect(tx2ConfirmedState.balance.deposit).toBe(0n);
  });
});
