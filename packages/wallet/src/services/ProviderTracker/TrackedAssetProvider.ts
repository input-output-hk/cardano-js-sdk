import { AssetProvider } from '@cardano-sdk/core';
import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, ProviderTracker } from './ProviderTracker';

export class AssetProviderStats {
  readonly getAsset$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.getAsset$.complete();
  }

  reset() {
    this.getAsset$.next(CLEAN_FN_STATS);
  }
}

/**
 * Wraps a AssetProvider, tracking # of calls of each function
 */
export class TrackedAssetProvider extends ProviderTracker implements AssetProvider {
  readonly stats = new AssetProviderStats();
  readonly getAsset: AssetProvider['getAsset'];

  constructor(assetProvider: AssetProvider) {
    super();
    assetProvider = assetProvider;

    this.getAsset = (assetId) => this.trackedCall(() => assetProvider.getAsset(assetId), this.stats.getAsset$);
  }
}
