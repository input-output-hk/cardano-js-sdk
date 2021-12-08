import { CSL, Cardano, coreToCsl } from '@cardano-sdk/core';
import { SelectionResult } from '@cardano-sdk/cip2';

export type TxInternals = {
  hash: Cardano.TransactionId;
  body: Cardano.TxBodyAlonzo;
};

export type CreateTxInternalsProps = {
  changeAddress: Cardano.Address;
  inputSelection: SelectionResult['selection'];
  validityInterval: Cardano.ValidityInterval;
  certificates?: Cardano.Certificate[];
  withdrawals?: Cardano.Withdrawal[];
};

export const createTransactionInternals = async ({
  changeAddress,
  withdrawals,
  certificates,
  validityInterval,
  inputSelection
}: CreateTxInternalsProps): Promise<TxInternals> => {
  const outputs = [...inputSelection.outputs];
  for (const value of inputSelection.change) {
    outputs.push({
      address: changeAddress,
      value
    });
  }
  const body = {
    // TODO: return more fields. Also add support in coreToCsl.txBody:
    // collaterals, mint, requiredExtraSignatures, scriptIntegrityHash
    certificates,
    fee: inputSelection.fee,
    inputs: [...inputSelection.inputs].map(([txIn]) => txIn),
    outputs,
    validityInterval,
    withdrawals
  };
  return {
    body,
    hash: Cardano.TransactionId(Buffer.from(CSL.hash_transaction(coreToCsl.txBody(body)).to_bytes()).toString('hex'))
  };
};
