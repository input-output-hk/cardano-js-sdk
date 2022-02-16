import { Cardano } from '@cardano-sdk/core';
import { SingleAddressWallet, StakeKeyStatus, Wallet } from '../../../src';
import {
  assetProvider,
  keyAgentsReady,
  poolId1,
  poolId2,
  stakePoolSearchProvider,
  timeSettingsProvider,
  walletProvider
} from '../config';
import { distinctUntilChanged, filter, firstValueFrom, map, merge, mergeMap, skip, tap, timer } from 'rxjs';

const createDelegationCertificates = async (wallet: Wallet) => {
  const {
    delegatee: delegateeBefore1stTx,
    address: rewardAccount,
    keyStatus
  } = (await firstValueFrom(wallet.delegation.rewardAccounts$))[0];
  // swap poolId if it's already delegating to one of the pools
  const poolId = delegateeBefore1stTx?.nextNextEpoch.id === poolId2 ? poolId1 : poolId2;
  const isStakeKeyRegistered = keyStatus === StakeKeyStatus.Registered;
  const {
    currentEpoch: { number: epoch }
  } = await firstValueFrom(wallet.networkInfo$);
  return {
    certificates: [
      ...(isStakeKeyRegistered
        ? []
        : ([{ __typename: Cardano.CertificateType.StakeKeyRegistration, rewardAccount }] as Cardano.Certificate[])),
      { __typename: Cardano.CertificateType.StakeDelegation, epoch, poolId, rewardAccount }
    ] as Cardano.Certificate[],
    isStakeKeyRegistered,
    poolId
  };
};

const waitForNewStakePoolIdAfterTx = (wallet: Wallet) =>
  firstValueFrom(
    merge(
      wallet.delegation.rewardAccounts$.pipe(
        map(([acc]) => acc.delegatee?.nextNextEpoch.id),
        distinctUntilChanged(),
        skip(1)
      ),
      wallet.transactions.outgoing.failed$,
      // Test will fail if fetching new stake pool takes more than 30s
      wallet.transactions.outgoing.confirmed$.pipe(mergeMap(() => timer(30_000)))
    )
  );

describe('SingleAddressWallet/delegation', () => {
  let rewardAccount: Cardano.RewardAccount;
  let wallet: Wallet;
  let wallet2: Wallet;

  const waitForBalanceCoins = (expectedCoins: Cardano.Lovelace) =>
    firstValueFrom(
      wallet.balance.total$.pipe(
        filter(({ coins }) => coins === expectedCoins),
        tap(({ coins }) => expect(wallet.balance.available$.value?.coins).toBe(coins))
      )
    );

  beforeAll(async () => {
    wallet = new SingleAddressWallet(
      { name: 'Test Wallet' },
      {
        assetProvider,
        keyAgent: await keyAgentsReady[0],
        stakePoolSearchProvider,
        timeSettingsProvider,
        walletProvider
      }
    );
    [{ rewardAccount }] = await firstValueFrom(wallet.addresses$);
    wallet2 = new SingleAddressWallet(
      { name: 'Test Wallet2' },
      {
        assetProvider,
        keyAgent: await keyAgentsReady[1],
        stakePoolSearchProvider,
        timeSettingsProvider,
        walletProvider
      }
    );
  });

  afterAll(() => {
    wallet.shutdown();
    wallet2.shutdown();
  });

  it('has an address', async () => {
    const addresses = await firstValueFrom(wallet.addresses$);
    expect(addresses[0].address.startsWith('addr')).toBe(true);
  });

  it('has assets$', async () => {
    expect(typeof (await firstValueFrom(wallet.assets$))).toBe('object');
  });

  test('balance & transaction', async () => {
    let sourceWallet: Wallet;
    let destWallet: Wallet;

    let initialAvailableBalance = await firstValueFrom(wallet.balance.available$);
    const initialAvailableBalance2 = await firstValueFrom(wallet2.balance.available$);
    if (initialAvailableBalance.coins > initialAvailableBalance2.coins) {
      sourceWallet = wallet;
      destWallet = wallet2;
    } else {
      sourceWallet = wallet2;
      destWallet = wallet;
      initialAvailableBalance = initialAvailableBalance2;
    }
    const initialTotalBalance = await firstValueFrom(sourceWallet.balance.total$);
    const stakeKeyDeposit = BigInt((await firstValueFrom(sourceWallet.protocolParameters$)).stakeKeyDeposit);

    expect(initialTotalBalance.coins).toBeGreaterThan(0n);
    expect(initialTotalBalance.coins).toBe(initialAvailableBalance.coins);
    const tx1OutputCoins = 1_000_000n;

    const { poolId, certificates, isStakeKeyRegistered } = await createDelegationCertificates(sourceWallet);
    const initialDeposit = isStakeKeyRegistered ? stakeKeyDeposit : 0n;
    expect(initialAvailableBalance.deposit).toBe(initialDeposit);
    const [initialDelegatee] = await firstValueFrom(sourceWallet.delegation.rewardAccounts$);

    // Make a 1st tx with key registration (if not already registered) and stake delegation
    // Also send some coin to wallet2
    const destAddresses = await firstValueFrom(destWallet.addresses$);
    const tx1Internals = await sourceWallet.initializeTx({
      certificates,
      outputs: new Set([{ address: destAddresses[0].address, value: { coins: tx1OutputCoins } }])
    });
    await sourceWallet.submitTx(await sourceWallet.finalizeTx(tx1Internals));

    const expectedCoinsAfterTx1 =
      initialTotalBalance.coins -
      tx1OutputCoins -
      tx1Internals.body.fee -
      (isStakeKeyRegistered ? 0n : stakeKeyDeposit);

    await firstValueFrom(sourceWallet.transactions.outgoing.inFlight$.pipe(filter((txs) => txs.length > 0)));
    // Assert changes after submitting the tx
    await Promise.all([
      // Test it locks available balance after tx is submitted
      // and updates total balance after tx is confirmed
      (async () => {
        const afterTx1TotalBalance = await firstValueFrom(sourceWallet.balance.total$);
        const afterTx1AvailableBalance = await firstValueFrom(sourceWallet.balance.available$);
        expect(afterTx1TotalBalance.coins).toBe(initialTotalBalance.coins);
        const utxo = sourceWallet.utxo.total$.value!;
        const expectedCoinsWhileTxPending =
          initialTotalBalance.coins -
          Cardano.util.coalesceValueQuantities(
            tx1Internals.body.inputs.map((txInput) => utxo.find(([txIn]) => txIn.txId === txInput.txId)![1].value)
          ).coins;
        expect(afterTx1AvailableBalance.coins).toBe(expectedCoinsWhileTxPending);
        await waitForBalanceCoins(expectedCoinsAfterTx1);
      })(),
      // Test it updates wallet.delegation after delegating to stake pool
      (async () => {
        expect(await waitForNewStakePoolIdAfterTx(sourceWallet)).toBe(poolId);
        const [newDelegatee] = await firstValueFrom(sourceWallet.delegation.rewardAccounts$);
        // nothing changes for 2 epochs
        expect(newDelegatee.delegatee?.nextEpoch).toEqual(initialDelegatee?.delegatee?.nextEpoch);
        expect(newDelegatee.delegatee?.currentEpoch).toEqual(initialDelegatee?.delegatee?.currentEpoch);
      })(),
      // Test confirmed$
      async () => {
        expect(await firstValueFrom(sourceWallet.transactions.outgoing.confirmed$)).toBeTruthy();
      }
    ]);

    // Make a 2nd tx with key deregistration
    const tx2Internals = await sourceWallet.initializeTx({
      certificates: [{ __typename: Cardano.CertificateType.StakeKeyDeregistration, rewardAccount }]
    });
    await sourceWallet.submitTx(await sourceWallet.finalizeTx(tx2Internals));

    // No longer delegating
    expect(await waitForNewStakePoolIdAfterTx(sourceWallet)).toBeUndefined();

    // Deposit is returned to wallet balance
    await waitForBalanceCoins(expectedCoinsAfterTx1 + stakeKeyDeposit - tx2Internals.body.fee);
    expect((await firstValueFrom(sourceWallet.balance.total$)).deposit).toBe(0n);
  });
});
