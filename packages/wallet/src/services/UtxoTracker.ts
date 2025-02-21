import { Cardano, UtxoProvider } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { NEVER, Observable, combineLatest, concat, distinctUntilChanged, map, of, shareReplay, switchMap } from 'rxjs';
import { PersistentCollectionTrackerSubject, pollProvider, txInEquals, utxoEquals } from './util';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TxInFlight, UtxoTracker } from './types';
import { WalletStores } from '../persistence';
import { sortUtxoByTxIn } from '@cardano-sdk/input-selection';
import chunk from 'lodash/chunk.js';
import uniqWith from 'lodash/uniqWith.js';

// Temporarily hardcoded. Will be replaced with ChainHistoryProvider 'maxPageSize' value once ADP-2249 is implemented
const PAGE_SIZE = 25;

export interface UtxoTrackerProps {
  utxoProvider: UtxoProvider;
  addresses$: Observable<Cardano.PaymentAddress[]>;
  stores: Pick<WalletStores, 'utxo' | 'unspendableUtxo'>;
  transactionsInFlight$: Observable<TxInFlight[]>;
  history$: Observable<Cardano.HydratedTx[]>;
  retryBackoffConfig: RetryBackoffConfig;
  logger: Logger;
}

export interface UtxoTrackerInternals {
  utxoSource$?: PersistentCollectionTrackerSubject<Cardano.Utxo>;
  unspendableUtxoSource$?: PersistentCollectionTrackerSubject<Cardano.Utxo>;
}

export const createUtxoProvider = (
  utxoProvider: UtxoProvider,
  addresses$: Observable<Cardano.PaymentAddress[]>,
  history$: Observable<Cardano.HydratedTx[]>,
  retryBackoffConfig: RetryBackoffConfig,
  logger: Logger
) =>
  addresses$.pipe(
    switchMap((paymentAddresses) =>
      pollProvider({
        equals: utxoEquals,
        logger,
        retryBackoffConfig,
        sample: async () => {
          let utxos = new Array<Cardano.Utxo>();

          const addressesSubGroups = chunk(paymentAddresses, PAGE_SIZE);

          for (const addresses of addressesSubGroups) {
            utxos = [...utxos, ...(await utxoProvider.utxoByAddresses({ addresses }))];
          }

          return utxos.sort(sortUtxoByTxIn);
        },
        trigger$: history$
      })
    )
  );

export const createUtxoTracker = (
  { utxoProvider, addresses$, stores, transactionsInFlight$, retryBackoffConfig, history$, logger }: UtxoTrackerProps,
  {
    utxoSource$ = new PersistentCollectionTrackerSubject<Cardano.Utxo>(
      () => createUtxoProvider(utxoProvider, addresses$, history$, retryBackoffConfig, logger),
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
    ]),
    map((utxo) => {
      const uniqueUtxo = uniqWith(utxo, ([a], [b]) => a.txId === b.txId && a.index === b.index);
      if (uniqueUtxo.length !== utxo.length) {
        logger.debug('Found duplicate UTxO in', utxo);
      }
      return uniqueUtxo;
    }),
    distinctUntilChanged((previous, current) => utxoEquals(previous, current)),
    shareReplay(1)
  );
  const available$ = combineLatest([total$, unspendableUtxoSource$]).pipe(
    // filter to utxo that are not included in in-flight transactions or unspendable
    map(([utxo, unspendableUtxo]) =>
      utxo.filter(([utxoTxIn]) => {
        const txInIsUnspendable = unspendableUtxo.some(([unspendable]) => txInEquals(utxoTxIn, unspendable));
        txInIsUnspendable && logger.debug('Exclude unspendable UTXO from availble$', utxoTxIn);
        return !txInIsUnspendable;
      })
    ),
    distinctUntilChanged((previous, current) => utxoEquals(previous, current)),
    shareReplay(1)
  );

  return {
    available$,
    setUnspendable: async (utxo) => {
      logger.debug('setUnspendable', utxo);
      unspendableUtxoSource$.next(utxo);
    },
    shutdown: () => {
      utxoSource$.complete();
      unspendableUtxoSource$.complete();
      logger.debug('Shutdown');
    },
    total$,
    unspendable$: combineLatest([unspendableUtxoSource$, total$]).pipe(
      map(([unspendableUtxo, utxo]) =>
        unspendableUtxo.filter(([unspendable]) => utxo.some(([utxoTxIn]) => txInEquals(utxoTxIn, unspendable)))
      ),
      distinctUntilChanged((previous, current) => utxoEquals(previous, current)),
      shareReplay(1)
    )
  };
};
