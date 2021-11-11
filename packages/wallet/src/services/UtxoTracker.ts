import { Cardano, WalletProvider } from '@cardano-sdk/core';
import { Observable, combineLatest, map } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TrackerSubject, coldObservableProvider, utxoEquals } from './util';
import { TransactionalTracker } from './types';

export interface UtxoTrackerProps {
  walletProvider: WalletProvider;
  addresses: Cardano.Address[];
  transactionsInFlight$: Observable<Cardano.NewTxAlonzo[]>;
  tipBlockHeight$: Observable<number>;
  retryBackoffConfig: RetryBackoffConfig;
}

export interface UtxoTrackerInternals {
  utxoSource$?: TrackerSubject<Cardano.Utxo[]>;
}

export const createUtxoProvider = (
  walletProvider: WalletProvider,
  addresses: Cardano.Address[],
  tipBlockHeight$: Observable<number>,
  retryBackoffConfig: RetryBackoffConfig
) =>
  coldObservableProvider(
    () => walletProvider.utxoDelegationAndRewards(addresses, '').then(({ utxo }) => utxo),
    retryBackoffConfig,
    tipBlockHeight$,
    utxoEquals
  );

export const createUtxoTracker = (
  { walletProvider, addresses, transactionsInFlight$, retryBackoffConfig, tipBlockHeight$ }: UtxoTrackerProps,
  {
    utxoSource$ = new TrackerSubject(createUtxoProvider(walletProvider, addresses, tipBlockHeight$, retryBackoffConfig))
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
    // Currently querying ALL utxo. In the future this will not be utxoSource$,
    // as the initial utxo set will be loaded from storage.
    // Same pattern in TransactionsTracker.
    total$: utxoSource$
  };
};
