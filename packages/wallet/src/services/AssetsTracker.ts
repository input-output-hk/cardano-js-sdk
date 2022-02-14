import { Asset, AssetProvider, Cardano, NftMetadataProvider } from '@cardano-sdk/core';
import { Assets } from '../types';
import { Balance, TransactionalTracker } from './types';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { coldObservableProvider } from './util';
import { distinct, from, map, mergeMap, of, scan, startWith } from 'rxjs';

export const createAssetService =
  (assetProvider: AssetProvider, retryBackoffConfig: RetryBackoffConfig) => (assetId: Cardano.AssetId) =>
    coldObservableProvider(
      () => assetProvider.getAsset(assetId),
      retryBackoffConfig,
      of(true) // fetch only once
    );
export type AssetService = ReturnType<typeof createAssetService>;

export const createNftMetadataService =
  (nftMetadataProvider: NftMetadataProvider, retryBackoffConfig: RetryBackoffConfig) => (asset: Asset.AssetInfo) =>
    coldObservableProvider(
      () => nftMetadataProvider(asset),
      retryBackoffConfig,
      of(true) // fetch only once
    );
export type NftMetadataService = ReturnType<typeof createNftMetadataService>;

export interface AssetsTrackerProps {
  balanceTracker: TransactionalTracker<Balance>;
  nftMetadataProvider: NftMetadataProvider;
  assetProvider: AssetProvider;
  retryBackoffConfig: RetryBackoffConfig;
}

interface AssetsTrackerInternals {
  assetService?: AssetService;
  nftMetadataService?: NftMetadataService;
}

export const createAssetsTracker = (
  { assetProvider, balanceTracker, retryBackoffConfig, nftMetadataProvider }: AssetsTrackerProps,
  {
    nftMetadataService = createNftMetadataService(nftMetadataProvider, retryBackoffConfig),
    assetService = createAssetService(assetProvider, retryBackoffConfig)
  }: AssetsTrackerInternals = {}
) =>
  balanceTracker.total$.pipe(
    mergeMap(({ assets }) => from(assets?.keys() || [])),
    distinct(),
    mergeMap((assetId) => assetService(assetId)),
    mergeMap((asset) => nftMetadataService(asset).pipe(map((nftMetadata) => ({ ...asset, nftMetadata })))),
    scan((assets, asset) => new Map([...assets, [asset.assetId, asset]]), new Map<Cardano.AssetId, Asset.AssetInfo>()),
    startWith({} as Assets)
  );
