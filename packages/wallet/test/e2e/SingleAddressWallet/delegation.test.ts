import { Balance, SingleAddressWallet, StakeKeyStatus, Wallet } from '../../../src';
import { Cardano } from '@cardano-sdk/core';
import {
  assetProvider,
  keyAgentByIdx,
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

const waitForBalanceCoins = (wallet: Wallet, expectedCoins: Cardano.Lovelace) =>
  firstValueFrom(
    wallet.balance.total$.pipe(
      filter(({ coins }) => coins === expectedCoins),
      tap(({ coins }) => expect(wallet.balance.available$.value?.coins).toBe(coins))
    )
  );

describe('SingleAddressWallet/delegation', () => {
  let wallet1: Wallet;
  let wallet2: Wallet;

  beforeAll(async () => {
    wallet1 = new SingleAddressWallet(
      { name: 'Test Wallet 1' },
      {
        assetProvider,
        keyAgent: await keyAgentByIdx(0),
        stakePoolSearchProvider,
        timeSettingsProvider,
        walletProvider
      }
    );
    wallet2 = new SingleAddressWallet(
      { name: 'Test Wallet 2' },
      {
        assetProvider,
        keyAgent: await keyAgentByIdx(1),
        stakePoolSearchProvider,
        timeSettingsProvider,
        walletProvider
      }
    );
  });

  afterAll(() => {
    wallet1.shutdown();
    wallet2.shutdown();
  });

  it('has an address', async () => {
    const wallet_addresses = await firstValueFrom(wallet1.addresses$);
    expect(wallet_addresses[0].address.startsWith('addr')).toBe(true);
    const wallet2_addresses = await firstValueFrom(wallet2.addresses$);
    expect(wallet2_addresses[0].address.startsWith('addr')).toBe(true);
  });

  it('has assets$', async () => {
    expect(typeof (await firstValueFrom(wallet1.assets$))).toBe('object');
    expect(typeof (await firstValueFrom(wallet2.assets$))).toBe('object');
  });

  const chooseWallets = async (): Promise<[Wallet, Wallet, Balance]> => {
    const wallet1Balance = await firstValueFrom(wallet1.balance.available$);
    const wallet2Balance = await firstValueFrom(wallet2.balance.available$);
    return wallet1Balance.coins > wallet2Balance.coins
      ? [wallet1, wallet2, wallet1Balance]
      : [wallet2, wallet1, wallet2Balance];
  };

  test('balance & transaction', async () => {
    // source wallet has the highest balance to begin with
    const [sourceWallet, destWallet, initialAvailableBalance] = await chooseWallets();
    const [{ rewardAccount }] = await firstValueFrom(sourceWallet.addresses$);

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
    // eslint-disable-next-line no-console
    console.log('FIRST SUBMIT');

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
        // sometimes FAILS like "Expected: 54507787n Received: 7848029n"
        expect(afterTx1AvailableBalance.coins).toBe(expectedCoinsWhileTxPending);
        await waitForBalanceCoins(sourceWallet, expectedCoinsAfterTx1);
        // eslint-disable-next-line no-console
        console.log('SOURCE WALLET BALANCE OK 1');
      })(),
      // Test it updates wallet.delegation after delegating to stake pool
      (async () => {
        // sometimes FAILS where "Expected: "pool1fghrkl620rl3g54ezv56weeuwlyce2tdannm2hphs62syf3vyyh" Received: 0"
        expect(await waitForNewStakePoolIdAfterTx(sourceWallet)).toBe(poolId);
        const [newDelegatee] = await firstValueFrom(sourceWallet.delegation.rewardAccounts$);
        // nothing changes for 2 epochs
        expect(newDelegatee.delegatee?.nextEpoch).toEqual(initialDelegatee?.delegatee?.nextEpoch);
        expect(newDelegatee.delegatee?.currentEpoch).toEqual(initialDelegatee?.delegatee?.currentEpoch);
        // eslint-disable-next-line no-console
        console.log('DELEGATION COMPLETE');
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
    // eslint-disable-next-line no-console
    console.log('SECOND SUBMIT');

    // No longer delegating
    expect(await waitForNewStakePoolIdAfterTx(sourceWallet)).toBeUndefined();
    // eslint-disable-next-line no-console
    console.log('NO LONGER DELEGATING');

    // Deposit is returned to wallet balance
    await waitForBalanceCoins(sourceWallet, expectedCoinsAfterTx1 + stakeKeyDeposit - tx2Internals.body.fee);
    // eslint-disable-next-line no-console
    console.log('SOURCE WALLET BALANCE OK 2');
    expect((await firstValueFrom(sourceWallet.balance.total$)).deposit).toBe(0n);
  });
});
