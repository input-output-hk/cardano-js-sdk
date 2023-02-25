/* eslint-disable func-style */
/* eslint-disable jsdoc/require-jsdoc */

import { Cardano, TxCBOR } from '@cardano-sdk/core';
import { MaybeValidTx, MaybeValidTxOut, ObservableWallet, OutgoingTx, ValidTx, ValidTxOut } from '../src';
import { Observable, catchError, filter, firstValueFrom, throwError, timeout } from 'rxjs';

const SECOND = 1000;
const MINUTE = 60 * SECOND;
export const TX_TIMEOUT = 7 * MINUTE;
const SYNC_TIMEOUT = 3 * MINUTE;
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
    'Took too long to load',
    SYNC_TIMEOUT
  );

export function assertTxIsValid(tx: MaybeValidTx): asserts tx is ValidTx {
  expect(tx.isValid).toBe(true);
}

export function assertTxOutIsValid(txOut: MaybeValidTxOut): asserts txOut is ValidTxOut {
  expect(txOut.isValid).toBe(true);
}

export const toOutgoingTx = (tx: Cardano.Tx): OutgoingTx => ({
  body: tx.body,
  cbor: TxCBOR.serialize(tx),
  id: tx.id
});

export const dummyCbor = TxCBOR('123');
