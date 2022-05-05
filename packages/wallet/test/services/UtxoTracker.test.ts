import { Cardano, UtxoProvider } from '@cardano-sdk/core';
import { InMemoryUtxoStore } from '../../src/persistence';
import { Observable } from 'rxjs';
import { PersistentCollectionTrackerSubject, createUtxoTracker } from '../../src/services';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { utxo } from '../mocks';

describe('createUtxoTracker', () => {
  // these variables are not relevant for this test, overwriting rewardsSource$
  let retryBackoffConfig: RetryBackoffConfig;
  let tipBlockHeight$: Observable<number>;
  let utxoProvider: UtxoProvider;

  it('fetches utxo from WalletProvider and locks when spent in a transaction in flight', () => {
    const store = new InMemoryUtxoStore();
    const address = utxo[0][0].address;
    createTestScheduler().run(({ cold, expectObservable }) => {
      const transactionsInFlight$ = cold('-a-b|', {
        a: [],
        b: [
          {
            body: {
              inputs: [utxo[0][0]]
            }
          } as unknown as Cardano.NewTxAlonzo
        ]
      });
      const utxoTracker = createUtxoTracker(
        {
          addresses$: cold('a', { a: [address!] }),
          retryBackoffConfig,
          stores: {
            unspendableUtxo: store,
            utxo: store
          },
          tipBlockHeight$,
          transactionsInFlight$,
          utxoProvider
        },
        {
          unspendableUtxoSource$: new PersistentCollectionTrackerSubject<Cardano.Utxo>(
            () =>
              cold('a---|', {
                a: []
              }),
            store
          ),
          utxoSource$: cold('a---|', { a: utxo }) as unknown as PersistentCollectionTrackerSubject<Cardano.Utxo>
        }
      );
      expectObservable(utxoTracker.total$).toBe('a---|', { a: utxo });
      expectObservable(utxoTracker.unspendable$).toBe('a---|', { a: [] });
      expectObservable(utxoTracker.available$).toBe('-a-b|', {
        a: utxo,
        b: utxo.slice(1)
      });
    });
  });

  it('fetches utxo from WalletProvider and locks unspendable ones', () => {
    const store = new InMemoryUtxoStore();
    const address = utxo[0][0].address;
    createTestScheduler().run(({ cold, expectObservable }) => {
      const transactionsInFlight$ = cold('-a--|', { a: [] });
      const utxoTracker = createUtxoTracker(
        {
          addresses$: cold('a', { a: [address!] }),
          retryBackoffConfig,
          stores: {
            unspendableUtxo: store,
            utxo: store
          },
          tipBlockHeight$,
          transactionsInFlight$,
          utxoProvider
        },
        {
          unspendableUtxoSource$: new PersistentCollectionTrackerSubject<Cardano.Utxo>(
            () =>
              cold('-a-b|', {
                a: [],
                b: [utxo[0]]
              }),
            store
          ),
          utxoSource$: cold('a---|', { a: utxo }) as unknown as PersistentCollectionTrackerSubject<Cardano.Utxo>
        }
      );
      expectObservable(utxoTracker.total$).toBe('a---|', { a: utxo });
      expectObservable(utxoTracker.unspendable$).toBe('-a-b|', { a: [], b: [utxo[0]] });
      expectObservable(utxoTracker.available$).toBe('-a-b|', {
        a: utxo,
        b: utxo.slice(1)
      });
    });
  });

  it('sets unspendable utxos and locks them', () => {
    const store = new InMemoryUtxoStore();
    const address = utxo[0][0].address;
    createTestScheduler().run(({ cold, expectObservable }) => {
      const transactionsInFlight$ = cold('-a--|', { a: [] });
      const utxoTracker = createUtxoTracker(
        {
          addresses$: cold('a', { a: [address!] }),
          retryBackoffConfig,
          stores: {
            unspendableUtxo: store,
            utxo: store
          },
          tipBlockHeight$,
          transactionsInFlight$,
          utxoProvider
        },
        {
          utxoSource$: cold('a---|', { a: utxo }) as unknown as PersistentCollectionTrackerSubject<Cardano.Utxo>
        }
      );
      utxoTracker.setUnspendable(utxo.slice(1));

      expectObservable(utxoTracker.total$).toBe('a---|', { a: utxo });
      expectObservable(utxoTracker.unspendable$).toBe('a', { a: utxo.slice(1) });
      expectObservable(utxoTracker.available$).toBe('-a', { a: [utxo[0]] });
    });
  });
});
