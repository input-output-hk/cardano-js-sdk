import { Cardano, WalletProvider } from '@cardano-sdk/core';
import { InMemoryUtxoStore } from '../../src/persistence';
import { Observable } from 'rxjs';
import { PersistentCollectionTrackerSubject, createUtxoTracker } from '../../src/services';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { createTestScheduler } from '../testScheduler';
import { utxo } from '../mocks';

describe('createUtxoTracker', () => {
  // these variables are not relevant for this test, overwriting rewardsSource$
  let retryBackoffConfig: RetryBackoffConfig;
  let tipBlockHeight$: Observable<number>;
  let walletProvider: WalletProvider;

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
          store,
          tipBlockHeight$,
          transactionsInFlight$,
          walletProvider
        },
        { utxoSource$: cold('a---|', { a: utxo }) as unknown as PersistentCollectionTrackerSubject<Cardano.Utxo> }
      );
      expectObservable(utxoTracker.total$).toBe('a---|', { a: utxo });
      expectObservable(utxoTracker.available$).toBe('-a-b|', {
        a: utxo,
        b: utxo.slice(1)
      });
    });
  });
});
