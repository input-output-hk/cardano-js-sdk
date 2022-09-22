/* eslint-disable max-len */
/* eslint-disable prettier/prettier */
/* eslint-disable no-multi-spaces */
/* eslint-disable space-in-parens */
import { BehaviorObservable } from '@cardano-sdk/util-rxjs';
import { Cardano, ProtocolParametersRequiredByWallet, coalesceValueQuantities } from '@cardano-sdk/core';
import { DelegationTracker, RewardAccount, StakeKeyStatus, createBalanceTracker } from '../../src/services';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { utxo, utxo2 } from '../mocks';

describe('createBalanceTracker', () => {
  it('combines data from rewardsTracker & utxoTracker', () => {
    createTestScheduler().run(({ hot, expectObservable }) => {
      const protocolParameters$ = hot( 'a------', { a: { stakeKeyDeposit: 2 } as ProtocolParametersRequiredByWallet });
      const utxoAvailable = hot(       '--a-b--', { a: utxo, b: utxo.slice(1) }) as unknown as BehaviorObservable<Cardano.Utxo[]>;
      const utxoTotal = hot(           '-a-----', { a: utxo }) as unknown as BehaviorObservable<Cardano.Utxo[]>;
      const utxoUnspendable = hot(     '-a-----', { a: utxo2 }) as unknown as BehaviorObservable<Cardano.Utxo[]>;
      const rewardAccounts$ = hot(     'a--b-cd', {
        a: [],
        b: [{ keyStatus: StakeKeyStatus.Registering, rewardBalance: 0n }],
        c: [{ keyStatus: StakeKeyStatus.Registered, rewardBalance: 5n }],
        d: [{ keyStatus: StakeKeyStatus.Unregistering, rewardBalance: 5n }]
      }) as unknown as BehaviorObservable<RewardAccount[]>;
      const balanceTracker = createBalanceTracker(
        protocolParameters$,
        { available$: utxoAvailable, total$: utxoTotal, unspendable$: utxoUnspendable },
        { rewardAccounts$ } as unknown as DelegationTracker
      );
      expectObservable(balanceTracker.rewardAccounts.deposit$).toBe('a--b--d', {
        a: 0n,
        b: 2n,
        d: 0n
      });
      expectObservable(balanceTracker.rewardAccounts.rewards$).toBe('a----c-', {
        a: 0n,
        c: 5n
      });
      expectObservable(balanceTracker.utxo.total$).toBe('-a-----', {
        a: coalesceValueQuantities(utxo.map((u) => u[1].value))
      });
      expectObservable(balanceTracker.utxo.available$).toBe('--a-b--', {
        a: coalesceValueQuantities(utxo.map((u) => u[1].value)),
        b: coalesceValueQuantities(utxo.slice(1).map((u) => u[1].value))
      });
      expectObservable(balanceTracker.utxo.unspendable$).toBe('-a-----', {
        a: coalesceValueQuantities(utxo2.map((u) => u[1].value))
      });
    });
  });
});
