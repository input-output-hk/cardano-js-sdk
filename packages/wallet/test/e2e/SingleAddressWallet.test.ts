import { Cardano } from '@cardano-sdk/core';
import { SingleAddressWallet, Wallet } from '../../src';
import { filter, firstValueFrom, tap } from 'rxjs';
import { keyManager, stakePoolSearchProvider, walletProvider } from './config';

const faucetAddress =
  'addr_test1qqr585tvlc7ylnqvz8pyqwauzrdu0mxag3m7q56grgmgu7sxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknswgndm3';

describe('SingleAddressWallet', () => {
  let wallet: Wallet;

  beforeAll(() => {
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
