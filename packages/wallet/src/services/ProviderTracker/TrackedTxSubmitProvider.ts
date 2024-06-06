import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderTracker } from './ProviderTracker.js';
import type { ProviderFnStats } from './ProviderTracker.js';
import type { TxSubmitProvider } from '@cardano-sdk/core';

export const CLEAN_TX_SUBMIT_STATS: ProviderFnStats = { ...CLEAN_FN_STATS, initialized: true };

export class TxSubmitProviderStats {
  readonly healthCheck$ = new BehaviorSubject<ProviderFnStats>(CLEAN_TX_SUBMIT_STATS);
  readonly submitTx$ = new BehaviorSubject<ProviderFnStats>(CLEAN_TX_SUBMIT_STATS);

  shutdown() {
    this.submitTx$.complete();
    this.healthCheck$.complete();
  }

  reset() {
    this.healthCheck$.next(CLEAN_TX_SUBMIT_STATS);
    this.submitTx$.next(CLEAN_TX_SUBMIT_STATS);
  }
}

/** Wraps a TxSubmitProvider, tracking # of calls of each function */
export class TrackedTxSubmitProvider extends ProviderTracker implements TxSubmitProvider {
  readonly stats = new TxSubmitProviderStats();
  readonly healthCheck: TxSubmitProvider['healthCheck'];
  readonly submitTx: TxSubmitProvider['submitTx'];

  constructor(txSubmitProvider: TxSubmitProvider) {
    super();
    txSubmitProvider = txSubmitProvider;

    this.healthCheck = () => this.trackedCall(() => txSubmitProvider.healthCheck(), this.stats.healthCheck$);

    this.submitTx = (signedTransaction) =>
      this.trackedCall(() => txSubmitProvider.submitTx(signedTransaction), this.stats.submitTx$);
  }
}
