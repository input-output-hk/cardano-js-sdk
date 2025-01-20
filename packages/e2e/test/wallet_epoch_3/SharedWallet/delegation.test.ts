/* eslint-disable max-statements */
import { BaseWallet, ObservableWallet } from '@cardano-sdk/wallet';
import { BigIntMath, isNotNil, toSerializableObject } from '@cardano-sdk/util';
import { Cardano, Serialization, StakePoolProvider } from '@cardano-sdk/core';
import {
  TX_TIMEOUT_DEFAULT,
  firstValueFromTimed,
  getEnv,
  getWallet,
  normalizeTxBody,
  waitForWalletStateSettle,
  walletReady,
  walletVariables
} from '../../../src';
import { buildSharedWallets } from '../../wallet_epoch_0/SharedWallet/utils';
import { combineLatest, filter, firstValueFrom, map, take } from 'rxjs';
import { logger } from '@cardano-sdk/util-dev';

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
    isStakeCredentialRegistered: [
      Cardano.StakeCredentialStatus.Registered,
      Cardano.StakeCredentialStatus.Registering
    ].includes(rewardAccount.credentialStatus),
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

describe('SharedWallet/delegation', () => {
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
    } = await getWallet({ env, logger, name: 'Sending Wallet' }));

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

  const chooseDifferentPoolIdRandomly = async (delegateeBefore1stTx?: Cardano.PoolId): Promise<Cardano.PoolId> => {
    const activePools = await stakePoolProvider.queryStakePools({
      filters: { status: [Cardano.StakePoolStatus.Active] },
      pagination: { limit: 2, startAt: 0 }
    });
    const filteredPools = activePools.pageResults.filter(({ id }) => id !== delegateeBefore1stTx);
    return filteredPools[Math.round(Math.random() * (filteredPools.length - 1))]?.id;
  };

  test('delegation preconditions', async () => {
    const addresses = await firstValueFrom(aliceMultiSigWallet.addresses$);
    const currentEpoch = await firstValueFrom(aliceMultiSigWallet.currentEpoch$);
    expect(addresses[0].rewardAccount).toBeTruthy();
    expect(currentEpoch.epochNo).toBeGreaterThan(0);
  });

  test('balance & transaction', async () => {
    const txFoundInHistory = await firstValueFrom(
      aliceMultiSigWallet.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === fundingTx.id)),
        filter(isNotNil),
        take(1)
      )
    );

    logger.info(`Found transaction id in chain history: ${txFoundInHistory.id}`);

    expect(txFoundInHistory).toBeDefined();
    expect(txFoundInHistory.id).toEqual(fundingTx.id);
    expect(normalizeTxBody(txFoundInHistory.body)).toEqual(normalizeTxBody(fundingTx.body));

    const tx1OutputCoins = 1_000_000n;
    await walletReady(aliceMultiSigWallet, tx1OutputCoins);

    const protocolParameters = await firstValueFrom(aliceMultiSigWallet.protocolParameters$);
    const stakeKeyDeposit = BigInt(protocolParameters.stakeKeyDeposit);
    const initialState = await getWalletStateSnapshot(aliceMultiSigWallet);
    expect(initialState.balance.total.coins).toBe(initialState.balance.available.coins);
    const poolId = await chooseDifferentPoolIdRandomly(initialState.rewardAccount.delegatee?.nextNextEpoch?.id);
    expect(poolId).toBeDefined();
    const initialDeposit = initialState.isStakeCredentialRegistered ? stakeKeyDeposit : 0n;
    expect(initialState.balance.deposit).toBe(initialDeposit);

    // Make a 1st tx with key registration (if not already registered) and stake delegation
    // Also send some coin to another wallet
    const destAddresses = (await firstValueFrom(faucetWallet.addresses$))[0].address;
    const txBuilder = aliceMultiSigWallet.createTxBuilder();

    let tx = (
      await txBuilder
        .addOutput(await txBuilder.buildOutput().address(destAddresses).coin(tx1OutputCoins).build())
        .delegateFirstStakeCredential(poolId)
        .build()
        .sign()
    ).tx;

    // Serialize and transmit TX...
    let serializedTx = Serialization.Transaction.fromCore(tx).toCbor();

    serializedTx = await bobMultiSigWallet.addSignatures({ sender: { id: 'e2e' }, tx: serializedTx });
    serializedTx = await charlotteMultiSigWallet.addSignatures({ sender: { id: 'e2e' }, tx: serializedTx });
    await aliceMultiSigWallet.submitTx(serializedTx);

    // Test it locks available balance after tx is submitted
    await firstValueFromTimed(
      aliceMultiSigWallet.transactions.outgoing.inFlight$.pipe(filter((inFlight) => inFlight.length === 1)),
      'No tx in flight'
    );

    const tx1PendingState = await getWalletStateSnapshot(aliceMultiSigWallet);

    // Updates total and available balance right after tx is submitted
    const coinsSpentOnDeposit = initialState.isStakeCredentialRegistered ? 0n : stakeKeyDeposit;
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

    await waitForTx(aliceMultiSigWallet, tx.id);
    const tx1ConfirmedState = await getWalletStateSnapshot(aliceMultiSigWallet);

    // Check Registration and StakeDelegation certificate from ChainHistoryProvider
    let gotTx = toSerializableObject(
      (await firstValueFrom(aliceMultiSigWallet.transactions.history$)).find((t) => tx.id === t.id)!
    );
    // These are required because txBuilder still uses StakeRegistration
    (gotTx as Cardano.HydratedTx).body.certificates![0].__typename = Cardano.CertificateType.StakeRegistration;
    delete ((gotTx as Cardano.HydratedTx).body.certificates![0] as Partial<Cardano.NewStakeAddressCertificate>).deposit;
    expect((gotTx as Cardano.HydratedTx).body.certificates?.length).toEqual(2);
    expect((gotTx as Cardano.HydratedTx).body.certificates).toEqual(toSerializableObject(tx.body.certificates));

    // Updates total and available balance after tx is on-chain
    expect(tx1ConfirmedState.balance.total.coins).toBe(expectedCoinsAfterTx1);
    expect(tx1ConfirmedState.balance.total).toEqual(tx1ConfirmedState.balance.available);
    expect(tx1ConfirmedState.balance.deposit).toEqual(stakeKeyDeposit);

    // If less than two epochs have elapsed, delegatee will still delegate to former pool during current epoch
    // if more than two epochs has elapsed, delegatee will delegate to new pool.
    const numEpochsPassed = tx1ConfirmedState.epoch - initialState.epoch;
    expect(tx1ConfirmedState.rewardAccount.delegatee?.currentEpoch?.id).toEqual(
      numEpochsPassed === 0
        ? initialState?.rewardAccount.delegatee?.currentEpoch?.id
        : numEpochsPassed === 1
        ? !initialState.isStakeCredentialRegistered
          ? initialState?.rewardAccount.delegatee?.nextEpoch?.id
          : poolId
        : poolId
    );
    expect(tx1ConfirmedState.rewardAccount.delegatee?.nextEpoch?.id).toEqual(
      initialState.isStakeCredentialRegistered
        ? poolId
        : numEpochsPassed === 0
        ? initialState?.rewardAccount.delegatee?.nextEpoch?.id
        : numEpochsPassed === 1
        ? initialState?.rewardAccount.delegatee?.nextNextEpoch?.id
        : poolId
    );
    expect(tx1ConfirmedState.rewardAccount.delegatee?.nextNextEpoch?.id).toEqual(poolId);

    expect(tx1ConfirmedState.rewardAccount.credentialStatus).toBe(Cardano.StakeCredentialStatus.Registered);

    // Make a 2nd tx with key de-registration
    tx = (await aliceMultiSigWallet.createTxBuilder().delegateFirstStakeCredential(null).build().sign()).tx;
    serializedTx = Serialization.Transaction.fromCore(tx).toCbor();

    serializedTx = await bobMultiSigWallet.addSignatures({ sender: { id: 'e2e' }, tx: serializedTx });
    serializedTx = await charlotteMultiSigWallet.addSignatures({ sender: { id: 'e2e' }, tx: serializedTx });

    await aliceMultiSigWallet.submitTx(serializedTx);

    await waitForTx(aliceMultiSigWallet, tx.id);
    const tx2ConfirmedState = await getWalletStateSnapshot(aliceMultiSigWallet);

    // Check Unregistration certificate from ChainHistoryProvider
    gotTx = toSerializableObject(
      (await firstValueFrom(aliceMultiSigWallet.transactions.history$)).find((t) => tx.id === t.id)!
    );
    // These are required because txBuilder still uses StakeDeregistration
    (gotTx as Cardano.HydratedTx).body.certificates![0].__typename = Cardano.CertificateType.StakeDeregistration;
    delete ((gotTx as Cardano.HydratedTx).body.certificates![0] as Partial<Cardano.NewStakeAddressCertificate>).deposit;
    expect((gotTx as Cardano.HydratedTx).body.certificates?.length).toEqual(1);
    expect((gotTx as Cardano.HydratedTx).body.certificates).toEqual(toSerializableObject(tx.body.certificates));

    // No longer delegating
    expect(tx2ConfirmedState.rewardAccount.delegatee?.nextNextEpoch?.id).toBeUndefined();
    expect(tx2ConfirmedState.rewardAccount.credentialStatus).toBe(Cardano.StakeCredentialStatus.Unregistered);

    // Deposit is returned to wallet balance
    const expectedCoinsAfterTx2 = expectedCoinsAfterTx1 + stakeKeyDeposit - tx.body.fee;
    expect(tx2ConfirmedState.balance.total.coins).toBe(expectedCoinsAfterTx2);
    expect(tx2ConfirmedState.balance.total).toEqual(tx2ConfirmedState.balance.available);
    expect(tx2ConfirmedState.balance.deposit).toBe(0n);
  });
});
