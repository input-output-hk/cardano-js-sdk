import { SingleAddressWallet, Wallet } from '../../src';
import { filter, firstValueFrom, tap } from 'rxjs';
import { keyManager, stakePoolSearchProvider, walletProvider } from './config';

const faucetAddress =
  'addr_test1qrydm8hsalwjmuqj624cwnyrs554zu6a8n8wg64dxk3zarsxu2hyfhlkwuxupa9d5085eunq2qywy7hvmvej456flknsq3qxgd';

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
    const expectedCoinsAfterTx = initialTotalBalance.coins - txCoins;
    const txInternals = await wallet.initializeTx({
      outputs: new Set([{ address: faucetAddress, value: { coins: txCoins } }])
    });
    await wallet.submitTx(await wallet.finalizeTx(txInternals));
    const afterTxTotalBalance = await firstValueFrom(wallet.balance.total$);
    const afterTxAvailableBalance = await firstValueFrom(wallet.balance.available$);
    expect(afterTxTotalBalance.coins).toBe(initialTotalBalance.coins);
    expect(afterTxAvailableBalance.coins).toBe(expectedCoinsAfterTx);
    await firstValueFrom(
      wallet.balance.total$.pipe(
        filter(({ coins }) => coins === expectedCoinsAfterTx),
        tap(({ coins }) => expect(wallet.balance.available$.value?.coins).toBe(coins))
      )
    );
  });
});
