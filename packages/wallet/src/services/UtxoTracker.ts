import { Cardano, UtxoProvider } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { NEVER, Observable, combineLatest, concat, map, of, switchMap } from 'rxjs';
import { PersistentCollectionTrackerSubject, coldObservableProvider, txInEquals, utxoEquals } from './util';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TxInFlight, UtxoTracker } from './types';
import { WalletStores } from '../persistence';

export interface UtxoTrackerProps {
  utxoProvider: UtxoProvider;
  addresses$: Observable<Cardano.Address[]>;
  stores: Pick<WalletStores, 'utxo' | 'unspendableUtxo'>;
  transactionsInFlight$: Observable<TxInFlight[]>;
  tipBlockHeight$: Observable<Cardano.BlockNo>;
  retryBackoffConfig: RetryBackoffConfig;
  logger: Logger;
  onFatalError?: (value: unknown) => void;
}

export interface UtxoTrackerInternals {
  utxoSource$?: PersistentCollectionTrackerSubject<Cardano.Utxo>;
  unspendableUtxoSource$?: PersistentCollectionTrackerSubject<Cardano.Utxo>;
}

export const createUtxoProvider = (
  utxoProvider: UtxoProvider,
  addresses$: Observable<Cardano.Address[]>,
  tipBlockHeight$: Observable<Cardano.BlockNo>,
  retryBackoffConfig: RetryBackoffConfig,
  onFatalError?: (value: unknown) => void
) =>
  addresses$.pipe(
    switchMap((addresses) =>
      coldObservableProvider({
        equals: utxoEquals,
        onFatalError,
        provider: () => utxoProvider.utxoByAddresses({ addresses }),
        retryBackoffConfig,
        trigger$: tipBlockHeight$
      })
    )
  );

export const createUtxoTracker = (
  {
    utxoProvider,
    addresses$,
    stores,
    transactionsInFlight$,
    retryBackoffConfig,
    tipBlockHeight$,
    logger,
    onFatalError
  }: UtxoTrackerProps,
  {
    utxoSource$ = new PersistentCollectionTrackerSubject<Cardano.Utxo>(
      () => createUtxoProvider(utxoProvider, addresses$, tipBlockHeight$, retryBackoffConfig, onFatalError),
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
      ...onChainUtxo.filter(([utxoTxIn]) => {
        const utxoIsUsedInFlight = transactionsInFlight.some(({ body: { inputs } }) =>
          inputs.some((input) => input.txId === utxoTxIn.txId && input.index === utxoTxIn.index)
        );
        utxoIsUsedInFlight &&
          logger.debug('OnChain UTXO is already used in in-flight transaction. Excluding from total$.', utxoTxIn);
        return !utxoIsUsedInFlight;
      }),
      ...transactionsInFlight.flatMap(({ body: { outputs }, id }, txInFlightIndex) =>
        outputs
          .filter(
            ({ address }, outputIndex) =>
              ownAddresses.includes(address) &&
              // not already consumed by another tx in flight
              !transactionsInFlight.some(
                ({ body: { inputs } }, i) =>
                  txInFlightIndex !== i && inputs.some((txIn) => txIn.txId === id && txIn.index === outputIndex)
              )
          )
          .map((txOut): Cardano.Utxo => {
            const txIn: Cardano.HydratedTxIn = {
              address: txOut.address, // not necessarily correct in multi-address wallet
              index: outputs.indexOf(txOut),
              txId: id
            };
            logger.debug('New UTXO available from in-flight transactions. Including in total$.', txIn);
            return [txIn, txOut];
          })
      )
    ])
  );
  const available$ = combineLatest([total$, unspendableUtxoSource$]).pipe(
    // filter to utxo that are not included in in-flight transactions or unspendable
    map(([utxo, unspendableUtxo]) =>
      utxo.filter(([utxoTxIn]) => {
        const txInIsUnspendable = unspendableUtxo.some(([unspendable]) => txInEquals(utxoTxIn, unspendable));
        txInIsUnspendable && logger.debug('Exclude unspendable UTXO from availble$', utxoTxIn);
        return !txInIsUnspendable;
      })
    )
  );

  return {
    available$,
    setUnspendable: unspendableUtxoSource$.next.bind(unspendableUtxoSource$),
    shutdown: () => {
      utxoSource$.complete();
      unspendableUtxoSource$.complete();
      logger.debug('Shutdown');
    },
    total$,
    unspendable$: unspendableUtxoSource$
  };
};
