import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, ProviderTracker } from './ProviderTracker';
import { TimeSettingsProvider } from '@cardano-sdk/core';

export class TimeSettingsProviderStats {
  readonly getTimeSettings$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.getTimeSettings$.complete();
  }

  reset() {
    this.getTimeSettings$.next(CLEAN_FN_STATS);
  }
}

/**
 * Wraps a TimeSettingsProvider, tracking # of calls of each function
 */
export class TrackedTimeSettingsProvider extends ProviderTracker implements TimeSettingsProvider {
  readonly stats = new TimeSettingsProviderStats();
  readonly getTimeSettings: TimeSettingsProvider['getTimeSettings'];

  constructor(timeSettingsProvider: TimeSettingsProvider) {
    super();
    timeSettingsProvider = timeSettingsProvider;

    this.getTimeSettings = () => this.trackedCall(timeSettingsProvider.getTimeSettings, this.stats.getTimeSettings$);
  }
}
