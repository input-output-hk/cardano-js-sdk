import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, ProviderTracker } from './ProviderTracker';
import { TxSubmitProvider } from '@cardano-sdk/core';

export class TxSubmitProviderStats {
  readonly submitTx$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  reset() {
    this.submitTx$.next(CLEAN_FN_STATS);
  }
}

/**
 * Wraps a TxSubmitProvider, tracking # of calls of each function
 */
export class TrackedTxSubmitProvider extends ProviderTracker implements TxSubmitProvider {
  readonly stats = new TxSubmitProviderStats();
  readonly submitTx: TxSubmitProvider['submitTx'];

  constructor(txSubmitProvider: TxSubmitProvider) {
    super();
    txSubmitProvider = txSubmitProvider;

    this.submitTx = (signedTransaction) =>
      this.trackedCall(() => txSubmitProvider.submitTx(signedTransaction), this.stats.submitTx$);
  }
}
