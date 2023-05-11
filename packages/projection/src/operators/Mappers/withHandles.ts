import { Cardano } from '@cardano-sdk/core';
import { FilterByPolicyIds } from './types';
import { ProjectionOperator } from '../../types';
import { WithUtxo } from './withUtxo';
import { map } from 'rxjs';

export interface Handle {
  handle: string;
  address: Cardano.PaymentAddress;
  assetId: Cardano.AssetId;
}

export interface WithHandles {
  handles: Handle[];
}

export const withHandles =
  <PropsIn extends WithUtxo>({ policyIds: _policyIds }: FilterByPolicyIds): ProjectionOperator<PropsIn, WithHandles> =>
  // eslint-disable-next-line unicorn/consistent-function-scoping
  (evt$) =>
    evt$.pipe(
      map((evt) => ({
        ...evt,
        // TODO: map tx outputs to handles
        handles: []
      }))
    );
