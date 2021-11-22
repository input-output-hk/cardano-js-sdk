import { AssetId } from '@cardano-sdk/util-dev';
import { AssetsTrackerProps, Balance, TransactionalTracker, createAssetsTracker } from '../../src/services';
import { Cardano } from '@cardano-sdk/core';
import { createTestScheduler } from '../testScheduler';
import { of } from 'rxjs';

describe('createAssetsTracker', () => {
  it('fetches asset info for every asset in total balance', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const balanceTracker = {
        total$: cold('a-b-c', {
          a: {} as Balance,
          b: { assets: { [AssetId.TSLA]: 1n } as Cardano.TokenMap } as Balance,
          c: {
            assets: {
              [AssetId.TSLA]: 1n,
              [AssetId.PXL]: 2n
            } as Cardano.TokenMap
          } as Balance
        })
      } as unknown as TransactionalTracker<Balance>;
      const asset1 = { assetId: AssetId.TSLA, name: 'TSLA' } as Cardano.Asset;
      const asset2 = { assetId: AssetId.PXL, name: 'PXL' } as Cardano.Asset;
      const getAssetProvider = jest.fn().mockReturnValueOnce(of(asset1)).mockReturnValueOnce(of(asset2));
      const target$ = createAssetsTracker({ balanceTracker } as AssetsTrackerProps, { getAssetProvider });
      expectObservable(target$).toBe('a-b-c', {
        a: {},
        b: {
          [AssetId.TSLA]: asset1
        },
        c: {
          [AssetId.TSLA]: asset1,
          [AssetId.PXL]: asset2
        }
      });
    });
  });
});
