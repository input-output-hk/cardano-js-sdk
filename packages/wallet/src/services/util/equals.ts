import { Cardano, EpochInfo, EraSummary } from '@cardano-sdk/core';
import { GroupedAddress } from '../../KeyManagement';
import isEqual from 'lodash/isEqual';

export const strictEquals = <T>(a: T, b: T) => a === b;

export const deepEquals = <T>(a: T, b: T) => isEqual(a, b);

export const arrayEquals = <T>(arrayA: T[], arrayB: T[], itemEquals: (a: T, b: T) => boolean) =>
  arrayA.length === arrayB.length && arrayA.every((a) => arrayB.some((b) => itemEquals(a, b)));

export const shallowArrayEquals = <T>(a: T[], b: T[]) => arrayEquals(a, b, strictEquals);

export const tipEquals = (a: Cardano.Tip, b: Cardano.Tip) => a.hash === b.hash;

export const txEquals = (a: Cardano.TxAlonzo, b: Cardano.TxAlonzo) => a.id === b.id;

export const transactionsEquals = (a: Cardano.TxAlonzo[], b: Cardano.TxAlonzo[]) => arrayEquals(a, b, txEquals);

export const txInEquals = (a: Cardano.NewTxIn, b: Cardano.NewTxIn) => a.txId === b.txId && a.index === b.index;

export const utxoEquals = (a: Cardano.Utxo[], b: Cardano.Utxo[]) =>
  arrayEquals(a, b, ([aTxIn], [bTxIn]) => txInEquals(aTxIn, bTxIn));

export const eraSummariesEquals = (a: EraSummary[], b: EraSummary[]) =>
  arrayEquals(a, b, (es1, es2) => es1.start.slot === es2.start.slot);

const groupedAddressEquals = (a: GroupedAddress, b: GroupedAddress) => a.address === b.address;

export const groupedAddressesEquals = (a: GroupedAddress[], b: GroupedAddress[]) =>
  arrayEquals(a, b, groupedAddressEquals);

export const epochInfoEquals = (a: EpochInfo, b: EpochInfo) => a.epochNo === b.epochNo;
