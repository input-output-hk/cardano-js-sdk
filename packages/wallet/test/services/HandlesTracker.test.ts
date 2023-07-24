/* eslint-disable prettier/prettier */
/* eslint-disable no-multi-spaces */
/* eslint-disable space-in-parens */
import { Asset } from '@cardano-sdk/core';
import {
  HYDRATE_HANDLE_INITIAL_INTERVAL,
  HYDRATE_HANDLE_MAX_RETRIES,
  HandleInfo,
  createHandlesTracker,
  hydrateHandleAsync,
  hydrateHandles
} from '../../src';
import { combineLatest, delay, of, take, throwError } from 'rxjs';
import { createTestScheduler, logger, mockProviders } from '@cardano-sdk/util-dev';

const {
  utxo,
  utxo2,
  ledgerTip,
  ledgerTip2,
  handleAssetId,
  handlePolicyId,
  handle,
  handleFingerprint,
  handleAssetName,
  handleAssetInfo
} = mockProviders;
const handleOutput = utxo.find(
  ([
    _,
    {
      value: { assets }
    }
  ]) => [...(assets?.keys() || [])].some((assetId) => assetId.startsWith(handlePolicyId))
)![1];

const expectedHandleInfo: HandleInfo = {
  assetId: handleAssetId,
  cardanoAddress: handleOutput.address,
  fingerprint: handleFingerprint,
  handle,
  hasDatum: !!handleOutput.datum,
  mintOrBurnCount: handleAssetInfo.mintOrBurnCount,
  name: handleAssetName,
  policyId: handlePolicyId,
  quantity: 1n,
  // We consider that handle was resolved when we got the utxo,
  // as AssetInfo is just some supplementary data
  resolvedAt: ledgerTip,
  supply: 1n
};

const expectedHydratedHandleInfo: HandleInfo = {
  ...expectedHandleInfo,
  backgroundImage: Asset.Uri('ipfs://Q2de4Fg56tNHy82300000001'),
  profilePic: undefined
};

const hydrateHandle = (handleInfo: HandleInfo) =>
  of({
    ...handleInfo,
    backgroundImage: expectedHydratedHandleInfo?.backgroundImage,
    profilePic: expectedHydratedHandleInfo?.profilePic
  }).pipe(delay(1));

const exponentialBackoffDelay = (iteration: number) => Math.pow(2, iteration) * HYDRATE_HANDLE_INITIAL_INTERVAL;

const lastInteration = HYDRATE_HANDLE_MAX_RETRIES - 1;

const retrySyntax = (retries: number) =>
  Array.from({ length: retries }, (_, i) => exponentialBackoffDelay(i) - (i === lastInteration ? 2 : 1))
    .map((exponentialDelay) => ` - ${exponentialDelay}ms `)
    .join('');

const failedToHydrateError = () => throwError('error');

describe('createHandlesTracker', () => {
  it('matches utxo$ assets to given handlePolicyIds and adds context from assetInfo$ and tip$ observables', () => {
    createTestScheduler().run(({ hot, expectObservable }) => {
      const utxo$ = hot(     '-ab-', { a: utxo, b: utxo2 });
      const tip$ = hot(      'a-b-', { a: ledgerTip, b: ledgerTip2 });
      const assetInfo$ = hot('-a-b', {
        a: new Map(),
        b: new Map([[handleAssetId, handleAssetInfo]])
      });

      const handles$ = createHandlesTracker({
        assetInfo$,
        handlePolicyIds: [handlePolicyId],
        handleProvider: {
          healthCheck: jest.fn(),
          resolveHandles: async () => []
        },
        hydrateHandle: () => hydrateHandle,
        logger,
        tip$,
        utxo$
      });

      expectObservable(handles$).toBe('---ab', {
        a: [expectedHandleInfo],
        b: [expectedHydratedHandleInfo]
      });
    });
  });

  it('filters out handles that have total supply >1', () => {
    createTestScheduler().run(({ hot, expectObservable }) => {
      const utxo$ = hot(     '-a', { a: utxo });
      const tip$ = hot(      'a-', { a: ledgerTip });
      const assetInfo$ = hot('-a', {
        a: new Map([
          [
            handleAssetId,
            {
              ...handleAssetInfo,
              supply: 2n
            }
          ]
        ])
      });

      const handles$ = createHandlesTracker({
        assetInfo$,
        handlePolicyIds: [handlePolicyId],
        handleProvider: {
          healthCheck: jest.fn(),
          resolveHandles: async () => []
        },
        hydrateHandle: () => hydrateHandle,
        logger,
        tip$,
        utxo$
      });

      expectObservable(handles$).toBe('-a', { a: [] });
    });
  });

  it('does not emit duplicates with no changes', () => {
    createTestScheduler().run(({ hot, expectObservable }) => {
      const utxo$ = hot(     '-a-', { a: utxo });
      const tip$ = hot(      'a--', { a: ledgerTip });
      const assetInfo$ = hot('-aa', { a: new Map([[handleAssetId, handleAssetInfo]]) });

      const handles$ = createHandlesTracker({
        assetInfo$,
        handlePolicyIds: [handlePolicyId],
        handleProvider: {
          healthCheck: jest.fn(),
          resolveHandles: async () => []
        },
        hydrateHandle: () => hydrateHandle,
        logger,
        tip$,
        utxo$
      });

      expectObservable(handles$).toBe('-ab', {
        a: [expectedHandleInfo],
        b: [expectedHydratedHandleInfo]
      });
    });
  });

  it('shares a single subscription to dependency observables', () => {
    createTestScheduler().run(({ hot, expectSubscriptions }) => {
      const utxo$ = hot('-a', { a: utxo });
      const tip$ = hot('a-', { a: ledgerTip });
      const assetInfo$ = hot('-a', {
        a: new Map([[handleAssetId, handleAssetInfo]])
      });
      const handles$ = createHandlesTracker({
        assetInfo$,
        handlePolicyIds: [handlePolicyId],
        handleProvider: {
          healthCheck: jest.fn(),
          resolveHandles: async () => []
        },
        hydrateHandle: () => hydrateHandle,
        logger,
        tip$,
        utxo$
      });
      combineLatest([handles$, handles$]).pipe(take(1)).subscribe();
      expectSubscriptions(utxo$.subscriptions).toBe('^!');
      expectSubscriptions(tip$.subscriptions).toBe('^!');
      expectSubscriptions(assetInfo$.subscriptions).toBe('^!');
    });
  });
});

describe('hydrateHandleAsync', () => {
  it('successfully hydrates the handle', async () => {
    const handleInfo: HandleInfo = await hydrateHandleAsync(
      {
        healthCheck: jest.fn(),
        resolveHandles: async () => [expectedHydratedHandleInfo]
      },
      logger
    )(expectedHandleInfo);

    expect(handleInfo).toEqual(expectedHydratedHandleInfo);
  });

  it('fails to hydrate the handle', async () => {
    await expect(
      hydrateHandleAsync(
        {
          healthCheck: jest.fn(),
          resolveHandles: async () => {
            throw new Error('Failed to resolve handle');
          }
        },
        logger
      )(expectedHandleInfo)
    ).rejects.toThrow('Failed to resolve handle');
  });
});

describe('hydrateHandles', () => {
  it('emits the initial handles resolution then emits the hydrated handles', async () => {
    createTestScheduler().run(({ hot, expectObservable }) => {
      const handles$ = hot('-a', { a: [expectedHandleInfo] });

      expectObservable(hydrateHandles(hydrateHandle)(handles$)).toBe('-ab', {
        a: [expectedHandleInfo],
        b: [expectedHydratedHandleInfo]
      });
    });
  });

  it('emits the initial handles resolution then backs off one time', async () => {
    createTestScheduler().run(({ hot, expectObservable }) => {
      const hydrateHandleMock = jest
        .fn()
        .mockImplementationOnce(failedToHydrateError)
        .mockImplementation(hydrateHandle);

      const handles$ = hot('-a', { a: [expectedHandleInfo] });

      expectObservable(hydrateHandles(hydrateHandleMock)(handles$)).toBe(`-a ${retrySyntax(1)} b`, {
        a: [expectedHandleInfo],
        b: [expectedHydratedHandleInfo]
      });
    });
  });

  it('emits the initial handles resolution then backs off three time', async () => {
    createTestScheduler().run(({ hot, expectObservable }) => {
      const hydrateHandleMock = jest
        .fn()
        .mockImplementationOnce(failedToHydrateError)
        .mockImplementationOnce(failedToHydrateError)
        .mockImplementationOnce(failedToHydrateError)
        .mockImplementation(hydrateHandle);

      const handles$ = hot('-a', { a: [expectedHandleInfo] });

      expectObservable(hydrateHandles(hydrateHandleMock)(handles$)).toBe(`-a ${retrySyntax(3)} b`, {
        a: [expectedHandleInfo],
        b: [expectedHydratedHandleInfo]
      });
    });
  });

  it('emits the initial handles resolution, exhaust the retries then falls back to initial resolution', async () => {
    createTestScheduler().run(({ hot, expectObservable }) => {
      const hydrateHandleMock = jest.fn().mockImplementation(failedToHydrateError);

      const handles$ = hot('-a', { a: [expectedHandleInfo] });

      expectObservable(hydrateHandles(hydrateHandleMock)(handles$)).toBe(
        `-a ${retrySyntax(HYDRATE_HANDLE_MAX_RETRIES)} b`,
        {
          a: [expectedHandleInfo],
          b: [expectedHandleInfo]
        }
      );
    });
  });
});
