import { BehaviorSubject, NEVER, of } from 'rxjs';
import { Cardano } from '@cardano-sdk/core';
import { insufficientFundsMessage, walletReady } from '../src/index.js';
import type { ObservableWallet } from '@cardano-sdk/wallet';

describe('util for e2e tests', () => {
  describe('walletReady', () => {
    const address = Cardano.PaymentAddress(
      'addr_test1qpcncempf4svkpw0salztrsxzrfpr5ll323q5whw7lv94vyw0kz5rxvdaq6u6tslwfrrgz6l4n4lpcpnawn87yl9k6dsu4hhg2'
    );

    const timeoutErrStr = 'Took too long to be ready';

    let wallet: ObservableWallet;
    let total$: BehaviorSubject<Cardano.Value>;
    let isSettled$: BehaviorSubject<boolean>;

    beforeEach(() => {
      total$ = new BehaviorSubject<Cardano.Value>({ coins: 1n });
      isSettled$ = new BehaviorSubject<boolean>(true);
      wallet = {
        addresses$: of([{ address }]),
        balance: { utxo: { total$ } },
        syncStatus: { isSettled$ }
      } as unknown as ObservableWallet;
    });

    it('uses 1 lovelace as minimum required balance', async () => {
      const [_, { coins }] = await walletReady(wallet);

      expect(coins).toEqual(1n);
    });

    it('returns the balance when it is equal to the required minimum', async () => {
      const coins = 1_000_000n;
      total$.next({ coins });
      const [_, balance] = await walletReady(wallet, coins);
      expect(balance.coins).toEqual(coins);
    });

    it('returns the balance when it is greater than the required minimum', async () => {
      const coins = 1_000_001n;
      total$.next({ coins });
      const [_, balance] = await walletReady(wallet, coins - 1n);

      expect(balance.coins).toEqual(coins);
    });

    it('fails with timeout if wallet is not ready', async () => {
      const minCoinBalance = 0n;
      isSettled$.next(false);
      await expect(walletReady(wallet, minCoinBalance, 0)).rejects.toThrow(timeoutErrStr);
    });

    it('fails with timeout if wallet balance never resolves', async () => {
      const minCoinBalance = 0n;
      wallet = {
        addresses$: of([{ address }]),
        balance: { utxo: { total$: NEVER } },
        syncStatus: { isSettled$ }
      } as unknown as ObservableWallet;
      await expect(walletReady(wallet, minCoinBalance, 0)).rejects.toThrow(timeoutErrStr);
    });

    it('fails with timeout if wallet address never resolves', async () => {
      const minCoinBalance = 0n;
      wallet = {
        addresses$: NEVER,
        balance: { utxo: { total$ } },
        syncStatus: { isSettled$ }
      } as unknown as ObservableWallet;
      await expect(walletReady(wallet, minCoinBalance, 0)).rejects.toThrow(timeoutErrStr);
    });

    it('fails with insufficient funds if balance minimum not met', async () => {
      const coins = 10n;
      const minCoinBalance = coins + 1n;
      total$.next({ coins });
      await expect(walletReady(wallet, minCoinBalance)).rejects.toThrow(
        insufficientFundsMessage(address, minCoinBalance, coins)
      );
    });
  });
});
