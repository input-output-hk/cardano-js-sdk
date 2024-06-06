import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderTracker } from './ProviderTracker.js';
import type { AssetProvider } from '@cardano-sdk/core';
import type { ProviderFnStats } from './ProviderTracker.js';

export class AssetProviderStats {
  readonly healthCheck$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);
  readonly getAsset$ = new BehaviorSubject<ProviderFnStats>(CLEAN_FN_STATS);

  shutdown() {
    this.healthCheck$.complete();
    this.getAsset$.complete();
  }

  reset() {
    this.healthCheck$.next(CLEAN_FN_STATS);
    this.getAsset$.next(CLEAN_FN_STATS);
  }
}

/** Wraps a AssetProvider, tracking # of calls of each function */
export class TrackedAssetProvider extends ProviderTracker implements AssetProvider {
  readonly stats = new AssetProviderStats();
  readonly healthCheck: AssetProvider['healthCheck'];
  readonly getAsset: AssetProvider['getAsset'];
  readonly getAssets: AssetProvider['getAssets'];

  constructor(assetProvider: AssetProvider) {
    super();
    assetProvider = assetProvider;

    this.healthCheck = () => this.trackedCall(() => assetProvider.healthCheck(), this.stats.healthCheck$);

    this.getAsset = ({ assetId, extraData }) =>
      this.trackedCall(() => assetProvider.getAsset({ assetId, extraData }), this.stats.getAsset$);

    this.getAssets = ({ assetIds, extraData }) =>
      this.trackedCall(() => assetProvider.getAssets({ assetIds, extraData }), this.stats.getAsset$);
  }
}
