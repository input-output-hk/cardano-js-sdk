import { Cardano } from '@cardano-sdk/core';
import { isEqual } from 'lodash-es';

export const strictEquals = <T>(a: T, b: T) => a === b;

export const deepEquals = <T>(a: T, b: T) => isEqual(a, b);

export const arrayEquals = <T>(arrayA: T[], arrayB: T[], itemEquals: (a: T, b: T) => boolean) =>
  arrayA.length === arrayB.length && arrayA.every((a) => arrayB.some((b) => itemEquals(a, b)));

export const shallowArrayEquals = <T>(a: T[], b: T[]) => arrayEquals(a, b, strictEquals);

export const txEquals = (a: Cardano.TxAlonzo, b: Cardano.TxAlonzo) => a.id === b.id;

export const transactionsEquals = (a: Cardano.TxAlonzo[], b: Cardano.TxAlonzo[]) => arrayEquals(a, b, txEquals);

export const utxoEquals = (a: Cardano.Utxo[], b: Cardano.Utxo[]) =>
  arrayEquals(a, b, ([aTxIn], [bTxIn]) => aTxIn.txId === bTxIn.txId && aTxIn.index === bTxIn.index);
