import { Balance, TransactionalTracker } from './types';
import { Cardano } from '@cardano-sdk/core';
import { TrackerSubject } from './util';
import { TransactionalObservables } from '..';
import { combineLatest, map } from 'rxjs';

// TODO: subtract deposit quantity from total utxo coin as it can't be spent
// Review: not sure how to represent this. Is it 'balance.available$'? 'balance.total$'? a new one?
// 'total' represents total value available to spend. Would be confusing if it includes deposit.
// 'available' represents value available to spend if it makes a transaction right now:
// would be confusing if it's never equal to total after stake registration
const mapToBalances = map<[Cardano.Utxo[], Cardano.Lovelace], Balance>(([utxo, rewards]) => ({
  ...Cardano.util.coalesceValueQuantities(utxo.map(([_, txOut]) => txOut.value)),
  rewards
}));

export const createBalanceTracker = (
  utxoTracker: TransactionalObservables<Cardano.Utxo[]>,
  rewardsTracker: TransactionalObservables<Cardano.Lovelace>
): TransactionalTracker<Balance> => {
  const available$ = new TrackerSubject<Balance>(
    combineLatest([utxoTracker.available$, rewardsTracker.available$]).pipe(mapToBalances)
  );
  const total$ = new TrackerSubject<Balance>(
    combineLatest([utxoTracker.total$, rewardsTracker.total$]).pipe(mapToBalances)
  );
  return {
    available$,
    shutdown() {
      available$.complete();
      total$.complete();
    },
    total$
  };
};
