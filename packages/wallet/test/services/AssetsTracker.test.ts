import { Asset, Cardano, GetAssetsArgs } from '@cardano-sdk/core';
import { AssetId, createTestScheduler, generateRandomHexString, logger } from '@cardano-sdk/util-dev';
import {
  AssetService,
  AssetsTrackerProps,
  BalanceTracker,
  TrackedAssetProvider,
  TransactionsTracker,
  createAssetService,
  createAssetsTracker
} from '../../src/services';

import { Observable, firstValueFrom, from, lastValueFrom, of, tap } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';

const createTxWithValues = (values: Partial<Cardano.Value>[]): Cardano.HydratedTx =>
  ({ body: { outputs: values.map((value) => ({ value })) }, id: generateRandomHexString(64) } as Cardano.HydratedTx);

const removeStaleAt = (assetInfos: Map<Cardano.AssetId, Asset.AssetInfo>[]) =>
  assetInfos.map(
    (assets) => new Map([...assets.entries()].map(([key, value]) => [key, { ...value, staleAt: undefined }]))
  );

const cip68AssetId = {
  referenceNFT: Cardano.AssetId.fromParts(
    Cardano.AssetId.getPolicyId(AssetId.TSLA),
    Asset.AssetNameLabel.encode(Cardano.AssetId.getAssetName(AssetId.TSLA), Asset.AssetNameLabelNum.ReferenceNFT)
  ),
  userNFT: Cardano.AssetId.fromParts(
    Cardano.AssetId.getPolicyId(AssetId.TSLA),
    Asset.AssetNameLabel.encode(Cardano.AssetId.getAssetName(AssetId.TSLA), Asset.AssetNameLabelNum.UserNFT)
  )
};

const ONE_WEEK = 7 * 24 * 60 * 60 * 1000;

const assetInfo = {
  PXL: { assetId: AssetId.PXL, nftMetadata: { name: 'nft' }, tokenMetadata: null } as Asset.AssetInfo,
  TSLA: { assetId: AssetId.TSLA, nftMetadata: null, tokenMetadata: null } as Asset.AssetInfo,
  cip68ReferenceNft: {
    assetId: cip68AssetId.referenceNFT,
    nftMetadata: null,
    tokenMetadata: null
  } as Asset.AssetInfo,
  cip68UserNft: [
    { assetId: cip68AssetId.userNFT, nftMetadata: null, tokenMetadata: null } as Asset.AssetInfo,
    {
      assetId: cip68AssetId.userNFT,
      nftMetadata: { image: 'ipfs://img', name: 'TSLA', version: '1.0' },
      tokenMetadata: null
    } as Asset.AssetInfo
  ]
};

describe('createAssetsTracker', () => {
  let assetService: AssetService;
  let assetProvider: TrackedAssetProvider;
  let balanceTracker: BalanceTracker;
  let assetsCache$: Observable<Map<Cardano.AssetId, Asset.AssetInfo>>;
  const retryBackoffConfig: RetryBackoffConfig = { initialInterval: 2 };

  beforeEach(() => {
    // Configure asset info responses here.
    // If value is an array, each element is used as a response for request,
    // starting from 0th element
    const assetMetadata = {
      [AssetId.TSLA]: assetInfo.TSLA,
      [AssetId.PXL]: assetInfo.PXL,
      [cip68AssetId.referenceNFT]: assetInfo.cip68ReferenceNft,
      [cip68AssetId.userNFT]: [assetInfo.cip68UserNft[0], assetInfo.cip68UserNft[1]]
    };
    assetService = jest.fn().mockImplementation((assetIds: Cardano.AssetId[]) =>
      of(
        assetIds.map((assetId) => {
          const response = assetMetadata[assetId];
          if (Array.isArray(response)) {
            return response.shift();
          }
          return response;
        })
      )
    );
    assetProvider = {
      setStatInitialized: jest.fn(),
      stats: {}
    } as unknown as TrackedAssetProvider;

    balanceTracker = {
      rewardAccounts: {
        deposit$: of(0n),
        rewards$: of(0n)
      },
      utxo: {
        available$: of({ coins: 0n }),
        total$: of({ coins: 0n }),
        unspendable$: of({ coins: 0n })
      }
    };

    assetsCache$ = of(new Map());
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
        {
          assetProvider,
          assetsCache$,
          balanceTracker,
          logger,
          retryBackoffConfig,
          transactionsTracker
        } as unknown as AssetsTrackerProps,
        {
          assetService
        }
      );
      expectObservable(target$).toBe('a--b-c', {
        a: new Map(),
        b: new Map([[AssetId.TSLA, assetInfo.TSLA]]),
        c: new Map([
          [AssetId.TSLA, assetInfo.TSLA],
          [AssetId.PXL, assetInfo.PXL]
        ])
      });
      flush();
      expect(assetProvider.setStatInitialized).toBeCalledTimes(1); // only when there are no assets
      expect(assetService).toHaveBeenCalledTimes(2);
    });
  });

  it('re-fetches asset info when there is a cip68 reference nft in some tx history output', () => {
    createTestScheduler().run(({ cold, expectObservable, flush }) => {
      const transactionsTracker: Partial<TransactionsTracker> = {
        history$: cold('a-b', {
          a: [createTxWithValues([{ assets: new Map([[cip68AssetId.userNFT, 1n]]) }])],
          b: [
            createTxWithValues([
              {
                assets: new Map([[cip68AssetId.referenceNFT, 1n]])
              }
            ])
          ]
        })
      };

      const target$ = createAssetsTracker(
        {
          assetProvider,
          assetsCache$,
          balanceTracker,
          logger,
          retryBackoffConfig,
          transactionsTracker
        } as unknown as AssetsTrackerProps,
        { assetService }
      );
      expectObservable(target$).toBe('a--b', {
        a: new Map([[cip68AssetId.userNFT, assetInfo.cip68UserNft[0]]]),
        b: new Map([
          // asset info was re-fetched
          [cip68AssetId.userNFT, assetInfo.cip68UserNft[1]],
          [cip68AssetId.referenceNFT, assetInfo.cip68ReferenceNft]
        ])
      });
      flush();
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
        {
          assetProvider,
          assetsCache$,
          balanceTracker,
          logger,
          retryBackoffConfig,
          transactionsTracker
        } as unknown as AssetsTrackerProps,
        {
          assetService
        }
      );
      expectObservable(target$).toBe('a--b--', {
        a: new Map(),
        b: new Map([[AssetId.TSLA, assetInfo.TSLA]])
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
          assetsCache$,
          balanceTracker,
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

      const target$ = createAssetsTracker(
        {
          assetProvider,
          assetsCache$,
          balanceTracker,
          logger,
          retryBackoffConfig,
          transactionsTracker
        } as unknown as AssetsTrackerProps,
        {
          assetService
        }
      );
      expectObservable(target$).toBe('a--b-', {
        a: new Map(),
        b: new Map([
          [AssetId.TSLA, assetInfo.TSLA],
          [AssetId.PXL, assetInfo.PXL]
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
        .mockReturnValueOnce(of([assetInfo.TSLA]))
        .mockReturnValueOnce(of([assetInfo.PXL]));

      const target$ = createAssetsTracker(
        {
          assetProvider,
          assetsCache$,
          balanceTracker,
          logger,
          retryBackoffConfig,
          transactionsTracker
        } as unknown as AssetsTrackerProps,
        {
          assetService
        }
      );
      expectObservable(target$).toBe('a--b-c', {
        a: new Map(),
        b: new Map([[AssetId.TSLA, assetInfo.TSLA]]),
        c: new Map([
          [AssetId.TSLA, assetInfo.TSLA],
          [AssetId.PXL, assetInfo.PXL]
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
        .mockResolvedValueOnce([{ ...assetInfo.TSLA, nftMetadata: undefined }, assetInfo.PXL])
        .mockResolvedValueOnce([{ ...assetInfo.TSLA, tokenMetadata: undefined }, assetInfo.PXL])
        .mockResolvedValueOnce([assetInfo.TSLA, assetInfo.PXL]),
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
      assetsCache$,
      balanceTracker,
      logger,
      retryBackoffConfig,
      transactionsTracker
    } as unknown as AssetsTrackerProps);

    const assetInfos: Map<Cardano.AssetId, Asset.AssetInfo>[] = [];
    await lastValueFrom(target$.pipe(tap((ai) => assetInfos.push(ai))));
    expect(removeStaleAt(assetInfos)).toEqual([
      new Map(),
      new Map([
        [AssetId.TSLA, { ...assetInfo.TSLA, nftMetadata: undefined }],
        [AssetId.PXL, assetInfo.PXL]
      ]),
      new Map([
        [AssetId.TSLA, { ...assetInfo.TSLA, tokenMetadata: undefined }],
        [AssetId.PXL, assetInfo.PXL]
      ]),
      new Map([
        [AssetId.TSLA, assetInfo.TSLA],
        [AssetId.PXL, assetInfo.PXL]
      ])
    ]);
    expect(assetProvider.getAssets).toBeCalledTimes(3);
  });
});

describe('createAssetService', () => {
  let assetProvider: TrackedAssetProvider;
  const retryBackoffConfig: RetryBackoffConfig = { initialInterval: 2 };

  beforeEach(() => {
    assetProvider = {
      getAssets: jest.fn() as jest.Mock<Promise<Asset.AssetInfo[]>, [GetAssetsArgs]>,
      setStatInitialized: jest.fn(),
      stats: { getAsset$: { value: {} } }
    } as unknown as TrackedAssetProvider;
  });

  it('returns cached assets if all assets are fresh', async () => {
    const cachedAssets = new Map([
      [
        AssetId.TSLA,
        {
          assetId: AssetId.TSLA,
          nftMetadata: null,
          staleAt: new Date(Date.now() + ONE_WEEK),
          tokenMetadata: null
        } as never
      ],
      [
        AssetId.PXL,
        {
          assetId: AssetId.PXL,
          nftMetadata: null,
          staleAt: new Date(Date.now() + ONE_WEEK),
          tokenMetadata: null
        } as never
      ]
    ]);

    (assetProvider.getAssets as jest.Mock).mockImplementation(() => Promise.resolve([]));

    const assetCache$ = of(cachedAssets);
    const totalBalance$ = of({
      assets: new Map([
        [AssetId.TSLA, 1000n],
        [AssetId.PXL, 2000n]
      ]),
      coins: 0n
    });

    const assetService = createAssetService(assetProvider, assetCache$, totalBalance$, retryBackoffConfig, logger);

    const result$ = assetService([AssetId.TSLA, AssetId.PXL]);

    const assets = await firstValueFrom(result$);

    expect(assets).toEqual([
      { assetId: AssetId.TSLA, nftMetadata: null, staleAt: expect.any(Date), tokenMetadata: null },
      { assetId: AssetId.PXL, nftMetadata: null, staleAt: expect.any(Date), tokenMetadata: null }
    ]);
    expect(assetProvider.getAssets).not.toBeCalled();
    expect(assetProvider.setStatInitialized).toBeCalled();
  });

  it('fetches uncached assets from the provider', async () => {
    const cachedAssets = new Map([
      [
        AssetId.TSLA,
        {
          assetId: AssetId.TSLA,
          nftMetadata: null,
          staleAt: new Date(Date.now() + ONE_WEEK),
          tokenMetadata: null
        } as never
      ]
    ]);
    const fetchedAssets = [
      { assetId: AssetId.PXL, nftMetadata: null, tokenMetadata: null },
      { assetId: AssetId.Unit, nftMetadata: null, tokenMetadata: null }
    ];

    (assetProvider.getAssets as jest.Mock).mockImplementation(() => Promise.resolve(fetchedAssets));

    const assetCache$ = of(cachedAssets);
    const totalBalance$ = of({ assets: new Map([[AssetId.TSLA, 1000n]]), coins: 0n });

    const assetService = createAssetService(assetProvider, assetCache$, totalBalance$, retryBackoffConfig, logger);

    const result$ = assetService([AssetId.TSLA, AssetId.PXL, AssetId.Unit]);

    const assets = await firstValueFrom(result$);

    expect(assets).toEqual([
      { assetId: AssetId.TSLA, nftMetadata: null, staleAt: expect.any(Date), tokenMetadata: null },
      { assetId: AssetId.PXL, nftMetadata: null, staleAt: expect.any(Date), tokenMetadata: null },
      { assetId: AssetId.Unit, nftMetadata: null, staleAt: expect.any(Date), tokenMetadata: null }
    ]);
  });

  it('handles an empty cache and fetches all assets', async () => {
    const fetchedAssets = [
      { assetId: AssetId.TSLA, nftMetadata: null, tokenMetadata: null },
      { assetId: AssetId.PXL, nftMetadata: null, tokenMetadata: null }
    ];

    (assetProvider.getAssets as jest.Mock).mockImplementation(() => Promise.resolve(fetchedAssets));

    const assetCache$ = of(new Map());
    const totalBalance$ = of({ assets: new Map(), coins: 0n });

    const assetService = createAssetService(assetProvider, assetCache$, totalBalance$, retryBackoffConfig, logger);

    const result$ = assetService([AssetId.TSLA, AssetId.PXL]);

    const assets = await firstValueFrom(result$);

    expect(assets).toEqual([
      { assetId: AssetId.TSLA, nftMetadata: null, staleAt: expect.any(Date), tokenMetadata: null },
      { assetId: AssetId.PXL, nftMetadata: null, staleAt: expect.any(Date), tokenMetadata: null }
    ]);
  });

  it('fetches stale assets from the provider', async () => {
    const cachedAssets = new Map([
      // Stale
      [
        AssetId.TSLA,
        {
          assetId: AssetId.TSLA,
          nftMetadata: { name: 'tsla_cached_name' },
          staleAt: new Date(Date.now() - ONE_WEEK),
          tokenMetadata: null
        } as never
      ],
      // Fresh
      [
        AssetId.PXL,
        {
          assetId: AssetId.PXL,
          nftMetadata: { name: 'pxl_cached_name' },
          staleAt: new Date(Date.now() + ONE_WEEK),
          tokenMetadata: null
        } as never
      ]
    ]);

    const fetchedAssets = [{ assetId: AssetId.TSLA, nftMetadata: { name: 'tsla_updated_name' }, tokenMetadata: null }];

    (assetProvider.getAssets as jest.Mock).mockImplementation((args: { assetIds: Cardano.AssetId[] }) => {
      expect(args.assetIds).toEqual([AssetId.TSLA]); // Only stale asset should be requested
      return Promise.resolve(fetchedAssets);
    });

    const assetCache$ = of(cachedAssets);
    const totalBalance$ = of({
      assets: new Map([
        [AssetId.TSLA, 1000n],
        [AssetId.PXL, 1000n]
      ]),
      coins: 0n
    });

    const assetService = createAssetService(assetProvider, assetCache$, totalBalance$, retryBackoffConfig, logger);

    const result$ = assetService([AssetId.TSLA, AssetId.PXL]);

    const assets = await firstValueFrom(result$);

    expect(assets).toEqual([
      {
        assetId: AssetId.PXL,
        nftMetadata: { name: 'pxl_cached_name' },
        staleAt: expect.any(Date),
        tokenMetadata: null
      },
      {
        assetId: AssetId.TSLA,
        nftMetadata: { name: 'tsla_updated_name' },
        staleAt: expect.any(Date),
        tokenMetadata: null
      }
    ]);
    expect(assetProvider.getAssets).toHaveBeenCalledTimes(1);
  });
});
