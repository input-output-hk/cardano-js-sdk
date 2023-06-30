import { Cardano } from '@cardano-sdk/core';
import { FilterByPolicyIds } from './types';
import { ProjectionOperator } from '../../types';
import { computeCompactTxId } from './util';
import { map } from 'rxjs';
import { unifiedProjectorOperator } from '../utils';

export interface Mint {
  assetId: Cardano.AssetId;
  policyId: Cardano.PolicyId;
  quantity: bigint;
  compactTxId: number;
}

export interface WithMint {
  mint: Mint[];
}

export const withMint = unifiedProjectorOperator<{}, WithMint>((evt) => ({
  ...evt,
  mint: evt.block.body.flatMap(({ body: { mint } }, txIndex) =>
    [...(mint?.entries() || [])].map(
      ([assetId, quantity]): Mint => ({
        assetId,
        compactTxId: computeCompactTxId(evt.block.header.blockNo, txIndex),
        policyId: Cardano.AssetId.getPolicyId(assetId),
        quantity
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
