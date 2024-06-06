import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderTracker } from './ProviderTracker.js';
import type { ChainHistoryProvider } from '@cardano-sdk/core';
import type { ProviderFnStats } from './ProviderTracker.js';

export class ChainHistoryProviderStats {
  readonly healthCheck$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly blocksByHashes$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly transactionsByAddresses$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly transactionsByHashes$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.healthCheck$.complete();
    this.blocksByHashes$.complete();
    this.transactionsByAddresses$.complete();
    this.transactionsByHashes$.complete();
  }

  reset() {
    this.healthCheck$.next(CLEAN_FN_STATS);
    this.blocksByHashes$.next(CLEAN_FN_STATS);
    this.transactionsByAddresses$.next(CLEAN_FN_STATS);
    this.transactionsByHashes$.next(CLEAN_FN_STATS);
  }
}

/** Wraps a ChainHistoryProvider, tracking # of calls of each function */
export class TrackedChainHistoryProvider extends ProviderTracker implements ChainHistoryProvider {
  readonly stats = new ChainHistoryProviderStats();
  readonly healthCheck: ChainHistoryProvider['healthCheck'];
  readonly transactionsByAddresses: ChainHistoryProvider['transactionsByAddresses'];
  readonly transactionsByHashes: ChainHistoryProvider['transactionsByHashes'];
  readonly blocksByHashes: ChainHistoryProvider['blocksByHashes'];

  constructor(chainHistoryProvider: ChainHistoryProvider) {
    super();
    chainHistoryProvider = chainHistoryProvider;

    this.healthCheck = () => this.trackedCall(() => chainHistoryProvider.healthCheck(), this.stats.healthCheck$);
    this.transactionsByAddresses = ({ addresses, pagination, blockRange }) =>
      this.trackedCall(
        () => chainHistoryProvider.transactionsByAddresses({ addresses, blockRange, pagination }),
        this.stats.transactionsByAddresses$
      );
    this.transactionsByHashes = (hashes) =>
      this.trackedCall(() => chainHistoryProvider.transactionsByHashes(hashes), this.stats.transactionsByHashes$);
    this.blocksByHashes = (hashes) =>
      this.trackedCall(() => chainHistoryProvider.blocksByHashes(hashes), this.stats.blocksByHashes$);
  }
}
