import { Cardano, WalletProvider } from '@cardano-sdk/core';
import { CollectionStore } from '../persistence';
import { Observable, combineLatest, map, switchMap } from 'rxjs';
import { PersistentCollectionTrackerSubject, TrackerSubject, coldObservableProvider, utxoEquals } from './util';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TransactionalTracker } from './types';

export interface UtxoTrackerProps {
  walletProvider: WalletProvider;
  addresses$: Observable<Cardano.Address[]>;
  store: CollectionStore<Cardano.Utxo>;
  transactionsInFlight$: Observable<Cardano.NewTxAlonzo[]>;
  tipBlockHeight$: Observable<number>;
  retryBackoffConfig: RetryBackoffConfig;
}

export interface UtxoTrackerInternals {
  utxoSource$?: PersistentCollectionTrackerSubject<Cardano.Utxo>;
}

export const createUtxoProvider = (
  walletProvider: WalletProvider,
  addresses$: Observable<Cardano.Address[]>,
  tipBlockHeight$: Observable<number>,
  retryBackoffConfig: RetryBackoffConfig
) =>
  addresses$.pipe(
    switchMap((addresses) =>
      coldObservableProvider(
        () => walletProvider.utxoByAddresses(addresses),
        retryBackoffConfig,
        tipBlockHeight$,
        utxoEquals
      )
    )
  );

export const createUtxoTracker = (
  { walletProvider, addresses$, store, transactionsInFlight$, retryBackoffConfig, tipBlockHeight$ }: UtxoTrackerProps,
  {
    utxoSource$ = new PersistentCollectionTrackerSubject<Cardano.Utxo>(
      () => createUtxoProvider(walletProvider, addresses$, tipBlockHeight$, retryBackoffConfig),
      store
    )
  }: UtxoTrackerInternals = {}
): TransactionalTracker<Cardano.Utxo[]> => {
  const available$ = new TrackerSubject<Cardano.Utxo[]>(
    combineLatest([utxoSource$, transactionsInFlight$]).pipe(
      // filter to utxo that are not included in in-flight transactions
      map(([utxo, transactionsInFlight]) =>
        utxo.filter(
          ([utxoTxIn]) =>
            !transactionsInFlight.some(({ body: { inputs } }) =>
              inputs.some((input) => input.txId === utxoTxIn.txId && input.index === utxoTxIn.index)
            )
        )
      )
    )
  );
  return {
    available$,
    shutdown: () => {
      utxoSource$.complete();
      available$.complete();
    },
    total$: utxoSource$
  };
};
