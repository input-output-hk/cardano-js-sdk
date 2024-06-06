import { Cardano } from '@cardano-sdk/core';
import { computeCompactTxId } from './util.js';
import { map } from 'rxjs';
import { unifiedProjectorOperator } from '../utils/index.js';
import type { FilterByPolicyIds } from './types.js';
import type { ProjectionOperator } from '../../types.js';

export interface Mint {
  assetId: Cardano.AssetId;
  policyId: Cardano.PolicyId;
  assetName: Cardano.AssetName;
  quantity: bigint;
  compactTxId: number;
  txMetadata?: Cardano.TxMetadata;
}

export interface WithMint {
  mint: Mint[];
}

export const withMint = unifiedProjectorOperator<{}, WithMint>((evt) => ({
  ...evt,
  mint: evt.block.body.flatMap(({ body: { mint }, auxiliaryData }, txIndex) =>
    [...(mint?.entries() || [])].map(
      ([assetId, quantity]): Mint => ({
        assetId,
        assetName: Cardano.AssetId.getAssetName(assetId),
        compactTxId: computeCompactTxId(evt.block.header.blockNo, txIndex),
        policyId: Cardano.AssetId.getPolicyId(assetId),
        quantity,
        txMetadata: auxiliaryData?.blob
      })
    )
  )
}));

export const filterMintByPolicyIds =
  <PropsIn extends WithMint>({ policyIds }: FilterByPolicyIds): ProjectionOperator<PropsIn> =>
  (evt$) =>
    evt$.pipe(
      map((evt) => ({
        ...evt,
        mint: evt.mint.filter(({ policyId }) => policyIds.includes(policyId))
      }))
    );
