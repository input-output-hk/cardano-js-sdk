/* eslint-disable prettier/prettier */
/* eslint-disable no-multi-spaces */
/* eslint-disable space-in-parens */
import { HandleInfo, createHandlesTracker } from '../../src';
import { combineLatest, take } from 'rxjs';
import { createTestScheduler, logger, mockProviders } from '@cardano-sdk/util-dev';

const {
  utxo, utxo2, ledgerTip, ledgerTip2, handleAssetId,
  handlePolicyId, handle, handleFingerprint, handleAssetName, handleAssetInfo
} = mockProviders;
const handleOutput = utxo.find(([_, { value: { assets } }]) =>
  [...assets?.keys() || []].some(assetId => assetId.startsWith(handlePolicyId)))![1];

const expectedHandleInfo = {
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
} as HandleInfo;

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
        assetInfo$, handlePolicyIds: [handlePolicyId], logger, tip$, utxo$
      });

      expectObservable(handles$).toBe('---a', { a: [expectedHandleInfo] });
    });
  });

  it('filters out handles that have total supply >1', () => {
    createTestScheduler().run(({ hot, expectObservable }) => {
      const utxo$ = hot(     '-a', { a: utxo });
      const tip$ = hot(      'a-', { a: ledgerTip });
      const assetInfo$ = hot('-a', {
        a: new Map([[handleAssetId, {
          ...handleAssetInfo,
          supply: 2n
        }]])
      });

      const handles$ = createHandlesTracker({
        assetInfo$, handlePolicyIds: [handlePolicyId], logger, tip$, utxo$
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
        assetInfo$, handlePolicyIds: [handlePolicyId], logger, tip$, utxo$
      });

      expectObservable(handles$).toBe('-a-', { a: [expectedHandleInfo] });
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
        assetInfo$, handlePolicyIds: [handlePolicyId], logger, tip$, utxo$
      });
      combineLatest([handles$, handles$]).pipe(take(1)).subscribe();
      expectSubscriptions(utxo$.subscriptions).toBe('^!');
      expectSubscriptions(tip$.subscriptions).toBe('^!');
      expectSubscriptions(assetInfo$.subscriptions).toBe('^!');
    });
  });
});
