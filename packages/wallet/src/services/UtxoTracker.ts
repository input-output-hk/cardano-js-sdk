import { Cardano, WalletProvider } from '@cardano-sdk/core';
import { Observable, combineLatest, from, map } from 'rxjs';
import { ProviderTrackerSubject, SourceTrackerConfig, TrackerSubject, utxoEquals } from './util';
import { SimpleProvider, SourceTransactionalTracker } from './types';

export interface UtxoTrackerProps {
  utxoProvider: SimpleProvider<Cardano.Utxo[]>;
  transactionsInFlight$: Observable<Cardano.NewTxAlonzo[]>;
  config: SourceTrackerConfig;
}

export interface UtxoTrackerInternals {
  utxoSource$?: ProviderTrackerSubject<Cardano.Utxo[]>;
}

export const createUtxoProvider =
  (walletProvider: WalletProvider, addresses: Cardano.Address[]): (() => Observable<Cardano.Utxo[]>) =>
  () =>
    from(walletProvider.utxoDelegationAndRewards(addresses, '').then(({ utxo }) => utxo));

export const createUtxoTracker = (
  { utxoProvider, transactionsInFlight$, config }: UtxoTrackerProps,
  {
    utxoSource$ = new ProviderTrackerSubject({ config, equals: utxoEquals, provider: utxoProvider })
  }: UtxoTrackerInternals = {}
): SourceTransactionalTracker<Cardano.Utxo[]> => {
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

    sync: () => utxoSource$.sync(),
    // Currently querying ALL utxo. In the future this will not be providerUtxo$,
    // as the initial utxo set will be loaded from storage.
    // Same pattern in TransactionsTracker.
    total$: utxoSource$
  };
};
