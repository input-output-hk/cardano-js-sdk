import * as trezor from 'trezor-connect';
import { Cardano } from '@cardano-sdk/core';
import { Transform } from '@cardano-sdk/util';
import { TrezorTxTransformerContext } from '../types';
import { resolvePaymentKeyPathForTxIn } from './keyPaths';

/**
 * Transforms the given Cardano input transaction to the Trezor
 * input transaction format using the given trezor input resolver.
 */
export const toTrezorTxIn: Transform<Cardano.TxIn, Promise<trezor.CardanoInput>, TrezorTxTransformerContext> = async (
  txIn,
  context?
) => ({
  path: (await resolvePaymentKeyPathForTxIn(txIn, context)) ?? undefined,
  prev_hash: Buffer.from(txIn.txId).toString('hex'),
  prev_index: txIn.index
});
