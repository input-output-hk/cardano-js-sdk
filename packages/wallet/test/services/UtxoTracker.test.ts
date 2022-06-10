import { Cardano, UtxoProvider } from '@cardano-sdk/core';
import { InMemoryUtxoStore } from '../../src/persistence';
import { Observable } from 'rxjs';
import { PersistentCollectionTrackerSubject, createUtxoTracker } from '../../src/services';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { utxo } from '../mocks';

describe('createUtxoTracker', () => {
  // these variables are not relevant for this test, overwriting utxoSource$
  let retryBackoffConfig: RetryBackoffConfig;
  let tipBlockHeight$: Observable<number>;
  let utxoProvider: UtxoProvider;

  it('fetches utxo from WalletProvider and includes change from a transaction in flight', () => {
    const store = new InMemoryUtxoStore();
    const ownAddress = utxo[0][1].address;
    const spendAddress = utxo[1][0].address;
    const spendUtxo = utxo[0];
    const spendTotalCoins = spendUtxo[1].value.coins;
    const spendCoins = spendTotalCoins / 2n;
    const spendOutput: Cardano.TxOut = {
      address: spendAddress,
      value: {
        coins: spendCoins
      }
    };
    const changeOutput: Cardano.TxOut = {
      address: ownAddress,
      value: {
        coins: spendTotalCoins - spendCoins
      }
    };
    const transactionId = Cardano.TransactionId('4123d70f66414cc921f6ffc29a899aafc7137a99a0fd453d6b200863ef5702d6');
    const outputs = [spendOutput, changeOutput];
    createTestScheduler().run(({ cold, expectObservable }) => {
      const transactionsInFlight$ = cold('-a-b|', {
        a: [],
        b: [
          {
            body: {
              inputs: [spendUtxo[0]],
              outputs
            },
            id: transactionId
          } as unknown as Cardano.NewTxAlonzo
        ]
      });
      const utxoTracker = createUtxoTracker(
        {
          addresses$: cold('a|', { a: [ownAddress!] }),
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
      const utxoWithTxInFlight = [
        ...utxo.slice(1),
        [
          { address: ownAddress, index: outputs.indexOf(changeOutput), txId: transactionId },
          changeOutput
        ] as Cardano.Utxo
      ];
      expectObservable(utxoTracker.total$).toBe('-a-b|', { a: utxo, b: utxoWithTxInFlight });
      expectObservable(utxoTracker.unspendable$).toBe('a---|', { a: [] });
      expectObservable(utxoTracker.available$).toBe('-a-b|', {
        a: utxo,
        b: utxoWithTxInFlight
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
          addresses$: cold('a|', { a: [address!] }),
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
      expectObservable(utxoTracker.total$).toBe('-a--|', { a: utxo });
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
          addresses$: cold('a|', { a: [address!] }),
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

      expectObservable(utxoTracker.total$).toBe('-a--|', { a: utxo });
      expectObservable(utxoTracker.unspendable$).toBe('a', { a: utxo.slice(1) });
      expectObservable(utxoTracker.available$).toBe('-a', { a: [utxo[0]] });
    });
  });
});
