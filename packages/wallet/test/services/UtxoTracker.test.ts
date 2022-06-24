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

  it(`fetches utxo from UtxoProvider;
      includes change from a transaction in flight;
      deeply chained transactions consumes chainable utxo`, () => {
    const store = new InMemoryUtxoStore();
    const ownAddress = utxo[0][1].address;
    const spendAddress = utxo[1][0].address;
    const spendUtxo = utxo[0];
    const spendTotalCoins = spendUtxo[1].value.coins;
    const spendCoins = spendTotalCoins / 2n;
    const tx1SpendOutput: Cardano.TxOut = {
      address: spendAddress,
      value: {
        coins: spendCoins
      }
    };
    const tx1ChangeOutput: Cardano.TxOut = {
      address: ownAddress,
      value: {
        coins: spendTotalCoins - spendCoins
      }
    };
    const transactionId1 = Cardano.TransactionId('4123d70f66414cc921f6ffc29a899aafc7137a99a0fd453d6b200863ef5702d6');
    const transactionId2 = Cardano.TransactionId('4123d70f66414cc921f6ffc29a899aafc7137a99a0fd453d6b200863ef5702d7');
    const tx1Outputs = [tx1SpendOutput, tx1ChangeOutput];
    const tx2Output = {
      address: ownAddress,
      value: tx1ChangeOutput.value
    };
    const tx2Outputs = [tx2Output];
    createTestScheduler().run(({ cold, expectObservable }) => {
      const inFlightTx1 = {
        body: {
          inputs: [spendUtxo[0]],
          outputs: tx1Outputs
        },
        id: transactionId1
      } as unknown as Cardano.NewTxAlonzo;
      const chainableUtxoFromTx1 = [
        { address: ownAddress, index: tx1Outputs.indexOf(tx1ChangeOutput), txId: transactionId1 },
        tx1ChangeOutput
      ] as Cardano.Utxo;
      const chainableUtxoFromTx2 = [
        { address: ownAddress, index: tx2Outputs.indexOf(tx2Output), txId: transactionId2 },
        tx2Output
      ] as Cardano.Utxo;
      const inFlightTx2 = {
        body: {
          inputs: [chainableUtxoFromTx1[0]],
          outputs: tx2Outputs
        },
        id: transactionId2
      } as unknown as Cardano.NewTxAlonzo;
      const transactionsInFlight$ = cold('-a-b-c|', {
        a: [],
        b: [inFlightTx1],
        c: [inFlightTx1, inFlightTx2]
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
      const utxoWithTx1InFlight = [...utxo.slice(1), chainableUtxoFromTx1];
      const utxoWithTx2InFlight = [...utxo.slice(1), chainableUtxoFromTx2];
      expectObservable(utxoTracker.total$).toBe('-a-b-c|', { a: utxo, b: utxoWithTx1InFlight, c: utxoWithTx2InFlight });
      expectObservable(utxoTracker.unspendable$).toBe('a---|', { a: [] });
      expectObservable(utxoTracker.available$).toBe('-a-b-c|', {
        a: utxo,
        b: utxoWithTx1InFlight,
        c: utxoWithTx2InFlight
      });
    });
  });

  it('fetches utxo from UtxoProvider and locks unspendable ones', () => {
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
