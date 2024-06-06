/* eslint-disable max-statements */
import { BigIntMath } from '@cardano-sdk/util';
import { Cardano } from '@cardano-sdk/core';
import {
  TX_TIMEOUT_DEFAULT,
  bip32Ed25519Factory,
  firstValueFromTimed,
  getEnv,
  getWallet,
  waitForWalletStateSettle,
  walletReady,
  walletVariables
} from '../../../src/index.js';
import { combineLatest, filter, firstValueFrom } from 'rxjs';
import { logger } from '@cardano-sdk/util-dev';
import type * as Crypto from '@cardano-sdk/crypto';
import type { BaseWallet, ObservableWallet } from '@cardano-sdk/wallet';
import type { TestWallet } from '../../../src/index.js';

const env = getEnv(walletVariables);

const getWalletStateSnapshot = async (wallet: ObservableWallet) => {
  const [rewardAccount] = await firstValueFrom(wallet.delegation.rewardAccounts$);
  const [publicStakeKey] = await firstValueFrom(wallet.publicStakeKeys$);
  const balanceAvailable = await firstValueFrom(wallet.balance.utxo.available$);
  const balanceTotal = await firstValueFrom(wallet.balance.utxo.total$);
  const deposit = await firstValueFrom(wallet.balance.rewardAccounts.deposit$);
  const epoch = await firstValueFrom(wallet.currentEpoch$);
  const utxoTotal = await firstValueFrom(wallet.utxo.total$);
  const utxoAvailable = await firstValueFrom(wallet.utxo.available$);
  const rewardsBalance = await firstValueFrom(wallet.balance.rewardAccounts.rewards$);

  return {
    balance: { available: balanceAvailable, deposit, total: balanceTotal },
    epoch: epoch.epochNo,
    isStakeKeyRegistered: rewardAccount.credentialStatus === Cardano.StakeCredentialStatus.Registered,
    publicStakeKey,
    rewardAccount,
    rewardsBalance,
    utxo: { available: utxoTotal, total: utxoAvailable }
  };
};

const waitForTx = async (wallet: ObservableWallet, hash: Cardano.TransactionId) => {
  await firstValueFromTimed(
    combineLatest([
      wallet.transactions.history$.pipe(filter((txs) => txs.some(({ id }) => id === hash))),
      // test that onChain$ works
      wallet.transactions.outgoing.onChain$.pipe(filter(({ id }) => id === hash))
    ]),
    'Tx not found on-chain for too long',
    TX_TIMEOUT_DEFAULT
  );
  await waitForWalletStateSettle(wallet);
};

describe('PersonalWallet/delegation', () => {
  let wallet1: TestWallet;
  let wallet2: TestWallet;
  let bip32Ed25519: Crypto.Bip32Ed25519;

  beforeAll(async () => {
    jest.setTimeout(180_000);
    wallet1 = await getWallet({ env, idx: 0, logger, name: 'Test Wallet 1', polling: { interval: 500 } });
    wallet2 = await getWallet({ env, idx: 1, logger, name: 'Test Wallet 2', polling: { interval: 500 } });

    await Promise.all([waitForWalletStateSettle(wallet1.wallet), waitForWalletStateSettle(wallet2.wallet)]);
    bip32Ed25519 = await bip32Ed25519Factory.create(env.KEY_MANAGEMENT_PARAMS.bip32Ed25519, null, logger);
  });

  afterAll(() => {
    wallet1.wallet.shutdown();
    wallet2.wallet.shutdown();
  });

  const chooseWallets = async (): Promise<[BaseWallet, BaseWallet]> => {
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

    const tx1OutputCoins = 1_000_000n;
    await walletReady(sourceWallet, tx1OutputCoins);

    const protocolParameters = await firstValueFrom(sourceWallet.protocolParameters$);
    const stakeKeyDeposit = BigInt(protocolParameters.stakeKeyDeposit);
    const initialState = await getWalletStateSnapshot(sourceWallet);
    expect(initialState.balance.total.coins).toBe(initialState.balance.available.coins);
    const poolId = await chooseDifferentPoolIdRandomly(initialState.rewardAccount.delegatee?.nextNextEpoch?.id);
    expect(poolId).toBeDefined();
    const initialDeposit = initialState.isStakeKeyRegistered ? stakeKeyDeposit : 0n;
    expect(initialState.balance.deposit).toBe(initialDeposit);

    // Make a 1st tx with key registration (if not already registered) and stake delegation
    // Also send some coin to another wallet
    const destAddresses = (await firstValueFrom(destWallet.addresses$))[0].address;
    const txBuilder = sourceWallet.createTxBuilder();

    const { tx } = await txBuilder
      .addOutput(await txBuilder.buildOutput().address(destAddresses).coin(tx1OutputCoins).build())
      .delegatePortfolio({ pools: [{ id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolId)), weight: 1 }] })
      .build()
      .sign();
    await sourceWallet.submitTx(tx);

    // Test it locks available balance after tx is submitted
    await firstValueFromTimed(
      sourceWallet.transactions.outgoing.inFlight$.pipe(filter((inFlight) => inFlight.length === 1)),
      'No tx in flight'
    );

    const tx1PendingState = await getWalletStateSnapshot(sourceWallet);

    // Updates total and available balance right after tx is submitted
    const coinsSpentOnDeposit = initialState.isStakeKeyRegistered ? 0n : stakeKeyDeposit;
    const newRewardsWhileSigningAndSubmitting = tx1PendingState.rewardsBalance;
    const expectedCoinsAfterTx1 =
      initialState.balance.total.coins -
      tx1OutputCoins -
      tx.body.fee -
      coinsSpentOnDeposit +
      BigIntMath.sum(tx.body.withdrawals?.map((wd) => wd.quantity) || []) +
      newRewardsWhileSigningAndSubmitting;
    expect(tx1PendingState.balance.total.coins).toEqual(expectedCoinsAfterTx1);
    expect(tx1PendingState.balance.available.coins).toEqual(expectedCoinsAfterTx1);
    expect(tx1PendingState.balance.deposit).toEqual(stakeKeyDeposit);

    await waitForTx(sourceWallet, tx.id);
    const tx1ConfirmedState = await getWalletStateSnapshot(sourceWallet);

    // Updates total and available balance after tx is on-chain
    expect(tx1ConfirmedState.balance.total.coins).toBe(expectedCoinsAfterTx1);
    expect(tx1ConfirmedState.balance.total).toEqual(tx1ConfirmedState.balance.available);
    expect(tx1PendingState.balance.deposit).toEqual(stakeKeyDeposit);

    // If less than two epochs have elapsed, delegatee will still delegate to former pool during current epoch
    // if more than two epochs has elapsed, delegatee will delegate to new pool.
    if (tx1ConfirmedState.epoch - initialState.epoch < 2) {
      expect(tx1ConfirmedState.rewardAccount.delegatee?.currentEpoch?.id).toEqual(
        initialState?.rewardAccount.delegatee?.currentEpoch?.id
      );
      expect(tx1ConfirmedState.rewardAccount.delegatee?.nextEpoch?.id).toEqual(
        initialState?.rewardAccount.delegatee?.nextEpoch?.id
      );
      expect(tx1ConfirmedState.rewardAccount.delegatee?.nextNextEpoch?.id).toEqual(poolId);
    } else {
      expect(tx1ConfirmedState.rewardAccount.delegatee?.currentEpoch?.id).toEqual(poolId);
    }

    const stakeKeyHash = await bip32Ed25519.getPubKeyHash(tx1ConfirmedState.publicStakeKey.publicStakeKey);
    expect(stakeKeyHash).toEqual(Cardano.RewardAccount.toHash(tx1ConfirmedState.rewardAccount.address));
    expect(tx1ConfirmedState.publicStakeKey.credentialStatus).toBe(Cardano.StakeCredentialStatus.Registered);

    // Make a 2nd tx with key de-registration
    const { tx: txDeregisterSigned } = await sourceWallet.createTxBuilder().delegatePortfolio(null).build().sign();
    await sourceWallet.submitTx(txDeregisterSigned);
    await waitForTx(sourceWallet, txDeregisterSigned.id);
    const tx2ConfirmedState = await getWalletStateSnapshot(sourceWallet);

    // No longer delegating
    expect(tx2ConfirmedState.rewardAccount.delegatee?.nextNextEpoch?.id).toBeUndefined();
    expect(tx2ConfirmedState.publicStakeKey.credentialStatus).toBe(Cardano.StakeCredentialStatus.Unregistered);

    // Deposit is returned to wallet balance
    const expectedCoinsAfterTx2 = expectedCoinsAfterTx1 + stakeKeyDeposit - txDeregisterSigned.body.fee;
    expect(tx2ConfirmedState.balance.total.coins).toBe(expectedCoinsAfterTx2);
    expect(tx2ConfirmedState.balance.total).toEqual(tx2ConfirmedState.balance.available);
    expect(tx2ConfirmedState.balance.deposit).toBe(0n);
  });
});
