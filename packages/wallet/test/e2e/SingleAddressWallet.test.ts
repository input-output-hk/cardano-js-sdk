import { Cardano } from '@cardano-sdk/core';
import { SingleAddressWallet, StakeKeyStatus, Wallet } from '../../src';
import { filter, firstValueFrom, skip, tap } from 'rxjs';
import { keyManagers, poolId1, poolId2, stakePoolSearchProvider, walletProvider } from './config';

const createDelegationCertificates = async (wallet: Wallet, rewardAccount: Cardano.Address) => {
  const delegateeBefore1stTx = await firstValueFrom(wallet.delegation.delegatee$);
  // swap poolId if it's already delegating to one of the pools
  const poolId = delegateeBefore1stTx.nextNextEpoch?.id === poolId2 ? poolId1 : poolId2;
  const isStakeKeyRegistered = (await firstValueFrom(wallet.delegation.rewardAccounts$)).some(
    (acc) => acc.keyStatus === StakeKeyStatus.Registered
  );
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

describe('SingleAddressWallet', () => {
  let rewardAccount: Cardano.Address;
  let walletOne: Wallet;
  let walletTwo: Wallet;

  const waitForBalanceCoins = (expectedCoins: Cardano.Lovelace) =>
    firstValueFrom(
      walletOne.balance.total$.pipe(
        filter(({ coins }) => coins === expectedCoins),
        tap(({ coins }) => expect(walletOne.balance.available$.value?.coins).toBe(coins))
      )
    );

  beforeAll(() => {
    rewardAccount = keyManagers[0].rewardAccount; // TODO: make this available from Wallet.addresses
    walletOne = new SingleAddressWallet(
      { name: 'Test Wallet One' },
      {
        keyManager: keyManagers[0],
        stakePoolSearchProvider,
        walletProvider
      }
    );
    walletTwo = new SingleAddressWallet(
      { name: 'Test Wallet Two' },
      {
        keyManager: keyManagers[1],
        stakePoolSearchProvider,
        walletProvider
      }
    );
  });

  afterAll(() => {
    walletOne.shutdown();
    walletTwo.shutdown();
  });

  it('has an address', () => {
    expect(walletOne.addresses[0].bech32.startsWith('addr')).toBe(true);
    expect(walletTwo.addresses[0].bech32.startsWith('addr')).toBe(true);
  });

  test('balance & transaction', async () => {
    const stakeKeyDeposit = BigInt((await firstValueFrom(walletOne.protocolParameters$)).stakeKeyDeposit);
    const initialTotalBalance = {
      one: await firstValueFrom(walletOne.balance.total$),
      two: await firstValueFrom(walletTwo.balance.total$)
    };
    const initialAvailableBalance = {
      one: await firstValueFrom(walletOne.balance.available$),
      two: await firstValueFrom(walletTwo.balance.available$)
    };
    expect(initialTotalBalance.one.coins).toBeGreaterThan(0n);
    expect(initialTotalBalance.one.coins).toBe(initialAvailableBalance.one.coins);
    const tx1OutputCoins = 1_000_000n;

    const { poolId, certificates, isStakeKeyRegistered } = await createDelegationCertificates(walletOne, rewardAccount);
    const initialDeposit = isStakeKeyRegistered ? stakeKeyDeposit : 0n;
    expect(initialAvailableBalance.one.deposit).toBe(initialDeposit);

    // Make a 1st tx with:
    // - key registration, if not already registered
    // - stake delegation
    // - payment of coins to walletTwo
    const tx1Internals = await walletOne.initializeTx({
      certificates,
      outputs: new Set([{ address: walletTwo.addresses[0].bech32, value: { coins: tx1OutputCoins } }])
    });
    await walletOne.submitTx(await walletOne.finalizeTx(tx1Internals));

    const expectedCoinsAfterTx1 = {
      one:
        initialTotalBalance.one.coins -
        tx1OutputCoins -
        tx1Internals.body.fee -
        (isStakeKeyRegistered ? 0n : stakeKeyDeposit),
      two: initialTotalBalance.two.coins + tx1OutputCoins
    };

    await firstValueFrom(walletOne.transactions.outgoing.inFlight$.pipe(filter((txs) => txs.length > 0)));

    // Assert changes after submitting the tx
    await Promise.all([
      // Test it locks available balance in walletOne after tx is submitted
      // and updates total balance after tx is confirmed
      (async () => {
        const afterTx1TotalBalance = await firstValueFrom(walletOne.balance.total$);
        const afterTx1AvailableBalance = await firstValueFrom(walletOne.balance.available$);
        expect(afterTx1TotalBalance.coins).toBe(initialTotalBalance.one.coins);
        const utxo = walletOne.utxo.total$.value!;
        const expectedCoinsWhileTxPending =
          initialTotalBalance.one.coins -
          Cardano.util.coalesceValueQuantities(
            tx1Internals.body.inputs.map((txInput) => utxo.find(([txIn]) => txIn.txId === txInput.txId)![1].value)
          ).coins;

        expect(afterTx1AvailableBalance.coins).toBe(expectedCoinsWhileTxPending);
        await waitForBalanceCoins(expectedCoinsAfterTx1.one);
      })(),
      // Test it updates walletOne.delegation after delegating to stake pool
      (async () => {
        const delegateeAfter1stTx = await firstValueFrom(walletOne.delegation.delegatee$.pipe(skip(1)));
        expect(delegateeAfter1stTx.nextNextEpoch?.id).toBe(poolId);
      })(),
      // Assert it updates walletTwo after receiving funds
      (async () => {
        await firstValueFrom(walletTwo.transactions.incoming$);
        const afterTx1TotalBalance = await firstValueFrom(walletTwo.balance.total$);
        expect(afterTx1TotalBalance.coins).toBe(expectedCoinsAfterTx1.two);
        await waitForBalanceCoins(expectedCoinsAfterTx1.two);
      })()
    ]);

    // Make a 2nd tx with:
    // - walletOne key deregistration
    const tx2Internals = await walletOne.initializeTx({
      certificates: [{ __typename: Cardano.CertificateType.StakeKeyDeregistration, address: rewardAccount }]
    });
    await walletOne.submitTx(await walletOne.finalizeTx(tx2Internals));

    // No longer delegating
    const delegateeAfter2ndTx = await firstValueFrom(walletOne.delegation.delegatee$.pipe(skip(1)));
    expect(delegateeAfter2ndTx.nextNextEpoch?.id).toBeUndefined();

    // Deposit is returned to walletOne balance
    await waitForBalanceCoins(expectedCoinsAfterTx1.one + stakeKeyDeposit - tx2Internals.body.fee);
    expect((await firstValueFrom(walletOne.balance.total$)).deposit).toBe(0n);

    const afterTx2TotalBalance = {
      one: await firstValueFrom(walletOne.balance.total$),
      two: await firstValueFrom(walletTwo.balance.total$)
    };

    // Make a 3rd tx using wallet2 with:
    // - payment to return the coins received in tx1 for future tests

    const tx3Internals = await walletTwo.initializeTx({
      outputs: new Set([{ address: walletOne.addresses[0].bech32, value: { coins: tx1OutputCoins } }])
    });
    await walletTwo.submitTx(await walletTwo.finalizeTx(tx3Internals));

    const expectedCoinsInWalletOneAfterTx3 = afterTx2TotalBalance.one.coins + tx1OutputCoins;

    await waitForBalanceCoins(expectedCoinsInWalletOneAfterTx3);
    await expect(walletOne.balance.total$).toBe(expectedCoinsInWalletOneAfterTx3);
  });
});
