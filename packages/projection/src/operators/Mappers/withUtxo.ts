import { Cardano } from '@cardano-sdk/core';
import { FilterByPolicyIds } from './types';
import { ProjectionOperator } from '../../types';
import { map } from 'rxjs';
import { unifiedProjectorOperator } from '../utils';

export interface WithUtxo {
  utxo: {
    produced: Array<[Cardano.TxIn, Cardano.TxOut]>;
    /**
     * Refers to `compactUtxoId` of a previously produced utxo
     */
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
