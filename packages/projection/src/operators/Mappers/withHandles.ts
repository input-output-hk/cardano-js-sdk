import { Asset, Cardano } from '@cardano-sdk/core';
import { FilterByPolicyIds } from './types';
import { ProjectionOperator } from '../../types';
import { map } from 'rxjs';
import { unifiedProjectorOperator } from '../utils';

export interface Handle {
  amount: bigint;
  handle: string;
  address: Cardano.PaymentAddress;
  assetId: Cardano.AssetId;
  policyId: Cardano.PolicyId;
}

export interface WithHandles {
  handles: Handle[];
}

export const withHandles = unifiedProjectorOperator<{}, WithHandles>((evt) => ({
  ...evt,
  // map tx outputs to handles
  handles: evt.block.body.flatMap(({ body: { outputs } }) =>
    outputs.flatMap(({ address, value }) =>
      [...(value.assets?.entries() || [])].map(([assetId, amount]): Handle & { policyId: Cardano.PolicyId } => ({
        address,
        amount,
        assetId,
        handle: Buffer.from(Asset.util.assetNameFromAssetId(assetId), 'hex').toString('utf8'),
        policyId: Asset.util.policyIdFromAssetId(assetId)
      }))
    )
  )
}));

export const filterHandlesByPolicyId =
  <PropsIn extends WithHandles>({
    policyIds: _policyIds
  }: FilterByPolicyIds): ProjectionOperator<PropsIn, WithHandles> =>
  (evt$) =>
    evt$.pipe(
      map((evt) => ({
        ...evt,
        handles: evt.handles.filter(({ policyId, amount }) => _policyIds.includes(policyId) && amount === 1n)
      }))
    );
