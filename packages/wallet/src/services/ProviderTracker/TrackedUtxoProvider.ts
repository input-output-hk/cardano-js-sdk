import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderTracker } from './ProviderTracker.js';
import type { ProviderFnStats } from './ProviderTracker.js';
import type { UtxoProvider } from '@cardano-sdk/core';

export class UtxoProviderStats {
  readonly healthCheck$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly utxoByAddresses$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.utxoByAddresses$.complete();
    this.healthCheck$.complete();
  }

  reset() {
    this.healthCheck$.next(CLEAN_FN_STATS);
    this.utxoByAddresses$.next(CLEAN_FN_STATS);
  }
}

/** Wraps a UtxoProvider, tracking # of calls of each function */
export class TrackedUtxoProvider extends ProviderTracker implements UtxoProvider {
  readonly stats = new UtxoProviderStats();
  readonly healthCheck: UtxoProvider['healthCheck'];
  readonly utxoByAddresses: UtxoProvider['utxoByAddresses'];

  constructor(utxoProvider: UtxoProvider) {
    super();
    utxoProvider = utxoProvider;

    this.healthCheck = () => this.trackedCall(() => utxoProvider.healthCheck(), this.stats.healthCheck$);

    this.utxoByAddresses = (addresses) =>
      this.trackedCall(() => utxoProvider.utxoByAddresses(addresses), this.stats.utxoByAddresses$);
  }
}
