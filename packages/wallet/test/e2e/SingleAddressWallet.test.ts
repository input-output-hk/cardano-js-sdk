import { Cardano } from '@cardano-sdk/core';
import { SingleAddressWallet, Wallet } from '../../src';
import { combineLatest, filter, firstValueFrom, skip, tap } from 'rxjs';
import { keyManager, poolId1, poolId2, stakePoolSearchProvider, walletProvider } from './config';

const faucetAddress =
  'addr_test1qqr585tvlc7ylnqvz8pyqwauzrdu0mxag3m7q56grgmgu7sxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknswgndm3';

describe('SingleAddressWallet', () => {
  let rewardAccount: Cardano.Address;
  let wallet: Wallet;

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

  test('delegation', async () => {
    const delegateeBefore1stTx = await firstValueFrom(wallet.delegation.delegatee$);
    // swap poolId if it's already delegating to one of the pools
    const poolId = delegateeBefore1stTx.nextNextEpoch?.id === poolId2 ? poolId1 : poolId2;
    const isStakeKeyRegistered = !!delegateeBefore1stTx.nextNextEpoch;
    const {
      currentEpoch: { number: epoch }
    } = await firstValueFrom(wallet.networkInfo$);

    // Make a 1st tx with key registration (if not already registered) and stake delegation
    const tx1Internals = await wallet.initializeTx({
      certificates: [
        ...(isStakeKeyRegistered
          ? []
          : ([
              { __typename: Cardano.CertificateType.StakeRegistration, address: rewardAccount }
            ] as Cardano.Certificate[])),
        { __typename: Cardano.CertificateType.StakeDelegation, address: rewardAccount, epoch, poolId }
      ],
      // TODO: make outputs optional. Coin selection has to select at least 1 utxo for change output in this case.
      outputs: new Set()
    });
    await wallet.submitTx(await wallet.finalizeTx(tx1Internals));
    const delegateeAfter1stTx = await firstValueFrom(wallet.delegation.delegatee$.pipe(skip(1)));
    expect(delegateeAfter1stTx.nextNextEpoch?.id).toBe(poolId);

    // Wait for utxo to be unlocked to make a 2nd transaction
    await firstValueFrom(
      combineLatest([wallet.balance.available$, wallet.balance.total$]).pipe(
        filter(([total, available]) => total.coins === available.coins)
      )
    );
    // Make a 2nd tx with key deregistration
    const tx2Internals = await wallet.initializeTx({
      certificates: [{ __typename: Cardano.CertificateType.StakeDeregistration, address: rewardAccount }],
      outputs: new Set()
    });
    await wallet.submitTx(await wallet.finalizeTx(tx2Internals));
    const delegateeAfter2ndTx = await firstValueFrom(wallet.delegation.delegatee$.pipe(skip(1)));
    expect(delegateeAfter2ndTx.nextNextEpoch?.id).toBeUndefined();
  });

  test('balance', async () => {
    // has some coin on load
    const initialTotalBalance = await firstValueFrom(wallet.balance.total$);
    const initialAvailableBalance = await firstValueFrom(wallet.balance.available$);
    expect(initialTotalBalance.coins).toBeGreaterThan(0n);
    expect(initialTotalBalance.coins).toBe(initialAvailableBalance.coins);
    // available balance changes when tx is submitted
    const txCoins = 1_000_000n;
    const txInternals = await wallet.initializeTx({
      outputs: new Set([{ address: faucetAddress, value: { coins: txCoins } }])
    });
    await wallet.submitTx(await wallet.finalizeTx(txInternals));

    const afterTxTotalBalance = await firstValueFrom(wallet.balance.total$);
    const afterTxAvailableBalance = await firstValueFrom(wallet.balance.available$);
    expect(afterTxTotalBalance.coins).toBe(initialTotalBalance.coins);

    const utxo = wallet.utxo.total$.value!;
    const expectedCoinsWhileTxPending =
      initialTotalBalance.coins -
      Cardano.util.coalesceValueQuantities(
        txInternals.body.inputs.map((txInput) => utxo.find(([txIn]) => txIn.txId === txInput.txId)![1].value)
      ).coins;
    expect(afterTxAvailableBalance.coins).toBe(expectedCoinsWhileTxPending);

    const expectedAfterTxCoins = initialTotalBalance.coins - txCoins - txInternals.body.fee;
    await firstValueFrom(
      wallet.balance.total$.pipe(
        filter(({ coins }) => coins === expectedAfterTxCoins),
        tap(({ coins }) => expect(wallet.balance.available$.value?.coins).toBe(coins))
      )
    );
  });
});
