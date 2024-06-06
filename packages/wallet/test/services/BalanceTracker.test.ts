/* eslint-disable prettier/prettier */
/* eslint-disable no-multi-spaces */
/* eslint-disable space-in-parens */
import { Cardano, coalesceValueQuantities } from '@cardano-sdk/core';
import { createBalanceTracker, createUtxoBalanceByAddressTracker } from '../../src/services/index.js';
import { createTestScheduler, mockProviders } from '@cardano-sdk/util-dev';
import type { BehaviorObservable } from '@cardano-sdk/util-rxjs';
import type { DelegationTracker } from '../../src/services/index.js';

const { utxo, utxo2 } = mockProviders;

describe('createBalanceTracker', () => {
  it('combines data from rewardsTracker & utxoTracker', () => {
    createTestScheduler().run(({ hot, expectObservable }) => {
      const protocolParameters$ = hot( 'a------', { a: { stakeKeyDeposit: 2 } as Cardano.ProtocolParameters });
      const utxoAvailable = hot(       '--a-b--', { a: utxo, b: utxo.slice(1) }) as unknown as BehaviorObservable<Cardano.Utxo[]>;
      const utxoTotal = hot(           '-a-----', { a: utxo }) as unknown as BehaviorObservable<Cardano.Utxo[]>;
      const utxoUnspendable = hot(     '-a-----', { a: utxo2 }) as unknown as BehaviorObservable<Cardano.Utxo[]>;
      const rewardAccounts$ = hot(     'a--b-cd', {
        a: [],
        b: [{ credentialStatus: Cardano.StakeCredentialStatus.Registering, rewardBalance: 0n }],
        c: [{ credentialStatus: Cardano.StakeCredentialStatus.Registered, rewardBalance: 5n }],
        d: [{ credentialStatus: Cardano.StakeCredentialStatus.Unregistering, rewardBalance: 5n }]
      }) as unknown as BehaviorObservable<Cardano.RewardAccountInfo[]>;
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

  it('createUtxoBalanceByAddressTracker returns balance filtered by addresses', () => {
    const address = utxo[0][1].address;
    const address2 = Cardano.PaymentAddress('addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz');
    const utxoMultipleAddresses = utxo.slice(0, 3);

    // Change the first utxo address so it's filtered out
    utxoMultipleAddresses[0][1].address = address2;
    createTestScheduler().run(({ hot, expectObservable }) => {
      const available$ = hot(  'aa', { a: utxoMultipleAddresses }) as unknown as BehaviorObservable<Cardano.Utxo[]>;
      const total$ = hot(      'aa', { a: utxoMultipleAddresses }) as unknown as BehaviorObservable<Cardano.Utxo[]>;
      const unspendable$ = hot('aa', { a: utxoMultipleAddresses }) as unknown as BehaviorObservable<Cardano.Utxo[]>;

      const balanceByAddressTracker = createUtxoBalanceByAddressTracker(
        { available$, total$, unspendable$ },
        [address]
      );

      const balanceBy2AddressesTracker = createUtxoBalanceByAddressTracker(
        { available$, total$, unspendable$ },
        [address, address2]
      );

      const balanceNoFilterTracker = createUtxoBalanceByAddressTracker({ available$, total$, unspendable$ });


      // Check emitted values when filtering by one address
      const filteredUtxos = utxoMultipleAddresses.slice(1);
      expectObservable(balanceByAddressTracker!.utxo.total$).toBe('a', {
        a: coalesceValueQuantities(filteredUtxos.map((u) => u[1].value))
      });
      expectObservable(balanceByAddressTracker!.utxo.available$).toBe('a', {
        a: coalesceValueQuantities(filteredUtxos.map((u) => u[1].value))
      });
      expectObservable(balanceByAddressTracker!.utxo.unspendable$).toBe('a', {
        a: coalesceValueQuantities(filteredUtxos.map((u) => u[1].value))
      });

      // Check emitted values when there is no filtering, so all utxos are returned
      expectObservable(balanceNoFilterTracker!.utxo.total$).toBe('a', {
        a: coalesceValueQuantities(utxoMultipleAddresses.map((u) => u[1].value))
      });
      expectObservable(balanceNoFilterTracker!.utxo.available$).toBe('a', {
        a: coalesceValueQuantities(utxoMultipleAddresses.map((u) => u[1].value))
      });
      expectObservable(balanceNoFilterTracker!.utxo.unspendable$).toBe('a', {
        a: coalesceValueQuantities(utxoMultipleAddresses.map((u) => u[1].value))
      });

      // Check emitted values when there filtering by two addresses
      expectObservable(balanceBy2AddressesTracker!.utxo.total$).toBe('a', {
        a: coalesceValueQuantities(utxoMultipleAddresses.map((u) => u[1].value))
      });
      expectObservable(balanceBy2AddressesTracker!.utxo.available$).toBe('a', {
        a: coalesceValueQuantities(utxoMultipleAddresses.map((u) => u[1].value))
      });
      expectObservable(balanceBy2AddressesTracker!.utxo.unspendable$).toBe('a', {
        a: coalesceValueQuantities(utxoMultipleAddresses.map((u) => u[1].value))
      });
    });
  });
});
