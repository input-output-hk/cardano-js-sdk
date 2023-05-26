import { Asset, Cardano } from '@cardano-sdk/core';
import { FilterByPolicyIds } from './types';
import { ProjectionOperator } from '../../types';
import { isNotNil } from '@cardano-sdk/util';
import { map } from 'rxjs';

export interface Handle {
  handle: string;
  address: Cardano.PaymentAddress;
  assetId: Cardano.AssetId;
  policyId: Cardano.PolicyId;
  datum?: Cardano.Datum;
}

export interface WithHandles {
  handles: Handle[];
}

export const withHandles =
  <PropsIn>({ policyIds }: FilterByPolicyIds): ProjectionOperator<PropsIn, WithHandles> =>
  (evt$) =>
    evt$.pipe(
      map((evt) => ({
        ...evt,
        handles: evt.block.body
          .flatMap(({ body: { outputs } }) =>
            outputs.flatMap(({ address, value, datum }) =>
              [...(value.assets?.entries() || [])].map(([assetId]): Handle | null => {
                const policyId = Asset.util.policyIdFromAssetId(assetId);
                if (!policyIds.includes(policyId)) return null;
                return {
                  address,
                  assetId,
                  datum,
                  handle: Buffer.from(Asset.util.assetNameFromAssetId(assetId), 'hex').toString('utf8'),
                  policyId
                };
              })
            )
          )
          .filter(isNotNil)
      }))
    );
