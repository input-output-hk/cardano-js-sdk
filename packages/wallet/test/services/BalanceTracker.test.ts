/* eslint-disable max-len */
/* eslint-disable prettier/prettier */
/* eslint-disable no-multi-spaces */
/* eslint-disable space-in-parens */
import { BehaviorObservable, createBalanceTracker } from '../../src/services';
import { Cardano } from '@cardano-sdk/core';
import { coalesceValueQuantities } from '@cardano-sdk/core/src/Cardano/util';
import { createTestScheduler } from '../testScheduler';
import { utxo } from '../mocks';

describe('createBalanceTracker', () => {
  it('combines data from rewardsTracker & utxoTracker', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const utxoAvailable = cold(   '--a-b-', { a: utxo, b: utxo.slice(1) }) as unknown as BehaviorObservable<Cardano.Utxo[]>;
      const rewardsAvailable = cold('-a-b--', { a: 10n, b: 5n }) as unknown as BehaviorObservable<Cardano.Lovelace>;
      const rewardsTotal = cold(    'a---b-', { a: 10n, b: 20n }) as unknown as BehaviorObservable<Cardano.Lovelace>;
      const utxoTotal = cold(       '-a----', { a: utxo }) as unknown as BehaviorObservable<Cardano.Utxo[]>;
      const balanceTracker = createBalanceTracker(
        { available$: utxoAvailable, total$: utxoTotal },
        { available$: rewardsAvailable, total$: rewardsTotal }
      );
      expectObservable(balanceTracker.total$).toBe('-a--b-', {
        a: { ...coalesceValueQuantities(utxo.map((u) => u[1].value)), rewards: 10n },
        b: { ...coalesceValueQuantities(utxo.map((u) => u[1].value)), rewards: 20n }
      });
      expectObservable(balanceTracker.available$).toBe('--abc-', {
        a: { ...coalesceValueQuantities(utxo.map((u) => u[1].value)), rewards: 10n },
        b: { ...coalesceValueQuantities(utxo.map((u) => u[1].value)), rewards: 5n },
        c: { ...coalesceValueQuantities(utxo.slice(1).map((u) => u[1].value)), rewards: 5n }
      });
    });
  });
});
