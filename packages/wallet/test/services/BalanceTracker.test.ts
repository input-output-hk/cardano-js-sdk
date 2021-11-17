/* eslint-disable max-len */
/* eslint-disable prettier/prettier */
/* eslint-disable no-multi-spaces */
/* eslint-disable space-in-parens */
import { BehaviorObservable, DelegationTracker, RewardAccount, StakeKeyStatus, createBalanceTracker } from '../../src/services';
import { Cardano, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { createTestScheduler } from '../testScheduler';
import { utxo } from '../mocks';

describe('createBalanceTracker', () => {
  it('combines data from rewardsTracker & utxoTracker', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const protocolParameters$ = cold( 'a------', { a: { stakeKeyDeposit: 2 } as ProtocolParametersRequiredByWallet });
      const utxoAvailable = cold(       '--a-b--', { a: utxo, b: utxo.slice(1) }) as unknown as BehaviorObservable<Cardano.Utxo[]>;
      const rewardsAvailable = cold(    '-a-b---', { a: 10n, b: 5n }) as unknown as BehaviorObservable<Cardano.Lovelace>;
      const rewardsTotal = cold(        'a---b--', { a: 10n, b: 20n }) as unknown as BehaviorObservable<Cardano.Lovelace>;
      const utxoTotal = cold(           '-a-----', { a: utxo }) as unknown as BehaviorObservable<Cardano.Utxo[]>;
      const rewardAccounts$ = cold(     'a----bc', {
        a: [],
        b: [{ keyStatus: StakeKeyStatus.Registered } as RewardAccount],
        c: [{ keyStatus: StakeKeyStatus.Registered } as RewardAccount, { keyStatus: StakeKeyStatus.Unregistering }] }) as unknown as BehaviorObservable<RewardAccount[]>;
      const balanceTracker = createBalanceTracker(
        protocolParameters$,
        { available$: utxoAvailable, total$: utxoTotal },
        { available$: rewardsAvailable, total$: rewardsTotal },
        { rewardAccounts$ } as unknown as DelegationTracker
      );
      expectObservable(balanceTracker.total$).toBe('-a--bc-', {
        a: { ...Cardano.util.coalesceValueQuantities(utxo.map((u) => u[1].value)), deposit: 0n, rewards: 10n },
        b: { ...Cardano.util.coalesceValueQuantities(utxo.map((u) => u[1].value)), deposit: 0n, rewards: 20n },
        c: { ...Cardano.util.coalesceValueQuantities(utxo.map((u) => u[1].value)), deposit: 2n, rewards: 20n }
      });
      expectObservable(balanceTracker.available$).toBe('--abcde', {
        a: { ...Cardano.util.coalesceValueQuantities(utxo.map((u) => u[1].value)), deposit: 0n, rewards: 10n },
        b: { ...Cardano.util.coalesceValueQuantities(utxo.map((u) => u[1].value)), deposit: 0n, rewards: 5n },
        c: { ...Cardano.util.coalesceValueQuantities(utxo.slice(1).map((u) => u[1].value)), deposit: 0n, rewards: 5n },
        d: { ...Cardano.util.coalesceValueQuantities(utxo.slice(1).map((u) => u[1].value)), deposit: 2n, rewards: 5n },
        e: { ...Cardano.util.coalesceValueQuantities(utxo.slice(1).map((u) => u[1].value)), deposit: 0n, rewards: 5n }
      });
    });
  });
});
