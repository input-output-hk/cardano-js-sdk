import { Asset, Cardano } from '@cardano-sdk/core';
import { AssetId, createTestScheduler, logger } from '@cardano-sdk/util-dev';
import {
  AssetService,
  AssetsTrackerProps,
  TrackedAssetProvider,
  TransactionsTracker,
  createAssetsTracker
} from '../../src/services';

import { RetryBackoffConfig } from 'backoff-rxjs';
import { from, lastValueFrom, of, tap } from 'rxjs';

const createTxWithValues = (values: Partial<Cardano.Value>[]): Cardano.HydratedTx =>
  ({ body: { outputs: values.map((value) => ({ value })) } } as Cardano.HydratedTx);

describe('createAssetsTracker', () => {
  let assetTsla: Asset.AssetInfo;
  let assetPxl: Asset.AssetInfo;
  let assetService: AssetService;
  let assetProvider: TrackedAssetProvider;
  const retryBackoffConfig: RetryBackoffConfig = { initialInterval: 2 };

  beforeEach(() => {
    const nftMetadata = { name: 'nft' } as Asset.NftMetadata;
    assetTsla = { assetId: AssetId.TSLA, nftMetadata: null, tokenMetadata: null } as Asset.AssetInfo;
    assetPxl = { assetId: AssetId.PXL, nftMetadata, tokenMetadata: null } as Asset.AssetInfo;
    assetService = jest
      .fn()
      .mockReturnValueOnce(of([assetTsla]))
      .mockReturnValueOnce(of([assetPxl]));
    assetProvider = {
      setStatInitialized: jest.fn(),
      stats: {}
    } as unknown as TrackedAssetProvider;
  });

  it('fetches asset info for every history transaction', () => {
    createTestScheduler().run(({ cold, expectObservable, flush }) => {
      const transactionsTracker: Partial<TransactionsTracker> = {
        history$: cold('a-b-c', {
          a: [],
          b: [createTxWithValues([{ assets: new Map([[AssetId.TSLA, 1n]]) }])],
          c: [
            createTxWithValues([{ assets: new Map([[AssetId.TSLA, 1n]]) }]),
            createTxWithValues([
              {
                assets: new Map([[AssetId.PXL, 2n]])
              }
            ])
          ]
        })
      };

      const target$ = createAssetsTracker(
        { assetProvider, logger, retryBackoffConfig, transactionsTracker } as unknown as AssetsTrackerProps,
        {
          assetService
        }
      );
      expectObservable(target$).toBe('a-b-c', {
        a: new Map(),
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

  it('does not emit if the assets in transaction history have not changed', () => {
    createTestScheduler().run(({ cold, expectObservable, flush }) => {
      const transactionsTracker: Partial<TransactionsTracker> = {
        history$: cold('a-b-c', {
          a: [createTxWithValues([{}])],
          b: [createTxWithValues([{ assets: new Map([[AssetId.TSLA, 1n]]), coins: 1_000_000n }])],
          c: [
            createTxWithValues([{ assets: new Map([[AssetId.TSLA, 1n]]), coins: 1_000_000n }]),
            createTxWithValues([{ assets: new Map([[AssetId.TSLA, 1n]]), coins: 2_000_000n }])
          ]
        })
      };

      const target$ = createAssetsTracker(
        { assetProvider, logger, retryBackoffConfig, transactionsTracker } as unknown as AssetsTrackerProps,
        {
          assetService
        }
      );
      expectObservable(target$).toBe('a-b--', {
        a: new Map(),
        b: new Map([[AssetId.TSLA, assetTsla]])
      });
      flush();
      expect(assetProvider.setStatInitialized).toBeCalledTimes(1);
      expect(assetService).toHaveBeenCalledTimes(1);
    });
  });

  it('emits at least once if there are no assets found in total history', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const transactionsTracker: Partial<TransactionsTracker> = {
        history$: cold('a-b-c', {
          a: [createTxWithValues([{ coins: 1_000_000n }])],
          b: [createTxWithValues([{ coins: 1_000_000n }]), createTxWithValues([{ coins: 2_000_000n }])],
          c: [
            createTxWithValues([{ coins: 1_000_000n }]),
            createTxWithValues([{ coins: 2_000_000n }]),
            createTxWithValues([{ coins: 3_000_000n }])
          ]
        })
      };

      const target$ = createAssetsTracker(
        {
          assetProvider,
          logger,
          retryBackoffConfig,
          transactionsTracker
        } as unknown as AssetsTrackerProps,
        {
          assetService
        }
      );
      expectObservable(target$).toBe('a----', { a: new Map() });
    });
  });

  it('does not remove assetInfo on transaction rollback', () => {
    createTestScheduler().run(({ cold, expectObservable, flush }) => {
      const transactionsTracker: Partial<TransactionsTracker> = {
        history$: cold('a-b-c', {
          a: [createTxWithValues([{}])],
          b: [
            createTxWithValues([{ assets: new Map([[AssetId.TSLA, 1n]]) }]),
            createTxWithValues([{ assets: new Map([[AssetId.PXL, 2n]]) }])
          ],
          c: [createTxWithValues([{ assets: new Map([[AssetId.PXL, 1n]]) }])]
        })
      };

      assetService = jest.fn().mockReturnValueOnce(of([assetTsla, assetPxl]));

      const target$ = createAssetsTracker(
        { assetProvider, logger, retryBackoffConfig, transactionsTracker } as unknown as AssetsTrackerProps,
        {
          assetService
        }
      );
      expectObservable(target$).toBe('a-b-c', {
        a: new Map(),
        b: new Map([
          [AssetId.TSLA, assetTsla],
          [AssetId.PXL, assetPxl]
        ]),
        c: new Map([
          [AssetId.TSLA, assetTsla],
          [AssetId.PXL, assetPxl]
        ])
      });
      flush();
      expect(assetService).toHaveBeenCalledTimes(1);
    });
  });

  it('gets assetInfo for all outputs, skipping outputs without assets', () => {
    createTestScheduler().run(({ cold, expectObservable, flush }) => {
      const transactionsTracker: Partial<TransactionsTracker> = {
        history$: cold('a-b-c', {
          a: [createTxWithValues([{}])],
          b: [
            createTxWithValues([{ assets: new Map([[AssetId.TSLA, 1n]]) }, { coins: 1000n }]),
            createTxWithValues([{ coins: 2000n }])
          ],
          c: [
            createTxWithValues([{ assets: new Map([[AssetId.TSLA, 1n]]) }, { coins: 1000n }]),
            createTxWithValues([{ coins: 2000n }]),
            createTxWithValues([{ coins: 3000n }, { assets: new Map([[AssetId.PXL, 2n]]) }]),
            createTxWithValues([{ coins: 4000n }])
          ]
        })
      };

      assetService = jest
        .fn()
        .mockReturnValueOnce(of([assetTsla]))
        .mockReturnValueOnce(of([assetPxl]));

      const target$ = createAssetsTracker(
        { assetProvider, logger, retryBackoffConfig, transactionsTracker } as unknown as AssetsTrackerProps,
        {
          assetService
        }
      );
      expectObservable(target$).toBe('a-b-c', {
        a: new Map(),
        b: new Map([[AssetId.TSLA, assetTsla]]),
        c: new Map([
          [AssetId.TSLA, assetTsla],
          [AssetId.PXL, assetPxl]
        ])
      });
      flush();
      expect(assetService).toHaveBeenCalledTimes(2);
    });
  });

  it('polls asset info while metadata is undefined', async () => {
    assetProvider = {
      getAssets: jest
        .fn()
        .mockResolvedValueOnce([{ ...assetTsla, nftMetadata: undefined }, assetPxl])
        .mockResolvedValueOnce([{ ...assetTsla, tokenMetadata: undefined }, assetPxl])
        .mockResolvedValueOnce([assetTsla, assetPxl]),
      setStatInitialized: jest.fn(),
      stats: {}
    } as unknown as TrackedAssetProvider;

    const transactionsTracker: Partial<TransactionsTracker> = {
      history$: from([
        [createTxWithValues([{}])],
        [
          createTxWithValues([
            {
              assets: new Map([
                [AssetId.TSLA, 1n],
                [AssetId.PXL, 2n]
              ])
            }
          ])
        ]
      ])
    };

    const target$ = createAssetsTracker({
      assetProvider,
      logger,
      retryBackoffConfig,
      transactionsTracker
    } as unknown as AssetsTrackerProps);

    const assetInfos: Map<Cardano.AssetId, Asset.AssetInfo>[] = [];
    await lastValueFrom(target$.pipe(tap((ai) => assetInfos.push(ai))));
    expect(assetInfos).toEqual([
      new Map(),
      new Map([
        [AssetId.TSLA, { ...assetTsla, nftMetadata: undefined }],
        [AssetId.PXL, assetPxl]
      ]),
      new Map([
        [AssetId.TSLA, { ...assetTsla, tokenMetadata: undefined }],
        [AssetId.PXL, assetPxl]
      ]),
      new Map([
        [AssetId.TSLA, assetTsla],
        [AssetId.PXL, assetPxl]
      ])
    ]);
    expect(assetProvider.getAssets).toBeCalledTimes(3);
  });
});
