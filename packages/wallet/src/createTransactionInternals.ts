import { SelectionResult } from '@cardano-sdk/cip2';
import { Transaction, CardanoSerializationLib, CSL } from '@cardano-sdk/core';

export type TxInternals = {
  hash: CSL.TransactionHash;
  body: CSL.TransactionBody;
};

export type CreateTxInternalsProps = {
  changeAddress: string;
  inputSelection: SelectionResult['selection'];
  validityInterval: Transaction.ValidityInterval;
};

export const createTransactionInternals = async (
  csl: CardanoSerializationLib,
  props: CreateTxInternalsProps
): Promise<TxInternals> => {
  const inputs = csl.TransactionInputs.new();
  for (const utxo of props.inputSelection.inputs) {
    inputs.add(utxo.input());
  }
  const body = csl.TransactionBody.new(
    inputs,
    props.inputSelection.outputs,
    csl.BigNum.from_str(props.inputSelection.fee.toString()),
    props.validityInterval.invalidHereafter
  );
  if (props.validityInterval.invalidBefore !== undefined) {
    body.set_validity_start_interval(props.validityInterval.invalidBefore);
  }
  return {
    body,
    hash: csl.hash_transaction(body)
  };
};
