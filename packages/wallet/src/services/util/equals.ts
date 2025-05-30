import { Cardano, EpochInfo, EraSummary } from '@cardano-sdk/core';
import { DelegatedStake } from '../types';
import { GroupedAddress, WitnessedTx } from '@cardano-sdk/key-management';
import { sameArrayItems } from '@cardano-sdk/util';

export const tipEquals = (a: Cardano.Tip, b: Cardano.Tip) => a.hash === b.hash;

export const txEquals = (a: Cardano.HydratedTx, b: Cardano.HydratedTx) => a.id === b.id;

export const sameSortedArrayItems = <T>(arrayA: T[], arrayB: T[], itemEquals: (a: T, b: T) => boolean): boolean => {
  if (arrayA.length !== arrayB.length) return false;

  for (const [i, element] of arrayA.entries()) {
    if (!itemEquals(element, arrayB[i])) {
      return false;
    }
  }

  return true;
};

export const transactionsEquals = (a: Cardano.HydratedTx[], b: Cardano.HydratedTx[]) => {
  if (a === b) return true;

  return sameSortedArrayItems(a, b, txEquals);
};

export const txInEquals = (a: Cardano.TxIn, b: Cardano.TxIn) => a.txId === b.txId && a.index === b.index;

export const utxoEquals = (a: Cardano.Utxo[], b: Cardano.Utxo[]) => {
  if (a === b) return true;

  return sameSortedArrayItems(a, b, ([aTxIn], [bTxIn]) => txInEquals(aTxIn, bTxIn));
};

export const eraSummariesEquals = (a: EraSummary[], b: EraSummary[]) =>
  sameArrayItems(a, b, (es1, es2) => es1.start.slot === es2.start.slot);

const groupedAddressEquals = (a: GroupedAddress, b: GroupedAddress) => a.address === b.address;

export const groupedAddressesEquals = (a: GroupedAddress[], b: GroupedAddress[]) =>
  sameArrayItems(a, b, groupedAddressEquals);

export const epochInfoEquals = (a: EpochInfo, b: EpochInfo) => a.epochNo === b.epochNo;

export const delegatedStakeEquals = (a: DelegatedStake, b: DelegatedStake) =>
  a.pool.id === b.pool.id && a.stake === b.stake && a.percentage === b.percentage;

const signedTxEquals = (a: WitnessedTx, b: WitnessedTx) => a.tx.id === b.tx.id;

export const signedTxsEquals = (a: WitnessedTx[], b: WitnessedTx[]) => sameArrayItems(a, b, signedTxEquals);
