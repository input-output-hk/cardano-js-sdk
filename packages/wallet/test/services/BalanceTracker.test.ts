/* eslint-disable max-len */
/* eslint-disable prettier/prettier */
/* eslint-disable no-multi-spaces */
/* eslint-disable space-in-parens */
import { BehaviorObservable, Delegation, DelegationKeyStatus, RewardAccount, createBalanceTracker } from '../../src/services';
import { Cardano, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { coalesceValueQuantities } from '@cardano-sdk/core/src/Cardano/util';
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
        b: [{ keyStatus: DelegationKeyStatus.Registered } as RewardAccount],
        c: [{ keyStatus: DelegationKeyStatus.Registered } as RewardAccount, { keyStatus: DelegationKeyStatus.Unregistering }] }) as unknown as BehaviorObservable<RewardAccount[]>;
      const balanceTracker = createBalanceTracker(
        protocolParameters$,
        { available$: utxoAvailable, total$: utxoTotal },
        { available$: rewardsAvailable, total$: rewardsTotal },
        { rewardAccounts$ } as Delegation
      );
      expectObservable(balanceTracker.total$).toBe('-a--bc-', {
        a: { ...coalesceValueQuantities(utxo.map((u) => u[1].value)), deposit: 0n, rewards: 10n },
        b: { ...coalesceValueQuantities(utxo.map((u) => u[1].value)), deposit: 0n, rewards: 20n },
        c: { ...coalesceValueQuantities(utxo.map((u) => u[1].value)), deposit: 2n, rewards: 20n }
      });
      expectObservable(balanceTracker.available$).toBe('--abcde', {
        a: { ...coalesceValueQuantities(utxo.map((u) => u[1].value)), deposit: 0n, rewards: 10n },
        b: { ...coalesceValueQuantities(utxo.map((u) => u[1].value)), deposit: 0n, rewards: 5n },
        c: { ...coalesceValueQuantities(utxo.slice(1).map((u) => u[1].value)), deposit: 0n, rewards: 5n },
        d: { ...coalesceValueQuantities(utxo.slice(1).map((u) => u[1].value)), deposit: 2n, rewards: 5n },
        e: { ...coalesceValueQuantities(utxo.slice(1).map((u) => u[1].value)), deposit: 0n, rewards: 5n }
      });
    });
  });
});
