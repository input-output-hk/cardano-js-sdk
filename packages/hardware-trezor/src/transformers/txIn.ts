import * as Trezor from '@trezor/connect';
import { Cardano } from '@cardano-sdk/core';
import { Transform } from '@cardano-sdk/util';
import { TrezorTxTransformerContext } from '../types';
import { resolvePaymentKeyPathForTxIn } from './keyPaths';

/**
 * Transforms the given Cardano input transaction to the Trezor
 * input transaction format using the given trezor input resolver.
 */
export const toTrezorTxIn: Transform<Cardano.TxIn, Trezor.CardanoInput, TrezorTxTransformerContext> = (
  txIn,
  context?
) => {
  const path = resolvePaymentKeyPathForTxIn(txIn, context);
  return {
    path,
    prev_hash: txIn.txId,
    prev_index: txIn.index
  };
};

/**
 * Transforms an array of core Cardano transaction inputs to
 * an array of trezor Cardano transaction inputs using the
 * given context.
 */
export const mapTxIns = (txIns: Cardano.TxIn[], context: TrezorTxTransformerContext): Trezor.CardanoInput[] =>
  txIns.map((txIn) => toTrezorTxIn(txIn, context));
