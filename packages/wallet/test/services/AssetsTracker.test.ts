import { Asset, Cardano } from '@cardano-sdk/core';
import { AssetId, createTestScheduler, generateRandomHexString, logger } from '@cardano-sdk/util-dev';
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
  ({ body: { outputs: values.map((value) => ({ value })) }, id: generateRandomHexString(64) } as Cardano.HydratedTx);

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
        { assetProvider, logger, retryBackoffConfig, transactionsTracker } as unknown as AssetsTrackerProps,
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
        { assetProvider, logger, retryBackoffConfig, transactionsTracker } as unknown as AssetsTrackerProps,
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
        { assetProvider, logger, retryBackoffConfig, transactionsTracker } as unknown as AssetsTrackerProps,
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
        { assetProvider, logger, retryBackoffConfig, transactionsTracker } as unknown as AssetsTrackerProps,
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
      logger,
      retryBackoffConfig,
      transactionsTracker
    } as unknown as AssetsTrackerProps);

    const assetInfos: Map<Cardano.AssetId, Asset.AssetInfo>[] = [];
    await lastValueFrom(target$.pipe(tap((ai) => assetInfos.push(ai))));
    expect(assetInfos).toEqual([
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
