import { Asset, Cardano } from '@cardano-sdk/core';
import { AssetId, createTestScheduler } from '@cardano-sdk/util-dev';
import { AssetsTrackerProps, BalanceTracker, TransactionalTracker, createAssetsTracker } from '../../src/services';
import { of } from 'rxjs';

describe('createAssetsTracker', () => {
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
      const nftMetadata = { name: 'nft' } as Asset.NftMetadata;
      const asset1 = { assetId: AssetId.TSLA } as Asset.AssetInfo;
      const asset2 = { assetId: AssetId.PXL, nftMetadata } as Asset.AssetInfo;
      const assetService = jest.fn().mockReturnValueOnce(of(asset1)).mockReturnValueOnce(of(asset2));
      const assetProvider = {
        setStatInitialized: jest.fn(),
        stats: {}
      };
      const target$ = createAssetsTracker({ assetProvider, balanceTracker } as unknown as AssetsTrackerProps, {
        assetService
      });
      expectObservable(target$).toBe('--b-c', {
        b: new Map([[AssetId.TSLA, asset1]]),
        c: new Map([
          [AssetId.TSLA, asset1],
          [AssetId.PXL, asset2]
        ])
      });
      flush();
      expect(assetProvider.setStatInitialized).toBeCalledTimes(1); // only when there are no assets
    });
  });
});
