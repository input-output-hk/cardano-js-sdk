import { Cardano } from '@cardano-sdk/core';
import { LedgerTxTransformerContext } from '../types';
import { toTxOut } from './txOut';

export const mapCollateralTxOut = (collateralTxOut: Cardano.TxOut | undefined, context: LedgerTxTransformerContext) =>
  collateralTxOut ? toTxOut(collateralTxOut, context) : null;
