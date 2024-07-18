import { Cardano } from '@cardano-sdk/core';
import { FilterByPolicyIds } from './types';
import { ProjectionOperator } from '../../types';
import { map } from 'rxjs';
import { unifiedProjectorOperator } from '../utils';

export type ProducedUtxo = [Cardano.TxIn, Cardano.TxOut];

export interface WithProducedUTxO {
  produced: Array<ProducedUtxo>;
}
export interface WithConsumedTxIn {
  /** Refers to `compactUtxoId` of a previously produced utxo */
  consumed: Cardano.TxIn[];
}
export interface WithUtxo {
  /** Complete utxo set from block including all transactions */
  utxo: WithConsumedTxIn & WithProducedUTxO;
  /** Utxo set grouped by transaction id */
  utxoByTx: Record<Cardano.TransactionId, WithConsumedTxIn & WithProducedUTxO>;
}

export const withUtxo = unifiedProjectorOperator<{}, WithUtxo>((evt) => {
  const txToUtxos = new Map<Cardano.TransactionId, WithConsumedTxIn & WithProducedUTxO>();

  for (const {
    body: { collaterals, inputs, outputs, collateralReturn },
    inputSource,
    id
  } of evt.block.body) {
    txToUtxos.set(id, {
      consumed: inputSource === Cardano.InputSource.inputs ? inputs : collaterals || [],
      produced: (inputSource === Cardano.InputSource.inputs ? outputs : collateralReturn ? [collateralReturn] : []).map(
        (txOut, outputIndex): [Cardano.TxIn, Cardano.TxOut] => [
          {
            index: outputIndex,
            txId: id
          },
          txOut
        ]
      )
    });
  }

  const utxoByTx = Object.fromEntries(txToUtxos);
  return {
    ...evt,
    utxo: {
      consumed: Object.values(utxoByTx).flatMap((tx) => tx.consumed),
      produced: Object.values(utxoByTx).flatMap((tx) => tx.produced)
    },
    utxoByTx
  };
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
        utxo: { ...evt.utxo, produced: evt.utxo.produced.filter(([_, { address }]) => addresses.includes(address)) },
        utxoByTx: {
          ...Object.fromEntries(
            Object.entries(evt.utxoByTx).reduce(
              (txToUtxo, [txId, utxos]) => ({
                ...txToUtxo,
                [txId]: {
                  ...utxos,
                  produced: utxos.produced.filter(([_, { address }]) => addresses.includes(address))
                }
              }),
              new Map<Cardano.TransactionId, WithConsumedTxIn & WithProducedUTxO>()
            )
          )
        } as Record<Cardano.TransactionId, WithConsumedTxIn & WithProducedUTxO>
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
        },
        utxoByTx: {
          ...evt.utxoByTx,
          ...Object.fromEntries(
            Object.entries(evt.utxoByTx).reduce(
              (txToUtxo, [txId, utxos]) => ({
                ...txToUtxo,
                [txId]: {
                  ...utxos,
                  produced: utxos.produced.filter(([_, { value }]) => value.assets && value.assets.size > 0)
                }
              }),
              new Map<Cardano.TransactionId, WithConsumedTxIn & WithProducedUTxO>()
            )
          )
        } as Record<Cardano.TransactionId, WithConsumedTxIn & WithProducedUTxO>
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
        },
        utxoByTx: {
          ...evt.utxoByTx,
          ...Object.entries(evt.utxoByTx).reduce(
            (txToUtxo, [txId, utxos]) => ({
              ...txToUtxo,
              [txId]: {
                ...utxos,
                produced: {
                  ...utxos.produced,
                  ...utxos.produced.map(([txIn, txOut]) => [
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
                  ])
                }
              }
            }),
            new Map<Cardano.TransactionId, WithConsumedTxIn & WithProducedUTxO>()
          )
        }
      }))
    );
