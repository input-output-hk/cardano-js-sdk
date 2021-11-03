import { Balance, TransactionalTracker } from './types';
import { Cardano } from '@cardano-sdk/core';
import { TrackerSubject } from './util';
import { combineLatest, map } from 'rxjs';

const mapToBalances = map<[Cardano.Utxo[], Cardano.Lovelace], Balance>(([utxo, rewards]) => ({
  ...Cardano.util.coalesceValueQuantities(utxo.map(([_, txOut]) => txOut.value)),
  rewards
}));

export const createBalanceTracker = (
  utxoTracker: TransactionalTracker<Cardano.Utxo[]>,
  rewardsTracker: TransactionalTracker<Cardano.Lovelace>
): TransactionalTracker<Balance> => {
  const available$ = new TrackerSubject<Balance>(
    combineLatest([utxoTracker.available$, rewardsTracker.available$]).pipe(mapToBalances)
  );
  const total$ = new TrackerSubject<Balance>(
    combineLatest([utxoTracker.total$, rewardsTracker.total$]).pipe(mapToBalances)
  );
  return {
    available$,
    total$
  };
};
