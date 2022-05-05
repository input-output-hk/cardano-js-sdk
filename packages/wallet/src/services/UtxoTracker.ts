import { Cardano, UtxoProvider } from '@cardano-sdk/core';
import { NEVER, Observable, combineLatest, concat, map, of, switchMap } from 'rxjs';
import { PersistentCollectionTrackerSubject, TrackerSubject, coldObservableProvider, utxoEquals } from './util';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { UtxoTracker } from './types';
import { WalletStores } from '../persistence';

export interface UtxoTrackerProps {
  utxoProvider: UtxoProvider;
  addresses$: Observable<Cardano.Address[]>;
  stores: Pick<WalletStores, 'utxo' | 'unspendableUtxo'>;
  transactionsInFlight$: Observable<Cardano.NewTxAlonzo[]>;
  tipBlockHeight$: Observable<number>;
  retryBackoffConfig: RetryBackoffConfig;
}

export interface UtxoTrackerInternals {
  utxoSource$?: PersistentCollectionTrackerSubject<Cardano.Utxo>;
  unspendableUtxoSource$?: PersistentCollectionTrackerSubject<Cardano.Utxo>;
}

export const createUtxoProvider = (
  utxoProvider: UtxoProvider,
  addresses$: Observable<Cardano.Address[]>,
  tipBlockHeight$: Observable<number>,
  retryBackoffConfig: RetryBackoffConfig
) =>
  addresses$.pipe(
    switchMap((addresses) =>
      coldObservableProvider(
        () => utxoProvider.utxoByAddresses(addresses),
        retryBackoffConfig,
        tipBlockHeight$,
        utxoEquals
      )
    )
  );

export const createUtxoTracker = (
  { utxoProvider, addresses$, stores, transactionsInFlight$, retryBackoffConfig, tipBlockHeight$ }: UtxoTrackerProps,
  {
    utxoSource$ = new PersistentCollectionTrackerSubject<Cardano.Utxo>(
      () => createUtxoProvider(utxoProvider, addresses$, tipBlockHeight$, retryBackoffConfig),
      stores.utxo
    ),
    unspendableUtxoSource$ = new PersistentCollectionTrackerSubject(
      (stored) => (stored.length > 0 ? NEVER : concat(of([]), NEVER)),
      stores.unspendableUtxo
    )
  }: UtxoTrackerInternals = {}
): UtxoTracker => {
  const available$ = new TrackerSubject<Cardano.Utxo[]>(
    combineLatest([utxoSource$, transactionsInFlight$, unspendableUtxoSource$]).pipe(
      // filter to utxo that are not included in in-flight transactions or unspendable
      map(([utxo, transactionsInFlight, unspendableUtxo]) =>
        utxo.filter(
          ([utxoTxIn]) =>
            !transactionsInFlight.some(({ body: { inputs } }) =>
              inputs.some((input) => input.txId === utxoTxIn.txId && input.index === utxoTxIn.index)
            ) &&
            !unspendableUtxo.some(
              ([unspendable]) => unspendable.txId === utxoTxIn.txId && unspendable.index === utxoTxIn.index
            )
        )
      )
    )
  );

  return {
    available$,
    setUnspendable: unspendableUtxoSource$.next.bind(unspendableUtxoSource$),
    shutdown: () => {
      utxoSource$.complete();
      available$.complete();
      unspendableUtxoSource$.complete();
    },
    total$: utxoSource$,
    unspendable$: unspendableUtxoSource$
  };
};
