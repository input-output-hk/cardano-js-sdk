import { Asset, Cardano } from '@cardano-sdk/core';
import { AssetId, createTestScheduler } from '@cardano-sdk/util-dev';
import {
  AssetService,
  AssetsTrackerProps,
  BalanceTracker,
  TrackedAssetProvider,
  TransactionalTracker,
  createAssetsTracker
} from '../../src/services';
import { dummyLogger } from 'ts-log';
import { of } from 'rxjs';

describe('createAssetsTracker', () => {
  let assetTsla: Asset.AssetInfo;
  let assetPxl: Asset.AssetInfo;
  let assetService: AssetService;
  let assetProvider: TrackedAssetProvider;
  const logger = dummyLogger;

  beforeEach(() => {
    const nftMetadata = { name: 'nft' } as Asset.NftMetadata;
    assetTsla = { assetId: AssetId.TSLA } as Asset.AssetInfo;
    assetPxl = { assetId: AssetId.PXL, nftMetadata } as Asset.AssetInfo;
    assetService = jest.fn().mockReturnValueOnce(of(assetTsla)).mockReturnValueOnce(of(assetPxl));
    assetProvider = {
      setStatInitialized: jest.fn(),
      stats: {}
    } as unknown as TrackedAssetProvider;
  });

  it('fetches asset info for every asset in total balance', () => {
    createTestScheduler().run(({ cold, expectObservable, flush }) => {
      const balanceTracker = {
        utxo: {
          total$: cold('a-b-c', {
            a: {} as Cardano.Value,
            b: { assets: new Map([[AssetId.TSLA, 1n]]) } as Cardano.Value,
            c: {
              assets: new Map([
                [AssetId.TSLA, 1n],
                [AssetId.PXL, 2n]
              ])
            } as Cardano.Value
          })
        }
      } as unknown as TransactionalTracker<BalanceTracker>;

      const target$ = createAssetsTracker({ assetProvider, balanceTracker, logger } as unknown as AssetsTrackerProps, {
        assetService
      });
      expectObservable(target$).toBe('--b-c', {
        b: new Map([[AssetId.TSLA, assetTsla]]),
        c: new Map([
          [AssetId.TSLA, assetTsla],
          [AssetId.PXL, assetPxl]
        ])
      });
      flush();
      expect(assetProvider.setStatInitialized).toBeCalledTimes(1); // only when there are no assets
      expect(assetService).toHaveBeenCalledTimes(2);
    });
  });

  it('removes assets no longer available in total balance', () => {
    createTestScheduler().run(({ cold, expectObservable, flush }) => {
      const balanceTracker = {
        utxo: {
          total$: cold('a-b-c', {
            a: {} as Cardano.Value,
            b: {
              assets: new Map([
                [AssetId.TSLA, 1n],
                [AssetId.PXL, 2n]
              ])
            } as Cardano.Value,
            c: { assets: new Map([[AssetId.PXL, 2n]]) } as Cardano.Value
          })
        }
      } as unknown as TransactionalTracker<BalanceTracker>;

      const target$ = createAssetsTracker({ assetProvider, balanceTracker, logger } as unknown as AssetsTrackerProps, {
        assetService
      });
      expectObservable(target$).toBe('--b-c', {
        b: new Map([
          [AssetId.TSLA, assetTsla],
          [AssetId.PXL, assetPxl]
        ]),
        c: new Map([[AssetId.PXL, assetPxl]])
      });
      flush();
      expect(assetService).toHaveBeenCalledTimes(2);
    });
  });
});
