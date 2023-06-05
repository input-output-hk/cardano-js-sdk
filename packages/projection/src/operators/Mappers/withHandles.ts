import { Cardano } from '@cardano-sdk/core';
import { FilterByPolicyIds } from './types';
import { ProjectionOperator } from '../../types';
import { map } from 'rxjs';

export interface Handle {
  handle: string;
  /**
   * Last effect on this handle in this block.
   * - if it's non-`null`, it means it was found in one of the transaction outputs, but it does not
   *   mean that the handle is valid - it could still have total supply >1
   * - if it's `null`, it means handle was burned, but it does not mean that the handle is invalid,
   *   as it could also be burned as a corrective action.
   */
  latestOwnerAddress: Cardano.PaymentAddress | null;
  assetId: Cardano.AssetId;
  policyId: Cardano.PolicyId;
  datum?: Cardano.Datum;
}

export interface WithHandles {
  handles: Handle[];
}

const handleFromAssetId = (assetId: Cardano.AssetId) =>
  Buffer.from(Cardano.AssetId.getAssetName(assetId), 'hex').toString('utf8');

const getOutputHandles = (outputs: Cardano.TxOut[], policyIds: FilterByPolicyIds['policyIds']) => {
  const handles: Record<string, Handle> = {};
  for (const { address, value, datum } of outputs) {
    if (!value.assets) continue;
    for (const [assetId] of value.assets.entries()) {
      const policyId = Cardano.AssetId.getPolicyId(assetId);
      if (!policyIds.includes(policyId)) continue;
      const handle = handleFromAssetId(assetId);
      handles[handle] = {
        assetId,
        datum,
        handle,
        latestOwnerAddress: address,
        policyId
      };
    }
  }
  return handles;
};

const getBurnedHandles = (mint: Cardano.TokenMap | undefined, policyIds: FilterByPolicyIds['policyIds']) => {
  if (!mint) return;
  const handles: Record<string, Handle> = {};
  for (const [assetId, quantity] of mint.entries()) {
    // Positive quantity mint was already accounted for in 'getOutputHandles'
    if (quantity < 0n) {
      const policyId = Cardano.AssetId.getPolicyId(assetId);
      if (!policyIds.includes(policyId)) continue;
      const handle = handleFromAssetId(assetId);
      handles[handle] = {
        assetId,
        handle,
        latestOwnerAddress: null,
        policyId
      };
    }
  }
  return handles;
};

export const withHandles =
  <PropsIn>({ policyIds }: FilterByPolicyIds): ProjectionOperator<PropsIn, WithHandles> =>
  (evt$) =>
    evt$.pipe(
      map((evt) => {
        const handleMap = evt.block.body.reduce(
          (handles, { body: { outputs, mint } }) => ({
            ...handles,
            ...getOutputHandles(outputs, policyIds),
            ...getBurnedHandles(mint, policyIds)
          }),
          {} as Record<string, Handle>
        );
        return {
          ...evt,
          handles: [...Object.values(handleMap)]
        };
      })
    );
