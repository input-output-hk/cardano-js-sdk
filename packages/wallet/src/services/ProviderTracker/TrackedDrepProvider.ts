import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, ProviderTracker } from './ProviderTracker';
import { DRepProvider } from '@cardano-sdk/core';

export class DrepProviderStats {
  readonly healthCheck$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly getDRepInfo$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.healthCheck$.complete();
    this.getDRepInfo$.complete();
  }

  reset() {
    this.healthCheck$.next(CLEAN_FN_STATS);
    this.getDRepInfo$.next(CLEAN_FN_STATS);
  }
}

/** Wraps a DRepProvider, tracking # of calls of each function */
export class TrackedDrepProvider extends ProviderTracker implements DRepProvider {
  readonly stats = new DrepProviderStats();
  readonly healthCheck: DRepProvider['healthCheck'];
  readonly getDRepInfo: DRepProvider['getDRepInfo'];
  readonly getDRepsInfo: DRepProvider['getDRepsInfo'];

  constructor(drepProvider: DRepProvider) {
    super();
    drepProvider = drepProvider;

    this.healthCheck = () => this.trackedCall(() => drepProvider.healthCheck(), this.stats.healthCheck$);
    this.getDRepInfo = (args) => this.trackedCall(() => drepProvider.getDRepInfo(args), this.stats.getDRepInfo$);
    this.getDRepsInfo = (args) => this.trackedCall(() => drepProvider.getDRepsInfo(args), this.stats.getDRepInfo$);
  }
}
