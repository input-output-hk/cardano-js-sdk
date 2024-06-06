import type * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import type { Cardano } from '@cardano-sdk/core';

export const mapReferenceInputs = (collateralTxIns: Cardano.TxIn[] | undefined): Ledger.TxInput[] | null =>
  collateralTxIns
    ? collateralTxIns.map((txIn) => ({
        outputIndex: txIn.index,
        path: null,
        txHashHex: txIn.txId.toString()
      }))
    : null;
