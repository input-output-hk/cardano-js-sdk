import { Cardano } from '@cardano-sdk/core';
import { InMemoryUtxoStore } from '../../src/persistence/index.js';
import { PersistentCollectionTrackerSubject, createUtxoTracker } from '../../src/services/index.js';
import { createTestScheduler, mockProviders } from '@cardano-sdk/util-dev';
import { dummyCbor } from '../util.js';
import { dummyLogger } from 'ts-log';
import type { Observable } from 'rxjs';
import type { RetryBackoffConfig } from 'backoff-rxjs';
import type { TxInFlight } from '../../src/services/index.js';
import type { UtxoProvider } from '@cardano-sdk/core';

const { utxo, utxo2 } = mockProviders;

const createStubOutputs = (numOutputs: number) =>
  Array.from({ length: numOutputs }).map(
    (): Cardano.TxOut => ({
      address: Cardano.PaymentAddress('addr1vy36kffjf87vzkuyqc5g0ys3fe3pez5zvqg9r5z9q9kfrkg2cs093'),
      value: { coins: 123n }
    })
  );

describe('createUtxoTracker', () => {
  // these variables are not relevant for this test, overwriting utxoSource$
  let retryBackoffConfig: RetryBackoffConfig;
  let tipBlockHeight$: Observable<Cardano.BlockNo>;
  let utxoProvider: UtxoProvider;
  const logger = dummyLogger;

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
      const inFlightTx1: TxInFlight = {
        body: {
          inputs: [spendUtxo[0] as Cardano.TxIn],
          outputs: tx1Outputs
        } as Cardano.TxBody,
        cbor: dummyCbor,
        id: transactionId1
      };
      const chainableUtxoFromTx1 = [
        { address: ownAddress, index: tx1Outputs.indexOf(tx1ChangeOutput), txId: transactionId1 },
        tx1ChangeOutput
      ] as Cardano.Utxo;
      const chainableUtxoFromTx2 = [
        { address: ownAddress, index: tx2Outputs.indexOf(tx2Output), txId: transactionId2 },
        tx2Output
      ] as Cardano.Utxo;
      const inFlightTx2: TxInFlight = {
        body: {
          inputs: [chainableUtxoFromTx1[0] as Cardano.TxIn],
          outputs: tx2Outputs
        } as Cardano.TxBody,
        cbor: dummyCbor,
        id: transactionId2
      };

      const transactionsInFlight$ = cold<TxInFlight[]>('-a-b-c|', {
        a: [],
        b: [inFlightTx1],
        c: [inFlightTx1, inFlightTx2]
      });

      const utxoTracker = createUtxoTracker(
        {
          addresses$: cold('a|', { a: [ownAddress!] }),
          logger,
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
      expectObservable(utxoTracker.unspendable$).toBe('-a----|', { a: [] });
      expectObservable(utxoTracker.available$).toBe('-a-b-c|', {
        a: utxo,
        b: utxoWithTx1InFlight,
        c: utxoWithTx2InFlight
      });
    });
  });

  it('filters out duplicate utxo', () => {
    const store = new InMemoryUtxoStore();
    const address = utxo[0][0].address;
    createTestScheduler().run(({ cold, expectObservable }) => {
      const duplicateUtxo = utxo.find(([txOut]) => txOut.address === address)!;
      const transactionsInFlight$ = cold('a', {
        a: [
          {
            body: {
              inputs: [] as Cardano.TxIn[],
              // this output already exists in utxoSource$ emission
              outputs: [...createStubOutputs(duplicateUtxo[0].index), duplicateUtxo[1]]
            } as Cardano.TxBody,
            cbor: dummyCbor,
            id: duplicateUtxo[0].txId
          } as TxInFlight
        ]
      });
      const utxoTracker = createUtxoTracker(
        {
          addresses$: cold('a', { a: [address!] }),
          logger,
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
            () => cold('a', { a: [] }),
            store
          ),
          utxoSource$: cold('a', { a: utxo }) as unknown as PersistentCollectionTrackerSubject<Cardano.Utxo>
        }
      );
      expectObservable(utxoTracker.total$).toBe('a', { a: utxo });
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
          logger,
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

  it('sets unspendable utxos and locks them', async () => {
    const store = new InMemoryUtxoStore();
    const address = utxo[0][0].address;
    await createTestScheduler().run(async ({ cold, expectObservable }) => {
      const transactionsInFlight$ = cold('-a--|', { a: [] });
      const utxoTracker = createUtxoTracker(
        {
          addresses$: cold('a|', { a: [address!] }),
          logger,
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
      await utxoTracker.setUnspendable(utxo.slice(1));

      expectObservable(utxoTracker.total$).toBe('-a--|', { a: utxo });
      expectObservable(utxoTracker.unspendable$).toBe('a', { a: utxo.slice(1) });
      expectObservable(utxoTracker.available$).toBe('-a', { a: [utxo[0]] });
    });
  });

  it('unsets unspendable utxos if they are no longer present in wallet utxo set', () => {
    const store = new InMemoryUtxoStore();
    const address = utxo[0][0].address;
    createTestScheduler().run(({ cold, expectObservable }) => {
      const transactionsInFlight$ = cold('-a--|', { a: [] });
      const utxoTracker = createUtxoTracker(
        {
          addresses$: cold('a|', { a: [address!] }),
          logger,
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
              cold('a|', {
                a: [utxo[0]]
              }),
            store
          ),
          utxoSource$: cold('a---b---|', {
            a: utxo,
            b: utxo2
          }) as unknown as PersistentCollectionTrackerSubject<Cardano.Utxo>
        }
      );
      expectObservable(utxoTracker.total$).toBe('-a--b---|', { a: utxo, b: utxo2 });
      expectObservable(utxoTracker.unspendable$).toBe('-a--b---|', { a: [utxo[0]], b: [] });
      expectObservable(utxoTracker.available$).toBe('-a--b---|', {
        a: utxo2,
        b: utxo2
      });
    });
  });
});
