import { mapTxIns } from './txIn.js';
import type * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import type { Cardano } from '@cardano-sdk/core';
import type { LedgerTxTransformerContext } from '../types.js';

export const mapCollateralTxIns = (
  collateralTxIns: Cardano.TxIn[] | undefined,
  context: LedgerTxTransformerContext
): Ledger.TxInput[] | null => (collateralTxIns ? mapTxIns(collateralTxIns, context) : null);
