import { Cardano } from '@cardano-sdk/core';
import { DirectionalTransaction } from '../types';
import { TxAlonzo } from '@cardano-sdk/core/src/Cardano';

export const strictEquals = <T>(a: T, b: T) => a === b;

export const arrayEquals = <T>(arrayA: T[], arrayB: T[], itemEquals: (a: T, b: T) => boolean) =>
  arrayA.length === arrayB.length && arrayA.every((a) => arrayB.some((b) => itemEquals(a, b)));

export const txEquals = (a: TxAlonzo, b: TxAlonzo) => a.id === b.id;

export const transactionsEquals = (a: Cardano.TxAlonzo[], b: Cardano.TxAlonzo[]) => arrayEquals(a, b, txEquals);

export const directionalTransactionsEquals = (a: DirectionalTransaction[], b: DirectionalTransaction[]) =>
  arrayEquals(a, b, (aTx, bTx) => txEquals(aTx.tx, bTx.tx));

export const utxoEquals = (a: Cardano.Utxo[], b: Cardano.Utxo[]) =>
  arrayEquals(a, b, ([aTxIn], [bTxIn]) => aTxIn.txId === bTxIn.txId && aTxIn.index === bTxIn.index);
