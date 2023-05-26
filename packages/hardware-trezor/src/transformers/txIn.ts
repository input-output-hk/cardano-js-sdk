import * as Trezor from 'trezor-connect';
import { Cardano } from '@cardano-sdk/core';
import { Transform } from '@cardano-sdk/util';
import { TrezorTxTransformerContext } from '../types';
import { resolvePaymentKeyPathForTxIn } from './keyPaths';

/**
 * Transforms the given Cardano input transaction to the Trezor
 * input transaction format using the given trezor input resolver.
 */
export const toTrezorTxIn: Transform<Cardano.TxIn, Promise<Trezor.CardanoInput>, TrezorTxTransformerContext> = async (
  txIn,
  context?
) => ({
  path: (await resolvePaymentKeyPathForTxIn(txIn, context)) ?? undefined,
  prev_hash: Buffer.from(txIn.txId).toString('hex'),
  prev_index: txIn.index
});

/**
 * Transforms an array of core Cardano transaction inputs to
 * an array of trezor Cardano transaction inputs using the
 * given context.
 */
export const mapTxIns = async (
  txIns: Cardano.TxIn[],
  context: TrezorTxTransformerContext
): Promise<Trezor.CardanoInput[]> => Promise.all(txIns.map((txIn) => toTrezorTxIn(txIn, context)));
