import { Cardano } from '@cardano-sdk/core';
import { map } from 'rxjs';
import { unifiedProjectorOperator } from '../utils/index.js';
import type { FilterByPolicyIds } from './types.js';
import type { ProjectionOperator } from '../../types.js';

export type ProducedUtxo = [Cardano.TxIn, Cardano.TxOut];

export interface WithUtxo {
  utxo: {
    produced: Array<ProducedUtxo>;
    /** Refers to `compactUtxoId` of a previously produced utxo */
    consumed: Cardano.TxIn[];
  };
}

export const withUtxo = unifiedProjectorOperator<{}, WithUtxo>((evt) => {
  const produced = evt.block.body.flatMap(({ body: { outputs, collateralReturn }, inputSource, id }) =>
    (inputSource === Cardano.InputSource.inputs ? outputs : collateralReturn ? [collateralReturn] : []).map(
      (txOut, outputIndex): [Cardano.TxIn, Cardano.TxOut] => [
        {
          index: outputIndex,
          txId: id
        },
        txOut
      ]
    )
  );
  const consumed = evt.block.body.flatMap(({ body: { inputs, collaterals }, inputSource }) =>
    inputSource === Cardano.InputSource.inputs ? inputs : collaterals || []
  );
  return { ...evt, utxo: { consumed, produced } };
});

export interface FilterByPaymentAddresses {
  addresses: Cardano.PaymentAddress[];
}

export const filterProducedUtxoByAddresses =
  <PropsIn extends WithUtxo>({ addresses }: FilterByPaymentAddresses): ProjectionOperator<PropsIn> =>
  (evt$) =>
    evt$.pipe(
      map((evt) => ({
        ...evt,
        utxo: { ...evt.utxo, produced: evt.utxo.produced.filter(([_, { address }]) => addresses.includes(address)) }
      }))
    );

export const filterProducedUtxoByAssetsPresence =
  <PropsIn extends WithUtxo>(): ProjectionOperator<PropsIn> =>
  // eslint-disable-next-line unicorn/consistent-function-scoping
  (evt$) =>
    evt$.pipe(
      map((evt) => ({
        ...evt,
        utxo: {
          ...evt.utxo,
          produced: evt.utxo.produced.filter(([_, { value }]) => value.assets && value.assets.size > 0)
        }
      }))
    );

export const filterProducedUtxoByAssetPolicyId =
  <PropsIn extends WithUtxo>({ policyIds }: FilterByPolicyIds): ProjectionOperator<PropsIn> =>
  (evt$) =>
    evt$.pipe(
      map((evt) => ({
        ...evt,
        utxo: {
          ...evt.utxo,
          produced: evt.utxo.produced
            .map(
              ([txIn, txOut]) =>
                [
                  txIn,
                  {
                    ...txOut,
                    value: {
                      ...txOut.value,
                      assets: txOut.value.assets
                        ? new Map(
                            [...txOut.value.assets.entries()].filter(([assetId]) =>
                              policyIds.includes(Cardano.AssetId.getPolicyId(assetId))
                            )
                          )
                        : undefined
                    }
                  }
                ] as const
            )
            .filter(
              ([
                _,
                {
                  value: { assets }
                }
              ]) => assets && assets.size > 0
            )
        }
      }))
    );
