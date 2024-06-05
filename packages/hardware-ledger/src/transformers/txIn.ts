import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { Cardano } from '@cardano-sdk/core';
import { LedgerTxTransformerContext } from '../types';
import { Transform } from '@cardano-sdk/util';
import { TxInId, util } from '@cardano-sdk/key-management';

const resolveKeyPath = (
  txIn: Cardano.TxIn,
  { accountIndex, txInKeyPathMap, purpose }: LedgerTxTransformerContext
): Ledger.BIP32Path | null => {
  const txInKeyPath = txInKeyPathMap[TxInId(txIn)];

  if (!txInKeyPath || txInKeyPath.role === undefined || txInKeyPath.index === undefined) return null;

  const utxoKeyPath = {
    ...txInKeyPath,
    purpose
  };

  return util.accountKeyDerivationPathToBip32Path(accountIndex, utxoKeyPath);
};

export const toTxIn: Transform<Cardano.TxIn, Ledger.TxInput, LedgerTxTransformerContext> = (txIn, context) => ({
  outputIndex: txIn.index,
  path: resolveKeyPath(txIn, context!),
  txHashHex: txIn.txId
});

export const mapTxIns = (txIns: Cardano.TxIn[], context: LedgerTxTransformerContext): Ledger.TxInput[] =>
  txIns.map((txIn) => toTxIn(txIn, context));
