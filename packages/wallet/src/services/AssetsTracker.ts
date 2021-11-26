import { AssetProvider, Cardano } from '@cardano-sdk/core';
import { Assets } from '../types';
import { Balance, TransactionalTracker } from './types';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { coldObservableProvider } from './util';
import { distinct, from, mergeMap, of, scan, startWith } from 'rxjs';

export const createGetAssetProvider =
  (assetProvider: AssetProvider, retryBackoffConfig: RetryBackoffConfig) => (assetId: Cardano.AssetId) =>
    coldObservableProvider(
      () => assetProvider.getAsset(assetId),
      retryBackoffConfig,
      of(true) // fetch only once
    );
export type GetAssetProvider = ReturnType<typeof createGetAssetProvider>;

export interface AssetsTrackerProps {
  balanceTracker: TransactionalTracker<Balance>;
  assetProvider: AssetProvider;
  retryBackoffConfig: RetryBackoffConfig;
}

interface AssetsTrackerInternals {
  getAssetProvider?: GetAssetProvider;
}

export const createAssetsTracker = (
  { assetProvider, balanceTracker, retryBackoffConfig }: AssetsTrackerProps,
  { getAssetProvider = createGetAssetProvider(assetProvider, retryBackoffConfig) }: AssetsTrackerInternals = {}
) =>
  balanceTracker.total$.pipe(
    mergeMap(({ assets }) => from(assets?.keys() || [])),
    distinct(),
    mergeMap((assetId) => getAssetProvider(assetId)),
    scan((assets, asset) => new Map([...assets, [asset.assetId, asset]]), new Map<Cardano.AssetId, Cardano.Asset>()),
    startWith({} as Assets)
  );
