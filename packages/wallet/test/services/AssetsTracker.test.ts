import { Asset } from '@cardano-sdk/core';
import { AssetId } from '@cardano-sdk/util-dev';
import { AssetsTrackerProps, Balance, TransactionalTracker, createAssetsTracker } from '../../src/services';
import { createTestScheduler } from '../testScheduler';
import { of } from 'rxjs';

describe('createAssetsTracker', () => {
  it('fetches asset info for every asset in total balance', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const balanceTracker = {
        total$: cold('a-b-c', {
          a: {} as Balance,
          b: { assets: new Map([[AssetId.TSLA, 1n]]) } as Balance,
          c: {
            assets: new Map([
              [AssetId.TSLA, 1n],
              [AssetId.PXL, 2n]
            ])
          } as Balance
        })
      } as unknown as TransactionalTracker<Balance>;
      const nftMetadata = { name: 'nft' } as Asset.NftMetadata;
      const nftMetadataService = jest
        .fn()
        .mockReturnValueOnce(cold('a', { a: undefined }))
        .mockReturnValueOnce(cold('a', { a: nftMetadata }));
      const asset1 = { assetId: AssetId.TSLA } as Asset.AssetInfo;
      const asset2 = { assetId: AssetId.PXL, nftMetadata } as Asset.AssetInfo;
      const assetService = jest.fn().mockReturnValueOnce(of(asset1)).mockReturnValueOnce(of(asset2));
      const target$ = createAssetsTracker({ balanceTracker } as AssetsTrackerProps, {
        assetService,
        nftMetadataService
      });
      expectObservable(target$).toBe('a-b-c', {
        a: {},
        b: new Map([[AssetId.TSLA, asset1]]),
        c: new Map([
          [AssetId.TSLA, asset1],
          [AssetId.PXL, asset2]
        ])
      });
    });
  });
});
