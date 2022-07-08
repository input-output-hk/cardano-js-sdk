import { Cardano, UtxoProvider } from '@cardano-sdk/core';
import { NEVER, Observable, combineLatest, concat, map, of, switchMap } from 'rxjs';
import { PersistentCollectionTrackerSubject, coldObservableProvider, txInEquals, utxoEquals } from './util';
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
      coldObservableProvider({
        equals: utxoEquals,
        provider: () => utxoProvider.utxoByAddresses(addresses),
        retryBackoffConfig,
        trigger$: tipBlockHeight$
      })
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
  const total$ = combineLatest([utxoSource$, transactionsInFlight$, addresses$]).pipe(
    map(([onChainUtxo, transactionsInFlight, ownAddresses]) => [
      ...onChainUtxo.filter(
        ([utxoTxIn]) =>
          !transactionsInFlight.some(({ body: { inputs } }) =>
            inputs.some((input) => input.txId === utxoTxIn.txId && input.index === utxoTxIn.index)
          )
      ),
      ...transactionsInFlight.flatMap((tx, txInFlightIndex) =>
        tx.body.outputs
          .filter(
            ({ address }, outputIndex) =>
              ownAddresses.includes(address) &&
              // not already consumed by another tx in flight
              !transactionsInFlight.some(
                ({ body: { inputs } }, i) =>
                  txInFlightIndex !== i && inputs.some((txIn) => txIn.txId === tx.id && txIn.index === outputIndex)
              )
          )
          .map(
            (txOut): Cardano.Utxo => [
              {
                address: txOut.address, // not necessarily correct in multi-address wallet
                index: tx.body.outputs.indexOf(txOut),
                txId: tx.id
              },
              txOut
            ]
          )
      )
    ])
  );
  const available$ = combineLatest([total$, unspendableUtxoSource$]).pipe(
    // filter to utxo that are not included in in-flight transactions or unspendable
    map(([utxo, unspendableUtxo]) =>
      utxo.filter(([utxoTxIn]) => !unspendableUtxo.some(([unspendable]) => txInEquals(utxoTxIn, unspendable)))
    )
  );

  return {
    available$,
    setUnspendable: unspendableUtxoSource$.next.bind(unspendableUtxoSource$),
    shutdown: () => {
      utxoSource$.complete();
      unspendableUtxoSource$.complete();
    },
    total$,
    unspendable$: unspendableUtxoSource$
  };
};
