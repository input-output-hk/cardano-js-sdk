import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { Cardano } from '@cardano-sdk/core';
import { LedgerTxTransformerContext } from '../types';
import { mapTxIns } from './txIn';

export const mapCollateralTxIns = (
  collateralTxIns: Cardano.TxIn[] | undefined,
  context: LedgerTxTransformerContext
): Ledger.TxInput[] | null => (collateralTxIns ? mapTxIns(collateralTxIns, context) : null);
