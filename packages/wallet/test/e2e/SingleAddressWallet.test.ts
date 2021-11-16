import { Cardano } from '@cardano-sdk/core';
import { SingleAddressWallet, StakeKeyStatus, Wallet } from '../../src';
import { distinctUntilChanged, filter, firstValueFrom, map, merge, mergeMap, skip, tap, timer } from 'rxjs';
import { keyManager, poolId1, poolId2, stakePoolSearchProvider, walletProvider } from './config';

const faucetAddress =
  'addr_test1qqr585tvlc7ylnqvz8pyqwauzrdu0mxag3m7q56grgmgu7sxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknswgndm3';

const createDelegationCertificates = async (wallet: Wallet) => {
  const {
    delegatee: delegateeBefore1stTx,
    address: rewardAccount,
    keyStatus
  } = (await firstValueFrom(wallet.delegation.rewardAccounts$))[0];
  // swap poolId if it's already delegating to one of the pools
  const poolId = delegateeBefore1stTx.nextNextEpoch?.id === poolId2 ? poolId1 : poolId2;
  const isStakeKeyRegistered = keyStatus === StakeKeyStatus.Registered;
  const {
    currentEpoch: { number: epoch }
  } = await firstValueFrom(wallet.networkInfo$);
  return {
    certificates: [
      ...(isStakeKeyRegistered
        ? []
        : ([
            { __typename: Cardano.CertificateType.StakeKeyRegistration, address: rewardAccount }
          ] as Cardano.Certificate[])),
      { __typename: Cardano.CertificateType.StakeDelegation, address: rewardAccount, epoch, poolId }
    ] as Cardano.Certificate[],
    isStakeKeyRegistered,
    poolId
  };
};

const waitForNewStakePoolIdAfterTx = (wallet: Wallet) =>
  firstValueFrom(
    merge(
      wallet.delegation.rewardAccounts$.pipe(
        map(([acc]) => acc.delegatee.nextNextEpoch?.id),
        distinctUntilChanged(),
        skip(1)
      ),
      wallet.transactions.outgoing.failed$,
      // Test will fail if fetching new stake pool takes more than 30s
      wallet.transactions.outgoing.confirmed$.pipe(mergeMap(() => timer(30_000)))
    )
  );

describe('SingleAddressWallet', () => {
  let rewardAccount: Cardano.Address;
  let wallet: Wallet;

  const waitForBalanceCoins = (expectedCoins: Cardano.Lovelace) =>
    firstValueFrom(
      wallet.balance.total$.pipe(
        filter(({ coins }) => coins === expectedCoins),
        tap(({ coins }) => expect(wallet.balance.available$.value?.coins).toBe(coins))
      )
    );

  beforeAll(() => {
    rewardAccount = keyManager.rewardAccount; // TODO: make this available from Wallet.addresses
    wallet = new SingleAddressWallet(
      { name: 'Test Wallet' },
      {
        keyManager,
        stakePoolSearchProvider,
        walletProvider
      }
    );
  });

  afterAll(() => wallet.shutdown());

  it('has an address', () => {
    expect(wallet.addresses[0].bech32.startsWith('addr')).toBe(true);
  });

  test('balance & transaction', async () => {
    const stakeKeyDeposit = BigInt((await firstValueFrom(wallet.protocolParameters$)).stakeKeyDeposit);
    const initialTotalBalance = await firstValueFrom(wallet.balance.total$);
    const initialAvailableBalance = await firstValueFrom(wallet.balance.available$);
    expect(initialTotalBalance.coins).toBeGreaterThan(0n);
    expect(initialTotalBalance.coins).toBe(initialAvailableBalance.coins);
    const tx1OutputCoins = 1_000_000n;

    const { poolId, certificates, isStakeKeyRegistered } = await createDelegationCertificates(wallet);
    const initialDeposit = isStakeKeyRegistered ? stakeKeyDeposit : 0n;
    expect(initialAvailableBalance.deposit).toBe(initialDeposit);

    // Make a 1st tx with key registration (if not already registered) and stake delegation
    // Also send some coin to faucet
    const tx1Internals = await wallet.initializeTx({
      certificates,
      outputs: new Set([{ address: faucetAddress, value: { coins: tx1OutputCoins } }])
    });
    await wallet.submitTx(await wallet.finalizeTx(tx1Internals));

    const expectedCoinsAfterTx1 =
      initialTotalBalance.coins -
      tx1OutputCoins -
      tx1Internals.body.fee -
      (isStakeKeyRegistered ? 0n : stakeKeyDeposit);

    await firstValueFrom(wallet.transactions.outgoing.inFlight$.pipe(filter((txs) => txs.length > 0)));
    // Assert changes after submitting the tx
    await Promise.all([
      // Test it locks available balance after tx is submitted
      // and updates total balance after tx is confirmed
      (async () => {
        const afterTx1TotalBalance = await firstValueFrom(wallet.balance.total$);
        const afterTx1AvailableBalance = await firstValueFrom(wallet.balance.available$);
        expect(afterTx1TotalBalance.coins).toBe(initialTotalBalance.coins);
        const utxo = wallet.utxo.total$.value!;
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
        expect(await waitForNewStakePoolIdAfterTx(wallet)).toBe(poolId);
      })(),
      // Test confirmed$
      async () => {
        expect(await firstValueFrom(wallet.transactions.outgoing.confirmed$)).toBeTruthy();
      }
    ]);

    // Make a 2nd tx with key deregistration
    const tx2Internals = await wallet.initializeTx({
      certificates: [{ __typename: Cardano.CertificateType.StakeKeyDeregistration, address: rewardAccount }]
    });
    await wallet.submitTx(await wallet.finalizeTx(tx2Internals));

    // No longer delegating
    expect(await waitForNewStakePoolIdAfterTx(wallet)).toBeUndefined();

    // Deposit is returned to wallet balance
    await waitForBalanceCoins(expectedCoinsAfterTx1 + stakeKeyDeposit - tx2Internals.body.fee);
    expect((await firstValueFrom(wallet.balance.total$)).deposit).toBe(0n);
  });
});
