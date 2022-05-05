/* eslint-disable max-len */
/* eslint-disable prettier/prettier */
/* eslint-disable no-multi-spaces */
/* eslint-disable space-in-parens */
import { BehaviorObservable, DelegationTracker, RewardAccount, StakeKeyStatus, createBalanceTracker } from '../../src/services';
import { Cardano, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
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
        b: [{ keyStatus: StakeKeyStatus.Registered, rewardBalance: { available: 0n, total: 0n } }],
        c: [{ keyStatus: StakeKeyStatus.Registered, rewardBalance: { available: 5n, total: 10n } }],
        d: [{ keyStatus: StakeKeyStatus.Unregistering, rewardBalance: { available: 5n, total: 10n } }]
      }) as unknown as BehaviorObservable<RewardAccount[]>;
      const balanceTracker = createBalanceTracker(
        protocolParameters$,
        { available$: utxoAvailable, total$: utxoTotal, unspendable$: utxoUnspendable },
        { rewardAccounts$ } as unknown as DelegationTracker
      );
      expectObservable(balanceTracker.total$).toBe('-a-b-c', {
        a: { ...Cardano.util.coalesceValueQuantities(utxo.map((u) => u[1].value)), deposit: 0n, rewards: 0n },
        b: { ...Cardano.util.coalesceValueQuantities(utxo.map((u) => u[1].value)), deposit: 2n, rewards: 0n },
        c: { ...Cardano.util.coalesceValueQuantities(utxo.map((u) => u[1].value)), deposit: 2n, rewards: 10n }
      });
      expectObservable(balanceTracker.available$).toBe('--abcde', {
        a: { ...Cardano.util.coalesceValueQuantities(utxo.map((u) => u[1].value)), deposit: 0n, rewards: 0n },
        b: { ...Cardano.util.coalesceValueQuantities(utxo.map((u) => u[1].value)), deposit: 2n, rewards: 0n },
        c: { ...Cardano.util.coalesceValueQuantities(utxo.slice(1).map((u) => u[1].value)), deposit: 2n, rewards: 0n },
        d: { ...Cardano.util.coalesceValueQuantities(utxo.slice(1).map((u) => u[1].value)), deposit: 2n, rewards: 5n },
        e: { ...Cardano.util.coalesceValueQuantities(utxo.slice(1).map((u) => u[1].value)), deposit: 0n, rewards: 5n }
      });
      expectObservable(balanceTracker.unspendable$).toBe('-a------', {
        a: { ...Cardano.util.coalesceValueQuantities(utxo2.map((u) => u[1].value)), deposit: 0n, rewards: 0n }
      });
    });
  });
});
