/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano } from '@cardano-sdk/core';
import {
  EMPTY,
  Observable,
  catchError,
  combineLatest,
  filter,
  firstValueFrom,
  merge,
  mergeMap,
  throwError,
  timeout
} from 'rxjs';
import { ObservableWallet } from '@cardano-sdk/wallet';

const SECOND = 1000;
const MINUTE = 60 * SECOND;
export const TX_TIMEOUT = 7 * MINUTE;
const SYNC_TIMEOUT = 3 * MINUTE;
const BALANCE_TIMEOUT = 3 * MINUTE;

export const FAST_OPERATION_TIMEOUT = 15 * SECOND;

export const firstValueFromTimed = <T>(
  observable$: Observable<T>,
  timeoutMessage = 'Timed out',
  timeoutAfter = FAST_OPERATION_TIMEOUT
) =>
  firstValueFrom(
    observable$.pipe(
      timeout(timeoutAfter),
      catchError(() => throwError(() => new Error(timeoutMessage)))
    )
  );

export const waitForWalletStateSettle = (wallet: ObservableWallet) =>
  firstValueFromTimed(
    wallet.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)),
    'Took too long to settle',
    SYNC_TIMEOUT
  );

export const waitForWalletBalance = (wallet: ObservableWallet) =>
  firstValueFromTimed(
    wallet.balance.utxo.total$.pipe(filter(({ coins }) => coins > 0)),
    'Took too long to load balance',
    BALANCE_TIMEOUT
  );

export const walletReady = (wallet: ObservableWallet) =>
  firstValueFromTimed(
    combineLatest([wallet.syncStatus.isSettled$, wallet.balance.utxo.total$]).pipe(
      filter(([isSettled, balance]) => isSettled && balance.coins > 0n)
    ),
    'Took too long to be ready',
    SYNC_TIMEOUT
  );

export const normalizeTxBody = (body: Cardano.TxBodyAlonzo | Cardano.NewTxBodyAlonzo) => {
  body.collaterals ||= [];
  return body;
};

export const txConfirmed = (
  {
    transactions: {
      outgoing: { confirmed$, failed$ }
    }
  }: ObservableWallet,
  { id }: Cardano.NewTxAlonzo
) =>
  merge(
    confirmed$.pipe(filter(({ tx }) => tx.id === id)),
    failed$.pipe(
      mergeMap(({ tx, error, reason }) =>
        tx.id === id ? throwError(() => error || new Error(`Tx failed due to '${reason}': ${id}`)) : EMPTY
      )
    )
  );

export const submitAndConfirm = (wallet: ObservableWallet, tx: Cardano.NewTxAlonzo) =>
  Promise.all([wallet.submitTx(tx), firstValueFrom(txConfirmed(wallet, tx))]);
