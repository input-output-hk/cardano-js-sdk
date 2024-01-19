import { Cardano, EpochInfo, EraSummary } from '@cardano-sdk/core';
import { DelegatedStake } from '../types';
import { GroupedAddress } from '@cardano-sdk/key-management';
import { sameArrayItems } from '@cardano-sdk/util';

export const tipEquals = (a: Cardano.Tip, b: Cardano.Tip) => a.hash === b.hash;

export const txEquals = <T extends Pick<Cardano.HydratedTx, 'id'> = Cardano.HydratedTx>(a: T, b: T) => a.id === b.id;

export const transactionsEquals = <T extends Pick<Cardano.HydratedTx, 'id'> = Cardano.HydratedTx>(a: T[], b: T[]) =>
  sameArrayItems(a, b, txEquals);

export const txInEquals = (a: Cardano.TxIn, b: Cardano.TxIn) => a.txId === b.txId && a.index === b.index;

export const utxoEquals = (a: Cardano.Utxo[], b: Cardano.Utxo[]) =>
  sameArrayItems(a, b, ([aTxIn], [bTxIn]) => txInEquals(aTxIn, bTxIn));

export const eraSummariesEquals = (a: EraSummary[], b: EraSummary[]) =>
  sameArrayItems(a, b, (es1, es2) => es1.start.slot === es2.start.slot);

const groupedAddressEquals = (a: GroupedAddress, b: GroupedAddress) => a.address === b.address;

export const groupedAddressesEquals = (a: GroupedAddress[], b: GroupedAddress[]) =>
  sameArrayItems(a, b, groupedAddressEquals);

export const epochInfoEquals = (a: EpochInfo, b: EpochInfo) => a.epochNo === b.epochNo;

export const delegatedStakeEquals = (a: DelegatedStake, b: DelegatedStake) =>
  a.pool.id === b.pool.id && a.stake === b.stake && a.percentage === b.percentage;
