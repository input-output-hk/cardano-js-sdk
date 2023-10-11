import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { Cardano } from '@cardano-sdk/core';
import { LedgerTxTransformerContext } from '../types';
import { Transform } from '@cardano-sdk/util';
import { util } from '@cardano-sdk/key-management';

const resolveKeyPath = async (
  txIn: Cardano.TxIn,
  context: LedgerTxTransformerContext
): Promise<Ledger.BIP32Path | null> => {
  const txOut = await context.inputResolver.resolveInput(txIn);

  let paymentKeyPath = null;

  if (txOut) {
    const knownAddress = context.knownAddresses.find(({ address }) => address === txOut.address);

    if (knownAddress) {
      paymentKeyPath = util.paymentKeyPathFromGroupedAddress(knownAddress);
    }
  }

  return paymentKeyPath;
};

export const toTxIn: Transform<Cardano.TxIn, Promise<Ledger.TxInput>, LedgerTxTransformerContext> = async (
  txIn,
  context
) => ({
  outputIndex: txIn.index,
  path: await resolveKeyPath(txIn, context!),
  txHashHex: txIn.txId
});

export const mapTxIns = async (
  txIns: Cardano.TxIn[],
  context: LedgerTxTransformerContext
): Promise<Ledger.TxInput[]> => {
  const result = txIns.map((txIn) => toTxIn(txIn, context));
  return await Promise.all(result);
};
