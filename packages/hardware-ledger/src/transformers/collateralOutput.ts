import { Cardano } from '@cardano-sdk/core';
import { LedgerTxTransformerContext } from '../types';
import { toTxOut } from './txOut';

export const mapCollateralTxOut = (collateralTxOut: Cardano.TxOut | undefined, context: LedgerTxTransformerContext) =>
  collateralTxOut ? toTxOut({ index: 0, isCollateral: true, txOut: collateralTxOut }, context) : null;
