import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { Cardano } from '@cardano-sdk/core';
import { LedgerTxTransformerContext } from '../types';
import { Transform } from '@cardano-sdk/util';
import { TxInId, util } from '@cardano-sdk/key-management';

const resolveKeyPath = (
  txIn: Cardano.TxIn,
  { accountIndex, txInKeyPathMap }: LedgerTxTransformerContext
): Ledger.BIP32Path | null => {
  const utxoKeyPath = txInKeyPathMap[TxInId(txIn)];
  if (utxoKeyPath) {
    return util.accountKeyDerivationPathToBip32Path(accountIndex, utxoKeyPath);
  }

  return null;
};

export const toTxIn: Transform<Cardano.TxIn, Ledger.TxInput, LedgerTxTransformerContext> = (txIn, context) => ({
  outputIndex: txIn.index,
  path: resolveKeyPath(txIn, context!),
  txHashHex: txIn.txId
});

export const mapTxIns = (txIns: Cardano.TxIn[], context: LedgerTxTransformerContext): Ledger.TxInput[] =>
  txIns.map((txIn) => toTxIn(txIn, context));
