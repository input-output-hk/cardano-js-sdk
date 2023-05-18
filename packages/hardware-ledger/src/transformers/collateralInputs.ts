import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { Cardano } from '@cardano-sdk/core';
import { LedgerTxTransformerContext } from '../types';
import { mapTxIns } from './txIn';

export const mapCollateralTxIns = async (
  collateralTxIns: Cardano.TxIn[] | undefined,
  context: LedgerTxTransformerContext
): Promise<Ledger.TxInput[] | null> => (collateralTxIns ? await mapTxIns(collateralTxIns, context) : null);
