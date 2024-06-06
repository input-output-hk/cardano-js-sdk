import { toTxOut } from './txOut.js';
import type { Cardano } from '@cardano-sdk/core';
import type { LedgerTxTransformerContext } from '../types.js';

export const mapCollateralTxOut = (collateralTxOut: Cardano.TxOut | undefined, context: LedgerTxTransformerContext) =>
  collateralTxOut ? toTxOut(collateralTxOut, context) : null;
